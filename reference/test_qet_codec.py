import json
import pytest

from qet_codec import Expr, Message, decode, encode, open_sealed, seal, to_semantics


def sample() -> Message:
    return Message(
        version=1,
        sender=1,
        recipient=1002,
        body=Expr.sequence([
            Expr.operation("OP", [
                Expr.concept(202),
                Expr.concept(2501),
            ]),
            Expr.modifier("Y", Expr.concept(101)),
            Expr.operation("SR", [
                Expr.concept(1),
                Expr.concept(1001),
            ]),
        ]),
    )


def test_compact_roundtrip() -> None:
    message = sample()
    assert decode(encode(message)) == message


def test_semantics_is_compositional() -> None:
    value = to_semantics(sample().body)
    assert value["kind"] == "sequence"
    assert value["items"][0]["operator"] == "OP"
    assert value["items"][1]["modifier"] == "Y"


@pytest.mark.parametrize("algorithm", ["A256GCM", "CHACHA20POLY1305"])
def test_aead_roundtrip(algorithm: str) -> None:
    message = sample()
    key = bytes(range(32))
    recovered = open_sealed(seal(message, key, algorithm), key)
    assert recovered == message


def test_aead_rejects_routing_tamper() -> None:
    message = sample()
    key = bytes(range(32))
    envelope = json.loads(seal(message, key))
    envelope["recipient"] = 1003
    with pytest.raises(ValueError):
        open_sealed(json.dumps(envelope), key)


def test_aead_rejects_ciphertext_tamper() -> None:
    message = sample()
    key = bytes(range(32))
    envelope = json.loads(seal(message, key))
    ciphertext = envelope["ciphertext"]
    envelope["ciphertext"] = ("A" if ciphertext[0] != "A" else "B") + ciphertext[1:]
    with pytest.raises(ValueError):
        open_sealed(json.dumps(envelope), key)


def test_parser_rejects_bad_boundary() -> None:
    with pytest.raises(ValueError):
        decode("※v1/s1/r2|O999[C20]|◎◉")
