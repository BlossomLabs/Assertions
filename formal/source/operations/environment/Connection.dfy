include "Control.generated.dfy"
module OperationsEnvironmentConnection {
  import M = OperationsEnvironmentModel
  import S = OperationsEnvironmentSource
  lemma timestamp(e: M.Env)
    requires M.Valid(e)
    ensures S.timestamp(e) == e.timestamp
  { }
  lemma blockNumber(e: M.Env)
    requires M.Valid(e)
    ensures S.blockNumber(e) == e.blockNumber
  { }
  lemma chainId(e: M.Env)
    requires M.Valid(e)
    ensures S.chainId(e) == e.chainId
  { }
  lemma baseFee(e: M.Env)
    requires M.Valid(e)
    ensures S.baseFee(e) == e.baseFee
  { }
  lemma prevRandao(e: M.Env)
    requires M.Valid(e)
    ensures S.prevRandao(e) == e.prevRandao
  { }
  lemma coinbase(e: M.Env)
    requires M.Valid(e)
    ensures S.coinbase(e) == e.coinbase
  { }
  lemma gasLimit(e: M.Env)
    requires M.Valid(e)
    ensures S.gasLimit(e) == e.gasLimit
  { }
  lemma blobBaseFee(e: M.Env)
    requires M.Valid(e)
    ensures S.blobBaseFee(e) == e.blobBaseFee
  { }
  lemma origin(e: M.Env)
    requires M.Valid(e)
    ensures S.origin(e) == e.origin
  { }
  lemma gasPrice(e: M.Env)
    requires M.Valid(e)
    ensures S.gasPrice(e) == e.gasPrice
  { }
  lemma balance(e: M.Env,a: int)
    requires M.Valid(e) && M.Word(a)
    ensures S.balance(e,a) == (if a in e.balances then e.balances[a] else 0)
  { }
  lemma codeHash(e: M.Env,a: int)
    requires M.Valid(e) && M.Word(a)
    ensures S.codeHash(e,a) == (if a in e.codeHashes then e.codeHashes[a] else 0)
  { }
  lemma code(e: M.Env,a: int)
    requires M.Valid(e) && M.Word(a)
    ensures S.code(e,a) == (if a in e.codes then e.codes[a] else [])
  { }
  lemma blockHash(e: M.Env,n: int)
    requires M.Valid(e) && M.Word(n)
    ensures S.blockHash(e,n) == (if n < e.blockNumber && e.blockNumber-n <= 256 && n in e.blockHashes then e.blockHashes[n] else 0)
    ensures n >= e.blockNumber || n+256 < e.blockNumber ==> S.blockHash(e,n) == 0
  { }
  lemma blobHash(e: M.Env,n: int)
    requires M.Valid(e) && M.Word(n)
    ensures S.blobHash(e,n) == (if n < |e.blobs| then e.blobs[n] else 0)
    ensures n >= |e.blobs| ==> S.blobHash(e,n) == 0
  { }
}
