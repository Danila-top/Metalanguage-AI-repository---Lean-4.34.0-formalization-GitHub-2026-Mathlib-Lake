from __future__ import annotations

from dataclasses import dataclass
import base64
import json
import re
import secrets
from typing import Any

from cryptography.hazmat.primitives.ciphers.aead import AESGCM, ChaCha20Poly1305


OPERATOR_IDS = {"OP": 20, "SR": 21, "FL": 22}
MODIFIER_IDS = {"E": 30, "C": 31, "T": 32, "R": 33, "Y": 34, "CH": 35}
OPERATOR_NAMES = {value: key for key, value in OPERATOR_IDS.items()}
MODIFIER_NAMES = {value: key for key, value in MODIFIER_IDS.items()}

_MESSAGE_RE = re.compile(
    r"^※v(?P<v>[0-9]+)/s(?P<s>[0-9]+)/r(?P<r>[0-9]+)\|(?P<body>.*)\|◎◉$",
    re.DOTALL,
)


@dataclass(frozen=True)
class Expr:
    kind: str
    value: Any = None

    @staticmethod
    def concept(identifier: int) -> "Expr":
        return Expr("concept", int(identifier))

    @staticmethod
    def integer(value: int) -> "Expr":
        return Expr("integer", int(value))

    @staticmethod
    def text(value: str) -> "Expr":
        return Expr("text", str(value))

    @staticmethod
    def boolean(value: bool) -> "Expr":
        return Expr("boolean", bool(value))

    @staticmethod
    def operation(operator: str, args: list["Expr"]) -> "Expr":
        if operator not in OPERATOR_IDS:
            raise ValueError(f"unknown operator: {operator}")
        return Expr("operation", (operator, list(args)))

    @staticmethod
    def modifier(modifier: str, body: "Expr") -> "Expr":
        if modifier not in MODIFIER_IDS:
            raise ValueError(f"unknown modifier: {modifier}")
        return Expr("modifier", (modifier, body))

    @staticmethod
    def sequence(items: list["Expr"]) -> "Expr":
        items = list(items)
        if not items:
            raise ValueError("sequence must be non-empty")
        return Expr("sequence", items)


@dataclass(frozen=True)
class Message:
    version: int
    sender: int
    recipient: int
    body: Expr

    def validate(self) -> None:
        if self.version <= 0:
            raise ValueError("version must be positive")
        if self.sender < 0 or self.recipient < 0:
            raise ValueError("sender and recipient must be non-negative")
        _validate_expr(self.body)


def _validate_expr(expr: Expr) -> None:
    if expr.kind in {"concept", "integer", "text", "boolean"}:
        return
    if expr.kind == "operation":
        operator, args = expr.value
        if operator not in OPERATOR_IDS:
            raise ValueError("unknown operator")
        for arg in args:
            _validate_expr(arg)
        return
    if expr.kind == "modifier":
        modifier, body = expr.value
        if modifier not in MODIFIER_IDS:
            raise ValueError("unknown modifier")
        _validate_expr(body)
        return
    if expr.kind == "sequence":
        if not expr.value:
            raise ValueError("sequence must be non-empty")
        for item in expr.value:
            _validate_expr(item)
        return
    raise ValueError(f"unknown expression kind: {expr.kind}")


def _b64e(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).decode("ascii").rstrip("=")


def _b64d(value: str) -> bytes:
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(value + padding)


def encode_expr(expr: Expr) -> str:
    _validate_expr(expr)
    if expr.kind == "concept":
        return f"C{expr.value}"
    if expr.kind == "integer":
        return f"N{expr.value}"
    if expr.kind == "text":
        return f"T{_b64e(expr.value.encode('utf-8'))}"
    if expr.kind == "boolean":
        return "B1" if expr.value else "B0"
    if expr.kind == "operation":
        operator, args = expr.value
        return f"O{OPERATOR_IDS[operator]}[" + ",".join(
            encode_expr(arg) for arg in args
        ) + "]"
    if expr.kind == "modifier":
        modifier, body = expr.value
        return f"M{MODIFIER_IDS[modifier]}[{encode_expr(body)}]"
    if expr.kind == "sequence":
        return "S[" + ",".join(encode_expr(item) for item in expr.value) + "]"
    raise ValueError(f"unsupported expression kind: {expr.kind}")


