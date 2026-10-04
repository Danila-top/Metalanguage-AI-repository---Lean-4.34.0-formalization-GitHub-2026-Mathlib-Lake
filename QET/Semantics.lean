import QET.Core

namespace QET

/-
  A small compositional semantic algebra.

  The important design decision is that syntax and meaning are different
  layers. An Expr is syntax. Meaning is an explicit mathematical object.
  This prevents the specification from silently delegating semantics to an
  unspecified neural network.
-/

inductive SemanticValue where
  | concept (id : Nat)
  | integer (value : Int)
  | text (value : String)
  | boolean (value : Bool)
  | operation (operator : Operator) (args : List SemanticValue)
  | modified (modifier : Modifier) (value : SemanticValue)
  | sequence (items : List SemanticValue)
  deriving DecidableEq, Repr

def interpretAtom : Atom → SemanticValue
  | .concept id => .concept id
  | .integer value => .integer value
  | .text value => .text value
  | .boolean value => .boolean value

def interpret : Expr → SemanticValue
  | .atom atom => interpretAtom atom
  | .apply operator args =>
      .operation operator (args.map interpret)
  | .modify modifier body =>
      .modified modifier (interpret body)
  | .sequence items =>
      .sequence (items.map interpret)

theorem interpret_deterministic (expr : Expr) :
    interpret expr = interpret expr := by
  rfl

theorem interpret_atom_injective {a b : Atom}
    (h : interpretAtom a = interpretAtom b) : a = b := by
  cases a <;> cases b <;> simp [interpretAtom] at h ⊢

def SemanticTriple (α : Type) where
  subject : α
  predicate : α
  object : α

/-
  RDF-inspired triple representation is intentionally kept generic.
  It gives the language a relational semantic layer without forcing one
  ontology or one vendor's vocabulary. The internet research notes in the
  repository explain why this mirrors the shape of RDF's abstract data model.
-/
def ConceptTriple := SemanticTriple Nat

def triple (s p o : Nat) : ConceptTriple :=
  { subject := s, predicate := p, object := o }

end QET
