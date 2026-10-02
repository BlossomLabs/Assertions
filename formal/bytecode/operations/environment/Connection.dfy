// SPDX-License-Identifier: MIT
include "BaseFee.generated.dfy"
include "BlobBaseFee.generated.dfy"
include "BlockNumber.generated.dfy"
include "ChainId.generated.dfy"
include "GasLimit.generated.dfy"
include "GasPrice.generated.dfy"
include "PrevRandao.generated.dfy"
include "Timestamp.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"

module OperationsEnvironmentConnection {
  import opened OperationsEnvironmentMachine
  import BaseFee = OperationsEnvironmentBaseFee
  import BlobBaseFee = OperationsEnvironmentBlobBaseFee
  import BlockNumber = OperationsEnvironmentBlockNumber
  import ChainId = OperationsEnvironmentChainId
  import GasLimit = OperationsEnvironmentGasLimit
  import GasPrice = OperationsEnvironmentGasPrice
  import PrevRandao = OperationsEnvironmentPrevRandao
  import Timestamp = OperationsEnvironmentTimestamp
  import N = OperationsEnvironmentRawNonzero
  import S = OperationsEnvironmentRawShort
  function DataWord(data: seq<Byte>): Word { Load(data,0) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>, destinations: set<nat>, state: State,
                   value: Word, data: seq<Byte>, world: World): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data),world) }
  predicate Assigned(selector: Word) { selector in {1861377082,4162871616,1474851303,2592736658,4135589559,4262935447,4251883716,3087497194} }
  function Expected(selector: Word, world: World): Word {
    if selector == 1861377082 then world.baseFee
    else if selector == 4162871616 then world.blobBaseFee
    else if selector == 1474851303 then world.blockNumber
    else if selector == 2592736658 then world.chainId
    else if selector == 4135589559 then world.gasLimit
    else if selector == 4262935447 then world.gasPrice
    else if selector == 4251883716 then world.prevRandao
    else if selector == 3087497194 then world.timestamp
    else 0
  }
  opaque predicate Matches(code: seq<Byte>) { BaseFee.Matches(code) && BlobBaseFee.Matches(code) && BlockNumber.Matches(code) && ChainId.Matches(code) && GasLimit.Matches(code) && GasPrice.Matches(code) && PrevRandao.Matches(code) && Timestamp.Matches(code) && N.Matches(code) && S.Matches(code) }
  ghost method Run(code: seq<Byte>, value: Word, data: seq<Byte>, world: World) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data)))
    ensures value != 0 || |data| < 4 ==> state == Reverted([])
    ensures value == 0 && |data| >= 4 ==> state == Returned(Encode(Expected(Selector(DataWord(data)),world),32))
  {
    reveal Matches();
    var size := |data| as Word;
    var word := DataWord(data);
    LoadProjection(data,0);
    if value != 0 { state := N.Run(code,value,size,word,world); }
    else if size < 4 { state := S.Run(code,value,size,word,world); }
    else if Selector(word) == 1861377082 { state := BaseFee.Run(code,value,size,word,world); }
    else if Selector(word) == 4162871616 { state := BlobBaseFee.Run(code,value,size,word,world); }
    else if Selector(word) == 1474851303 { state := BlockNumber.Run(code,value,size,word,world); }
    else if Selector(word) == 2592736658 { state := ChainId.Run(code,value,size,word,world); }
    else if Selector(word) == 4135589559 { state := GasLimit.Run(code,value,size,word,world); }
    else if Selector(word) == 4262935447 { state := GasPrice.Run(code,value,size,word,world); }
    else if Selector(word) == 4251883716 { state := PrevRandao.Run(code,value,size,word,world); }
    else if Selector(word) == 3087497194 { state := Timestamp.Run(code,value,size,word,world); }
    else { assert false; }
  }
}