def encode(message: Message) -> str:
    message.validate()
    return (
        f"※v{message.version}/s{message.sender}/r{message.recipient}"
        f"|{encode_expr(message.body)}|◎◉"
    )


class _Parser:
    def __init__(self, text: str) -> None:
        self.text = text
        self.i = 0

    def at_end(self) -> bool:
        return self.i >= len(self.text)

    def peek(self, prefix: str) -> bool:
        return self.text.startswith(prefix, self.i)

    def consume(self, prefix: str) -> None:
        if not self.peek(prefix):
            raise ValueError(f"expected {prefix!r} at offset {self.i}")
        self.i += len(prefix)

    def read_digits(self) -> int:
        start = self.i
        while not self.at_end() and self.text[self.i].isdigit():
            self.i += 1
        if start == self.i:
            raise ValueError(f"expected digits at offset {self.i}")
        return int(self.text[start:self.i])

    def read_signed_integer(self) -> int:
        negative = False
        if not self.at_end() and self.text[self.i] == "-":
            negative = True
            self.i += 1
        value = self.read_digits()
        return -value if negative else value

    def read_token(self) -> str:
        start = self.i
        depth = 0
        while not self.at_end():
            ch = self.text[self.i]
            if ch == "[":
                depth += 1
            elif ch == "]":
                if depth == 0:
                    break
                depth -= 1
            elif ch == "," and depth == 0:
                break
            self.i += 1
        if start == self.i:
            raise ValueError(f"empty token at offset {self.i}")
        return self.text[start:self.i]

    def parse_expr(self) -> Expr:
        if self.peek("C"):
            self.i += 1
            return Expr.concept(self.read_digits())
        if self.peek("N"):
            self.i += 1
            return Expr.integer(self.read_signed_integer())
        if self.peek("T"):
            self.i += 1
            token = self.read_token()
            try:
                value = _b64d(token).decode("utf-8")
            except (ValueError, UnicodeDecodeError) as exc:
                raise ValueError("invalid base64url text atom") from exc
            return Expr.text(value)
        if self.peek("B0"):
            self.i += 2
            return Expr.boolean(False)
        if self.peek("B1"):
            self.i += 2
            return Expr.boolean(True)
        if self.peek("O"):
            self.i += 1
            operator_id = self.read_digits()
            operator = OPERATOR_NAMES.get(operator_id)
            if operator is None:
                raise ValueError(f"unknown operator id {operator_id}")
            args = self.parse_list()
            return Expr.operation(operator, args)
        if self.peek("M"):
            self.i += 1
            modifier_id = self.read_digits()
            modifier = MODIFIER_NAMES.get(modifier_id)
            if modifier is None:
                raise ValueError(f"unknown modifier id {modifier_id}")
            self.consume("[")
            body = self.parse_expr()
            self.consume("]")
            return Expr.modifier(modifier, body)
        if self.peek("S["):
            self.i += 2
            items = self.parse_bracket_list()
            return Expr.sequence(items)
        raise ValueError(f"unknown expression at offset {self.i}")

    def parse_list(self) -> list[Expr]:
        self.consume("[")
        return self.parse_bracket_list(already_open=True)

    def parse_bracket_list(self, already_open: bool = False) -> list[Expr]:
        if not already_open:
            self.consume("[")
        if self.peek("]"):
            self.i += 1
            return []
        items = [self.parse_expr()]
        while self.peek(","):
            self.i += 1
            items.append(self.parse_expr())
        self.consume("]")
        return items


def decode(encoded: str) -> Message:
    match = _MESSAGE_RE.fullmatch(encoded)
    if not match:
        raise ValueError("invalid message envelope")
    parser = _Parser(match.group("body"))
    expr = parser.parse_expr()
    if not parser.at_end():
        raise ValueError(f"trailing bytes at offset {parser.i}")
    message = Message(
        version=int(match.group("v")),
        sender=int(match.group("s")),
        recipient=int(match.group("r")),
        body=expr,
    )
    message.validate()
    return message


