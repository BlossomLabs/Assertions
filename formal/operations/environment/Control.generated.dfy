include "Model.dfy"
module OperationsEnvironmentSource {
  import M = OperationsEnvironmentModel
  function balance(e: M.Env, a: int): int
    requires M.Valid(e) && M.Word(a)
  { M.Balance(e,a) }

  function codeHash(e: M.Env, a: int): int
    requires M.Valid(e) && M.Word(a)
  { M.CodeHash(e,a) }

  function timestamp(e: M.Env): int
    requires M.Valid(e)
  { e.timestamp }

  function blockNumber(e: M.Env): int
    requires M.Valid(e)
  { e.blockNumber }

  function chainId(e: M.Env): int
    requires M.Valid(e)
  { e.chainId }

  function baseFee(e: M.Env): int
    requires M.Valid(e)
  { e.baseFee }

  function prevRandao(e: M.Env): int
    requires M.Valid(e)
  { e.prevRandao }

  function coinbase(e: M.Env): int
    requires M.Valid(e)
  { e.coinbase }

  function gasLimit(e: M.Env): int
    requires M.Valid(e)
  { e.gasLimit }

  function blobBaseFee(e: M.Env): int
    requires M.Valid(e)
  { e.blobBaseFee }

  function blockHash(e: M.Env, a: int): int
    requires M.Valid(e) && M.Word(a)
  { M.BlockHash(e,a) }

  function origin(e: M.Env): int
    requires M.Valid(e)
  { e.origin }

  function gasPrice(e: M.Env): int
    requires M.Valid(e)
  { e.gasPrice }

  function blobHash(e: M.Env, a: int): int
    requires M.Valid(e) && M.Word(a)
  { M.BlobHash(e,a) }

  function code(e: M.Env, a: int): seq<bv8>
    requires M.Valid(e) && M.Word(a)
  { M.Code(e,a) }
}
