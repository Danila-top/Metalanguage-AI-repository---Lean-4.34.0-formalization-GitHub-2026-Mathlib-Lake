import QET.Core
import QET.Grammar
import QET.Lexicon
import QET.Protocol
import QET.Semantics

namespace QET

def exampleMessage : Message :=
  { version := 1
    sender := 1
    recipient := 1002
    body :=
      .sequence
        [ .apply .op
            [ .atom (.concept 202)
            , .atom (.concept 2501) ]
        , .modify .ethics (.atom (.concept 101))
        , .apply .sr
            [ .atom (.concept 1)
            , .atom (.concept 1001) ]
        ] }

example : exampleMessage.WellFormed := by
  repeat' constructor <;> simp [exampleMessage, Expr.WellFormed]

example :
    (encodeMessage exampleMessage).head? = some Token.init := by
  exact encodeMessage_starts_with_init exampleMessage

example :
    (encodeMessage exampleMessage).getLast? = some Token.close := by
  exact encodeMessage_ends_with_close exampleMessage

#eval messageSurface exampleMessage
#eval lookupLexeme 2501

end QET
