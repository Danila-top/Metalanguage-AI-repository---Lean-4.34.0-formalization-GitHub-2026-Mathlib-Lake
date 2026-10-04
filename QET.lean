import QET.Core
import QET.Grammar
import QET.Lexicon
import QET.Protocol
import QET.Semantics

namespace QET

theorem smoke :
    (lookupLexeme 1).isSome := by
  simp [lookupLexeme, lexicon]

end QET
