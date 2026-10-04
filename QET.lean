import QET.Core
import QET.Grammar
import QET.Lexicon
import QET.Protocol
import QET.Semantics
import QET.Typing
import QET.Relations
import QET.Extensions
import QET.Security

namespace QET

theorem smoke :
    (lookupLexeme 1).isSome := by
  simp [lookupLexeme, lexicon]

end QET
