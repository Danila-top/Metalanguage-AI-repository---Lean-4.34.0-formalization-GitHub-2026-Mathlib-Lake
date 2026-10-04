import QET.Core

namespace QET

/-
  The normative grammar is represented by the inductive Expr type in Core.lean.
  This file defines a canonical tokenization of that grammar.

  Legacy markers retained for compatibility:
    ※ = INIT
    ◎ = CONFIRM
    ◉ = CLOSE
    OP = operation
    SR = self-reference
    FL = feedback
    @E/@C/@T/@R = evolution/creativity/time/risk
-/

inductive Token where
  | init
  | confirm
  | close
  | version (value : Nat)
  | sender (value : Nat)
  | recipient (value : Nat)
  | openGroup
  | closeGroup
  | op (value : Operator)
  | modifier (value : Modifier)
  | atom (value : Atom)
  deriving DecidableEq, Repr

def encodeAtom : Atom → Token
  | .concept id => .atom (.concept id)
  | .integer value => .atom (.integer value)
  | .text value => .atom (.text value)
  | .boolean value => .atom (.boolean value)

def encodeExpr : Expr → List Token
  | .atom atom =>
      [.atom (encodeAtom atom |> fun t =>
        match t with
        | .atom a => a
        | _ => atom)]
  | .apply operator args =>
      [.op operator, .openGroup] ++ args.flatMap encodeExpr ++ [.closeGroup]
  | .modify modifier body =>
      [.modifier modifier, .openGroup] ++ encodeExpr body ++ [.closeGroup]
  | .sequence items =>
      [.openGroup] ++ items.flatMap encodeExpr ++ [.closeGroup]

def encodeMessage (message : Message) : List Token :=
  [.init, .version message.version, .sender message.sender,
   .recipient message.recipient] ++ encodeExpr message.body ++
  [.confirm, .close]

def markerSurface : Marker → String
  | .init => "※"
  | .confirm => "◎"
  | .close => "◉"

def operatorSurface : Operator → String
  | .op => "OP"
  | .sr => "SR"
  | .fl => "FL"

def modifierSurface : Modifier → String
  | .evolution => "@E"
  | .creativity => "@C"
  | .time => "@T"
  | .risk => "@R"
  | .ethics => "@Y"
  | .chaos => "@CH"

def tokenSurface : Token → String
  | .init => "※"
  | .confirm => "◎"
  | .close => "◉"
  | .version n => s!"v{n}"
  | .sender n => s!"s{n}"
  | .recipient n => s!"r{n}"
  | .openGroup => "["
  | .closeGroup => "]"
  | .op op => operatorSurface op
  | .modifier modifier => modifierSurface modifier
  | .atom (.concept id) => s!"C{id}"
  | .atom (.integer value) => s!"N{value}"
  | .atom (.text value) => s!"T{value}"
  | .atom (.boolean value) => if value then "B1" else "B0"

def tokenStreamSurface (tokens : List Token) : List String :=
  tokens.map tokenSurface

def messageSurface (message : Message) : String :=
  String.intercalate " " (tokenStreamSurface (encodeMessage message))

theorem encodeMessage_starts_with_init (message : Message) :
    encodeMessage message |>.head? = some Token.init := by
  simp [encodeMessage]

theorem encodeMessage_ends_with_close (message : Message) :
    encodeMessage message |>.getLast? = some Token.close := by
  simp [encodeMessage]

end QET
