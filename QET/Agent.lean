import QET.Core

namespace QET

inductive AgentRole where
  | sender
  | receiver
  | observer
  | coordinator
  deriving DecidableEq, Repr

inductive SpeechAct where
  | assert
  | request
  | response
  | feedback
  | propose
  | acknowledge
  | reject
  | cancel
  deriving DecidableEq, Repr

inductive TaskState where
  | created
  | working
  | inputRequired
  | completed
  | failed
  | cancelled
  deriving DecidableEq, Repr

structure Capability where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Intent where
  act : SpeechAct
  content : Expr
  taskId : Option String
  deriving DecidableEq, Repr

def Intent.WellFormed (intent : Intent) : Prop :=
  intent.content.WellFormed

structure AgentDescriptor where
  id : Nat
  roles : List AgentRole
  capabilities : List Capability
  deriving DecidableEq, Repr

def AgentDescriptor.WellFormed (agent : AgentDescriptor) : Prop :=
  ∀ capability ∈ agent.capabilities, capability.name ≠ ""

structure Task where
  id : String
  state : TaskState
  owner : Nat
  intent : Intent
  deriving DecidableEq, Repr

def Task.WellFormed (task : Task) : Prop :=
  task.id ≠ "" ∧
  task.intent.WellFormed

theorem intent_wellFormed
    (act : SpeechAct) (content : Expr) (taskId : Option String)
    (h : content.WellFormed) :
    (Intent.mk act content taskId).WellFormed := h

theorem task_wellFormed
    (task : Task)
    (h_id : task.id ≠ "")
    (h_intent : task.intent.WellFormed) :
    task.WellFormed := by
  exact ⟨h_id, h_intent⟩

end QET
