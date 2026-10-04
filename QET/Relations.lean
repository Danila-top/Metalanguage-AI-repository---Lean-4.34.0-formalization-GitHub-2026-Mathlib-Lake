import QET.Core

namespace QET

structure Evidence where
  source : String
  tier : Nat
  deriving DecidableEq, Repr

structure Assertion where
  subject : Nat
  predicate : Nat
  object : Nat
  evidence : List Evidence
  deriving DecidableEq, Repr

def Assertion.WellFormed (a : Assertion) : Prop :=
  a.predicate > 0 ∧
  ∀ e ∈ a.evidence, e.source ≠ ""

structure KnowledgeGraph where
  assertions : List Assertion
  deriving DecidableEq, Repr

def KnowledgeGraph.WellFormed (g : KnowledgeGraph) : Prop :=
  ∀ a ∈ g.assertions, a.WellFormed

def assertion (subject predicate object : Nat) : Assertion :=
  { subject := subject
    predicate := predicate
    object := object
    evidence := [] }

theorem assertion_wellFormed (subject predicate object : Nat)
    (h_predicate : predicate > 0) :
    (assertion subject predicate object).WellFormed := by
  simp [assertion, Assertion.WellFormed, h_predicate]

theorem empty_graph_wellFormed :
    (KnowledgeGraph.mk []).WellFormed := by
  simp [KnowledgeGraph.WellFormed]

end QET
