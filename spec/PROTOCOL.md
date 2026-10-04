# QET-ML protocol

## Canonical wire form

The initial compact form is:

※v<version>/s<sender>/r<recipient>|<body>|◎◉

The body is the canonical QET expression grammar.

## Stable numeric vocabulary

Operator IDs:
20 = OP
21 = SR
22 = FL

Modifier IDs:
30 = evolution
31 = creativity
32 = time
33 = risk
34 = ethics
35 = chaos

Legacy glyph aliases remain a compatibility surface; numeric identifiers are the machine-stable layer.

## Interoperability

QET-ML keeps the language data model separate from discovery, authorization, task lifecycle, transport binding, and monitoring. This makes it suitable for embedding into agent-to-agent systems without coupling the language to one vendor.

## Canonicalization

Structured semantic objects must be serialized deterministically before hashing or encryption: UTF-8, sorted object keys, compact separators, and an explicit protocol version.

## Integrity and confidentiality

A checksum is not encryption. Confidential transport uses AEAD. Routing metadata is authenticated as associated data so that changing sender/recipient/version invalidates the ciphertext.

Keys are external to the repository.
