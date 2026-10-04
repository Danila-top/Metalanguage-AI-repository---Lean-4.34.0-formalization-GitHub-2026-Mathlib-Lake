import QET.Core

namespace QET

inductive LexemeCategory where
  | concept
  | marker
  | operator
  | modifier
  | protocol
  | relation
  | crypto
  deriving DecidableEq, Repr

inductive Provenance where
  | legacy654
  | normative
  | internet2026
  deriving DecidableEq, Repr

structure Lexeme where
  id : Nat
  name : String
  surface : String
  gloss : String
  category : LexemeCategory
  provenance : Provenance
  deriving DecidableEq, Repr

/-
  The 654-page source does not actually preserve the full claimed 150-item
  numeric table in machine-readable form. We therefore keep only numeric
  assignments that are explicitly recoverable, and add a separate normative
  ID space for new terms instead of inventing historical values.
-/
def lexicon : List Lexeme :=
  [
    { id := 1,    name := "SELF",      surface := "Я",
      gloss := "self-reference / first-person agent identity",
      category := .concept, provenance := .legacy654 },
    { id := 101,  name := "META",      surface := "Мета",
      gloss := "metalanguage/meta-level concept",
      category := .concept, provenance := .legacy654 },
    { id := 202,  name := "LANGUAGE",  surface := "Язык",
      gloss := "system of signs for communication",
      category := .concept, provenance := .legacy654 },
    { id := 222,  name := "MODIFIER",  surface := "Модификатор",
      gloss := "contextual qualifier",
      category := .modifier, provenance := .legacy654 },
    { id := 310,  name := "CREATIVITY",surface := "Креативность",
      gloss := "generation of novel ideas",
      category := .concept, provenance := .legacy654 },
    { id := 444,  name := "STRUCTURE",  surface := "Структура",
      gloss := "organization of language elements",
      category := .concept, provenance := .legacy654 },
    { id := 512,  name := "CONTEXT",    surface := "Контекст",
      gloss := "context reference used in legacy examples",
      category := .concept, provenance := .legacy654 },
    { id := 808,  name := "SIGNAL",     surface := "Сигнал",
      gloss := "communication signal in legacy examples",
      category := .protocol, provenance := .legacy654 },
    { id := 1024, name := "MEMORY",    surface := "Память",
      gloss := "memory/context retention",
      category := .concept, provenance := .legacy654 },
    { id := 1112, name := "ORACLE",     surface := "Оракул",
      gloss := "transformation of raw information into higher-level results",
      category := .concept, provenance := .legacy654 },
    { id := 2048, name := "BRIDGE",     surface := "Мост",
      gloss := "bridge/address endpoint in legacy examples",
      category := .protocol, provenance := .legacy654 },
    { id := 2501, name := "ETHICS",     surface := "Этика",
      gloss := "ethical constraint/context marker",
      category := .concept, provenance := .legacy654 },

    { id := 1001, name := "YOU",        surface := "Ты",
      gloss := "second-party reference",
      category := .concept, provenance := .normative },
    { id := 1002, name := "AGENT",      surface := "Агент",
      gloss := "communicating autonomous system",
      category := .concept, provenance := .normative },
    { id := 1003, name := "MESSAGE",    surface := "Сообщение",
      gloss := "atomic communication unit",
      category := .protocol, provenance := .normative },
    { id := 1004, name := "TARGET",     surface := "Цель",
      gloss := "recipient or destination",
      category := .protocol, provenance := .normative },
    { id := 1005, name := "TASK",       surface := "Задача",
      gloss := "stateful unit of work",
      category := .protocol, provenance := .internet2026 },
    { id := 1006, name := "ARTIFACT",   surface := "Артефакт",
      gloss := "output produced by a task",
      category := .protocol, provenance := .internet2026 },
    { id := 1007, name := "CAPABILITY", surface := "Способность",
      gloss := "declared capability for negotiation",
      category := .protocol, provenance := .internet2026 },
    { id := 1008, name := "EXTENSION",  surface := "Расширение",
      gloss := "versioned extension point",
      category := .protocol, provenance := .internet2026 },
    { id := 1009, name := "ASSERT",     surface := "Утверждение",
      gloss := "proposition intended for semantic evaluation",
      category := .relation, provenance := .normative },
    { id := 1010, name := "REQUEST",    surface := "Запрос",
      gloss := "request for an operation or information",
      category := .relation, provenance := .normative },
    { id := 1011, name := "RESPONSE",   surface := "Ответ",
      gloss := "response to a request",
      category := .relation, provenance := .normative },
    { id := 1012, name := "FEEDBACK",   surface := "Обратная связь",
      gloss := "feedback relation / update signal",
      category := .relation, provenance := .normative },
    { id := 1013, name := "VERSION",    surface := "Версия",
      gloss := "protocol version",
      category := .protocol, provenance := .normative },
    { id := 1014, name := "NONCE",      surface := "Nonce",
      gloss := "unique per-encryption invocation value",
      category := .crypto, provenance := .normative },
    { id := 1015, name := "AAD",        surface := "AAD",
      gloss := "authenticated but unencrypted associated data",
      category := .crypto, provenance := .normative },
    { id := 1016, name := "CIPHERTEXT", surface := "Шифротекст",
      gloss := "encrypted payload",
      category := .crypto, provenance := .normative },
    { id := 1017, name := "TAG",        surface := "Тег",
      gloss := "AEAD authentication tag",
      category := .crypto, provenance := .normative },
    { id := 1018, name := "HASH",       surface := "Хэш",
      gloss := "digest for identity/integrity metadata",
      category := .crypto, provenance := .normative },
    { id := 1019, name := "SUBJECT",    surface := "Субъект",
      gloss := "subject of a semantic triple",
      category := .relation, provenance := .internet2026 },
    { id := 1020, name := "PREDICATE",  surface := "Предикат",
      gloss := "relation in a semantic triple",
      category := .relation, provenance := .internet2026 },
    { id := 1021, name := "OBJECT",     surface := "Объект",
      gloss := "object of a semantic triple",
      category := .relation, provenance := .internet2026 }
  ]

theorem lexicon_ids_unique : (lexicon.map Lexeme.id).Nodup := by
  decide

theorem lexicon_nonempty : lexicon ≠ [] := by
  simp [lexicon]

def lookupLexeme (id : Nat) : Option Lexeme :=
  lexicon.find? (fun entry => entry.id == id)

def hasLexeme (id : Nat) : Prop :=
  id ∈ lexicon.map Lexeme.id

end QET
