# External design inputs

QET-ML is not intended to reinvent every successful part of the 2020s protocol stack.

## Formal semantics

RDF provides a useful reference shape for graph semantics: resources and statements are represented through subject-predicate-object structure, and the current RDF 1.2 work also specifies entailment semantics. QET-ML adopts only the generic relational idea; its ontology remains independent.

## Agent interoperability

The current Agent2Agent (A2A) specification separates an agent data model from transport bindings and defines concepts such as Agent Card, Message, Part, Task, Artifact, and extensions. QET-ML uses the same architectural separation: language syntax/semantics are independent of the transport.

QET-ML currently maps:

- Agent -> sender/recipient identifiers and future capability records
- Message -> QET Message / Envelope
- Task -> optional taskId
- Artifact -> protocol-level output object
- Extension -> namespaced versioned extension

This is an architectural analogy, not a claim of wire compatibility.

## Authenticated encryption

RFC 8439 specifies ChaCha20-Poly1305 AEAD with a 256-bit key, a 96-bit nonce, associated data, and a 128-bit authentication tag. The reference codec follows this parameter shape.

AES-GCM is provided as a second AEAD option through the Python cryptography library.

## Group key management

For future multi-agent groups, RFC 9420 (MLS) is a useful research baseline because it addresses asynchronous group key establishment together with forward secrecy and post-compromise security.

## Why this matters

The result is a layered architecture:

language syntax
-> typed abstract syntax
-> compositional semantics
-> ontology / knowledge relations
-> agent protocol envelope
-> canonical serialization
-> authenticated encryption
-> transport binding

Only the first six layers belong to the language specification itself. Security keys and external authorization remain outside the public source tree.
