namespace QET

structure Extension where
  namespace : String
  name : String
  major : Nat
  minor : Nat
  patch : Nat
  deriving DecidableEq, Repr

def Extension.identifier (extension : Extension) : String :=
  extension.namespace ++ ":" ++ extension.name

def Extension.WellFormed (extension : Extension) : Prop :=
  extension.namespace ≠ "" ∧
  extension.name ≠ ""

structure ExtensionRegistry where
  entries : List Extension
  uniqueIdentifiers : (entries.map Extension.identifier).Nodup

def ExtensionRegistry.WellFormed (registry : ExtensionRegistry) : Prop :=
  ∀ extension ∈ registry.entries, extension.WellFormed

def emptyRegistry : ExtensionRegistry :=
  { entries := []
    uniqueIdentifiers := by simp }

theorem emptyRegistry_wellFormed :
    emptyRegistry.WellFormed := by
  simp [emptyRegistry, ExtensionRegistry.WellFormed]

end QET
