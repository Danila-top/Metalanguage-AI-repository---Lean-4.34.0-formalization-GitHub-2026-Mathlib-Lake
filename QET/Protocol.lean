import QET.Core

namespace QET

/-
  Protocol envelope inspired by modern agent interoperability patterns,
  while remaining independent of A2A itself.
-/

structure Part where
  body : Expr
  mediaType : String := "application/qet"
  deriving DecidableEq, Repr

structure Envelope where
  messageId : String
  contextId : Option String
  taskId : Option String
  sender : Nat
  recipient : Nat
  extensions : List String
  parts : List Part
  deriving DecidableEq, Repr

def Envelope.WellFormed (envelope : Envelope) : Prop :=
  envelope.messageId ≠ "" ∧
  envelope.parts ≠ [] ∧
  ∀ part ∈ envelope.parts, part.body.WellFormed

theorem part_wellFormed (body : Expr) (h : body.WellFormed) :
    (Part.mk body).body.WellFormed := h

theorem envelope_wellFormed
    (envelope : Envelope)
    (h_id : envelope.messageId ≠ "")
    (h_parts : envelope.parts ≠ [])
    (h_bodies : ∀ part ∈ envelope.parts, part.body.WellFormed) :
    envelope.WellFormed := by
  exact ⟨h_id, h_parts, h_bodies⟩

end QET
