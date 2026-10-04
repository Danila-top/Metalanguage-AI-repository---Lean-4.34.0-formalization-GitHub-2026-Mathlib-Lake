# AI-oriented semantic layer

The purpose of the language is not merely to compress natural-language text. An AI-to-AI metalanguage should expose information that ordinary prose often leaves implicit.

## Explicit dimensions

A QET-ML agent message can represent:

- who is communicating;
- who is the intended recipient;
- which context or task is active;
- whether the utterance is an assertion, request, response, feedback, proposal, acknowledgement, rejection, or cancellation;
- the structured content of the utterance;
- declared capabilities;
- provenance and evidence;
- optional cryptographic transport metadata.

These dimensions are represented by typed Lean structures instead of being inferred from punctuation.

## Speech acts

Natural language frequently makes an agent infer whether a sentence is a command, question, hypothesis, observation, acknowledgement, or correction.

QET-ML makes this state explicit through SpeechAct.

This is important for autonomous systems because an identical proposition can have different operational effects depending on its speech act.

## Intent versus semantics

Intent does not replace semantic content.

Intent = speech act + semantic expression + optional task reference.

An agent can therefore distinguish:

ASSERT(C202) from REQUEST(C202)

even when they contain the same concept.

## Context

The protocol envelope carries optional contextId and taskId. Context should be treated as an explicit addressable object, not as an unlimited implicit conversational state.

This makes replay, auditing, branching, and multi-agent coordination possible without changing the language grammar.

## Capabilities

Agents should advertise capabilities explicitly. A capability ID can be linked to a versioned extension or ontology.

Capability negotiation belongs to the protocol layer; capability meaning belongs to the ontology/lexicon layer.

## Provenance and evidence

Assertions can carry evidence records. The first implementation deliberately stores evidence as structured metadata rather than assigning arbitrary confidence numbers to every concept.

A future evidence model can distinguish observation, external source, derivation, consensus, and machine proof.

## Machine dialogue

The intended high-level dialogue is:

DISCOVER -> NEGOTIATE -> REQUEST -> WORK -> FEEDBACK -> RESPONSE -> COMPLETE

The state machine is intentionally separate from the expression grammar, so the language can be reused for simple messages and complex agent workflows.
