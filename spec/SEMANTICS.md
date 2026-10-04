# QET-ML semantic model

## Layer separation

QET-ML separates lexical identity, syntax, semantics, and transport security. The normative meaning is the explicit semantic object, not an unstated interpretation inside an LLM.

## Compositional denotation

Atoms denote concept IDs, integers, text, or Booleans.

Operations denote an operator applied to a list of denotations:

OP[e1,...,en] -> operation(OP,[denotation(e1),...,denotation(en)])

Modifiers denote a qualifier applied to one denotation:

M[e] -> modified(M,denotation(e))

Sequences denote an ordered list of denotations.

This gives a deterministic syntax-to-semantics function and leaves domain meaning open to an explicit ontology.

## Relational semantics

A minimal subject-predicate-object representation is available as SemanticTriple. This is intentionally generic and can later host typed relations, provenance, evidence, temporal validity, contradiction sets, and entailment rules.

## Context and identity

Sender and recipient are explicit protocol fields. Context and task identifiers belong to the protocol envelope rather than to the lexical meaning of a word.

## Extensions

Extensions are versioned and namespaced. They may add terms, operators, modifiers, semantic relations, or transport metadata, but must not silently redefine an existing numeric identifier.

## Source-derived layer

The 654-page source contributes the symbolic markers ※ ◎ ◉, OP/SR/FL operators, modifier families, numeric concepts, self-reference, feedback, dictionary extension, and integrity concepts.

Historical or speculative material from the source is not promoted into normative semantics merely because it appears in the corpus. Missing numeric dictionary entries are not fabricated.
