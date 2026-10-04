import QET.Core

namespace QET

inductive ExprKind where
  | concept
  | integer
  | text
  | boolean
  | operation
  | modified
  | sequence
  deriving DecidableEq, Repr

def Expr.kind : Expr -> ExprKind
  | .atom (.concept _) => .concept
  | .atom (.integer _) => .integer
  | .atom (.text _) => .text
  | .atom (.boolean _) => .boolean
  | .apply _ _ => .operation
  | .modify _ _ => .modified
  | .sequence _ => .sequence

def Expr.depth : Expr -> Nat
  | .atom _ => 0
  | .apply _ args => 1 + (args.map Expr.depth).foldl max 0
  | .modify _ body => 1 + body.depth
  | .sequence items => 1 + (items.map Expr.depth).foldl max 0

theorem kind_is_total (expr : Expr) : ∃ k, expr.kind = k := by
  exact ⟨expr.kind, rfl⟩

theorem depth_nonnegative (expr : Expr) : 0 ≤ expr.depth := by
  exact Nat.zero_le _

theorem wellFormed_kind
    (expr : Expr) (h : expr.WellFormed) :
    match expr.kind with
    | .concept | .integer | .text | .boolean => True
    | .operation | .modified => True
    | .sequence => expr.depth > 0 := by
  cases expr with
  | atom atom =>
      cases atom <;> simp [Expr.kind, Expr.depth]
  | apply operator args =>
      simp [Expr.kind]
  | modify modifier body =>
      simp [Expr.kind, Expr.depth]
  | sequence items =>
      have hne : items ≠ [] := h.1
      simp [Expr.kind, Expr.depth]
      cases items with
      | nil => contradiction
      | cons head tail => simp

end QET
