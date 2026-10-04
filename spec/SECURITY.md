# QET-ML security model

The repository is public. Therefore the grammar and implementation are not secrets. The privacy boundary is the external key and the encrypted payload.

## Threat model

The encrypted transport aims to provide confidentiality and integrity against an untrusted transport. Application code must separately enforce authentication, authorization, replay resistance, key lifecycle, and endpoint policy.

## AEAD

The reference codec supports AES-256-GCM and ChaCha20-Poly1305 with a 256-bit key and a fresh 96-bit nonce per encryption invocation. The version and routing identifiers are authenticated as associated data.

Do not invent ad-hoc "secret syntax" as a substitute for cryptography.

## Password-derived keys

Passwords should not be used directly as AEAD keys. A standards-based password KDF with a unique salt and adequate work factor is required when passwords are the source of key material.

## Group messaging

A future group-agent layer can study MLS-style key establishment instead of inventing custom group key rotation.

## Scope

QET-ML is an interoperability research protocol. Encryption is for privacy and integrity of authorized traffic; it is not intended to bypass authentication, moderation, safety controls, or monitoring.
