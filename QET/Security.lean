namespace QET

inductive AeadAlgorithm where
  | aes256gcm
  | chacha20poly1305
  deriving DecidableEq, Repr

def AeadAlgorithm.keyBytes : AeadAlgorithm → Nat
  | .aes256gcm => 32
  | .chacha20poly1305 => 32

def AeadAlgorithm.nonceBytes : AeadAlgorithm → Nat
  | .aes256gcm => 12
  | .chacha20poly1305 => 12

structure CryptoEnvelope where
  algorithm : AeadAlgorithm
  version : Nat
  sender : Nat
  recipient : Nat
  nonce : List UInt8
  associatedData : List UInt8
  ciphertext : List UInt8
  tag : List UInt8

def CryptoEnvelope.WellFormed (envelope : CryptoEnvelope) : Prop :=
  envelope.version > 0 ∧
  envelope.nonce.length = envelope.algorithm.nonceBytes ∧
  envelope.tag.length = 16

def authenticatedRoutingData (version sender recipient : Nat) : List UInt8 :=
  (s!"qet-ml/{version}|s{sender}|r{recipient}").toUTF8

theorem aes_nonce_size :
    AeadAlgorithm.aes256gcm.nonceBytes = 12 := by rfl

theorem chacha_nonce_size :
    AeadAlgorithm.chacha20poly1305.nonceBytes = 12 := by rfl

end QET
