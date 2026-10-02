module OperationsEnvironmentModel {
  const Mod: int := 0x10000000000000000000000000000000000000000000000000000000000000000
  datatype Env = Env(timestamp: int, blockNumber: int, chainId: int, baseFee: int, prevRandao: int, coinbase: int, gasLimit: int, blobBaseFee: int, origin: int, gasPrice: int, balances: map<int,int>, codeHashes: map<int,int>, codes: map<int,seq<bv8>>, blockHashes: map<int,int>, blobs: seq<int>)
  predicate Word(x: int) { 0 <= x < Mod }
  predicate Valid(e: Env) {
    Word(e.timestamp) && Word(e.blockNumber) && Word(e.chainId) && Word(e.baseFee) && Word(e.prevRandao) && Word(e.coinbase) && Word(e.gasLimit) && Word(e.blobBaseFee) && Word(e.origin) && Word(e.gasPrice) &&
    (forall a | a in e.balances :: Word(e.balances[a])) &&
    (forall a | a in e.codeHashes :: Word(e.codeHashes[a])) &&
    (forall n | n in e.blockHashes :: Word(e.blockHashes[n])) &&
    (forall i | 0 <= i < |e.blobs| :: Word(e.blobs[i]))
  }
  function Balance(e: Env,a: int): int { if a in e.balances then e.balances[a] else 0 }
  function CodeHash(e: Env,a: int): int { if a in e.codeHashes then e.codeHashes[a] else 0 }
  function Code(e: Env,a: int): seq<bv8> { if a in e.codes then e.codes[a] else [] }
  function BlockHash(e: Env,n: int): int { if n >= e.blockNumber || n + 256 < e.blockNumber then 0 else if n in e.blockHashes then e.blockHashes[n] else 0 }
  function BlobHash(e: Env,n: int): int { if 0 <= n < |e.blobs| then e.blobs[n] else 0 }
}
