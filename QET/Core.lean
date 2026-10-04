namespace QET

/-
  QET-ML core abstract syntax.

  This file deliberately contains no model-specific assumptions.
  The syntax is the machine-checkable layer; interpretation is defined
  separately in Semantics.lean.
-/

inductive Marker where
  | init
  | confirm
  | close
  deriving DecidableEq, Repr

inductive Operator where
  | op
  | sr
  | fl
  deriving DecidableEq, Repr

inductive Modifier where
  | evolution
  | creativity
  | time
  | risk
  | ethics
  | chaos
  deriving DecidableEq, Repr

inductive Atom where
  | concept (id : Nat)
  | integer (value : Int)
  | text (value : String)
  | boolean (value : Bool)
  deriving DecidableEq, Repr

inductive Expr where
  | atom (value : Atom)
  | apply (operator : Operator) (args : List Expr)
  | modify (modifier : Modifier) (body : Expr)
  | sequence (items : List Expr)
  deriving DecidableEq, Repr

structure Message where
  version : Nat
  sender : Nat
  recipient : Nat
  body : Expr
  deriving DecidableEq, Repr

def Expr.WellFormed : Expr → Prop
  | .atom _ => True
  | .apply _ args => ∀ arg ∈ args, arg.WellFormed
  | .modify _ body => body.WellFormed
  | .sequence items => items ≠ [] ∧ ∀ item ∈ items, item.WellFormed

def Message.WellFormed (message : Message) : Prop :=
  message.version > 0 ∧ message.body.WellFormed

@[simp] theorem atom_wellFormed (a : Atom) :
    (Expr.atom a).WellFormed := by
  simp [Expr.WellFormed]

theorem apply_wellFormed
    (op : Operator) (args : List Expr)
    (h : ∀ arg ∈ args, arg.WellFormed) :
    (Expr.apply op args).WellFormed := by
  exact h

theorem modify_wellFormed
    (modifier : Modifier) (body : Expr)
    (h : body.WellFormed) :
    (Expr.modify modifier body).WellFormed := by
  exact h

theorem sequence_wellFormed
    (items : List Expr)
    (h_nonempty : items ≠ [])
    (h_items : ∀ item ∈ items, item.WellFormed) :
    (Expr.sequence items).WellFormed := by
  exact ⟨h_nonempty, h_items⟩

theorem message_wellFormed
    (message : Message)
    (h_version : message.version > 0)
    (h_body : message.body.WellFormed) :
    message.WellFormed := by
  exact ⟨h_version, h_body⟩

end QET