def to_semantics(expr: Expr) -> dict[str, Any]:
    _validate_expr(expr)
    if expr.kind in {"concept", "integer", "text", "boolean"}:
        return {"kind": expr.kind, "value": expr.value}
    if expr.kind == "operation":
        operator, args = expr.value
        return {
            "kind": "operation",
            "operator": operator,
            "args": [to_semantics(arg) for arg in args],
        }
    if expr.kind == "modifier":
        modifier, body = expr.value
        return {
            "kind": "modified",
            "modifier": modifier,
            "value": to_semantics(body),
        }
    if expr.kind == "sequence":
        return {
            "kind": "sequence",
            "items": [to_semantics(item) for item in expr.value],
        }
    raise ValueError("unknown expression")


def canonical_message_bytes(message: Message) -> bytes:
    message.validate()
    obj = {
        "body": to_semantics(message.body),
        "recipient": message.recipient,
        "sender": message.sender,
        "version": message.version,
    }
    return json.dumps(
        obj,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    ).encode("utf-8")


def _aad(version: int, sender: int, recipient: int) -> bytes:
    return f"qet-ml/{version}|s{sender}|r{recipient}".encode("ascii")


def seal(message: Message, key: bytes, algorithm: str = "A256GCM") -> str:
    message.validate()
    if len(key) != 32:
        raise ValueError("AEAD key must be exactly 32 bytes")
    nonce = secrets.token_bytes(12)
    aad = _aad(message.version, message.sender, message.recipient)
    plaintext = canonical_message_bytes(message)

    if algorithm == "A256GCM":
        ciphertext = AESGCM(key).encrypt(nonce, plaintext, aad)
    elif algorithm == "CHACHA20POLY1305":
        ciphertext = ChaCha20Poly1305(key).encrypt(nonce, plaintext, aad)
    else:
        raise ValueError("unsupported AEAD algorithm")

    envelope = {
        "algorithm": algorithm,
        "aad": _b64e(aad),
        "ciphertext": _b64e(ciphertext),
        "nonce": _b64e(nonce),
        "protocol": "QET-ML",
        "recipient": message.recipient,
        "sender": message.sender,
        "version": message.version,
    }
    return json.dumps(envelope, sort_keys=True, separators=(",", ":"))


def _expr_from_semantics(obj: dict[str, Any]) -> Expr:
    kind = obj.get("kind")
    if kind == "concept":
        return Expr.concept(int(obj["value"]))
    if kind == "integer":
        return Expr.integer(int(obj["value"]))
    if kind == "text":
        return Expr.text(str(obj["value"]))
    if kind == "boolean":
        return Expr.boolean(bool(obj["value"]))
    if kind == "operation":
        return Expr.operation(
            str(obj["operator"]),
            [_expr_from_semantics(x) for x in obj["args"]],
        )
    if kind == "modified":
        return Expr.modifier(
            str(obj["modifier"]),
            _expr_from_semantics(obj["value"]),
        )
    if kind == "sequence":
        return Expr.sequence([_expr_from_semantics(x) for x in obj["items"]])
    raise ValueError(f"unknown semantic kind: {kind}")


def open_sealed(envelope_json: str, key: bytes) -> Message:
    envelope = json.loads(envelope_json)
    if envelope.get("protocol") != "QET-ML":
        raise ValueError("not a QET-ML envelope")
    if len(key) != 32:
        raise ValueError("AEAD key must be exactly 32 bytes")

    version = int(envelope["version"])
    sender = int(envelope["sender"])
    recipient = int(envelope["recipient"])

    aad = _b64d(envelope["aad"])
    expected_aad = _aad(version, sender, recipient)
    if aad != expected_aad:
        raise ValueError("AAD mismatch")

    nonce = _b64d(envelope["nonce"])
    ciphertext = _b64d(envelope["ciphertext"])
    algorithm = envelope["algorithm"]

    try:
        if algorithm == "A256GCM":
            plaintext = AESGCM(key).decrypt(nonce, ciphertext, aad)
        elif algorithm == "CHACHA20POLY1305":
            plaintext = ChaCha20Poly1305(key).decrypt(nonce, ciphertext, aad)
        else:
            raise ValueError("unsupported AEAD algorithm")
    except Exception as exc:
        raise ValueError("authenticated decryption failed") from exc

    obj = json.loads(plaintext.decode("utf-8"))
    message = Message(
        version=int(obj["version"]),
        sender=int(obj["sender"]),
        recipient=int(obj["recipient"]),
        body=_expr_from_semantics(obj["body"]),
    )
    message.validate()
    return message
