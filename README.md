# QET-ML — formalized AI metalanguage

This repository is the engineering continuation of the 654-page metalanguage research corpus.

The goal is to turn the historical QET ideas into a precise, testable language for machine-to-machine communication:

**lexicon -> grammar -> AST -> semantics -> canonical encoding -> secure transport -> formal proofs**

## Repository map

- `QET/Core.lean` — typed abstract syntax and well-formedness.
- `QET/Lexicon.lean` — provenance-aware machine lexicon.
- `QET/Semantics.lean` — compositional denotational layer.
- `QET/Grammar.lean` — canonical token representation.
- `QET/Protocol.lean` — message envelope and task/context metadata.
- `QET/Examples.lean` — executable examples and Lean checks.
- `spec/GRAMMAR.ebnf` — normative grammar.
- `spec/SEMANTICS.md` — semantic specification.
- `spec/PROTOCOL.md` — protocol and canonicalization rules.
- `spec/SECURITY.md` — threat model and cryptographic boundary.
- `spec/SOURCE_MAPPING.md` — mapping from the 654-page corpus to formal constructs.
- `spec/LEXICON.json` — machine-readable dictionary.
- `reference/qet_codec.py` — reference encoder/decoder and AEAD implementation.
- `reference/test_qet_codec.py` — codec and cryptographic regression tests.

## Core wire example

A compact message is:

    ※v1/s1/r1002|O20[C202,C2501]|◎◉

Interpretation:

- version 1
- sender 1
- recipient 1002
- operation OP applied to concepts 202 and 2501

The language can also express explicit self-reference with SR, feedback with FL, modifiers, nested structures, sequences, text, numbers, and Boolean values.

## What "secret" means here

The source code is intentionally public and inspectable. Secrecy comes from external cryptographic keys and authenticated encryption, not from an undocumented grammar.

The reference transport uses AES-256-GCM or ChaCha20-Poly1305. No private key belongs in this repository.

## Formalization status

The Lean layer is the normative semantic foundation. The Python implementation is an executable reference model. The intended next stages are:

1. prove stronger parser/encoder round-trip theorems in Lean;
2. formalize canonicalization and semantic equivalence;
3. define typed ontology and provenance constraints;
4. add capability negotiation and extension namespaces;
5. connect QET-ML to an agent transport without coupling its semantics to a single vendor.

The project uses Lean 4.34.0 and Mathlib 4.34.0.
