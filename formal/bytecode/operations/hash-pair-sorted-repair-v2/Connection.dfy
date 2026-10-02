// SPDX-License-Identifier: MIT
include "Keep.generated.dfy"
include "Swap.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
include "rejections/HashPairArgs.generated.dfy"
module OperationsHashPairSortedConnection {
  import opened OperationsHashPairSortedMachine
  import Keep = OperationsHashPairSortedKeep
  import Swap = OperationsHashPairSortedSwap
  import Args = OperationsHashPairSortedRawHashPairArgs
  import Nonzero = OperationsHashPairSortedRawNonzero
  import Short = OperationsHashPairSortedRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>,h: HashEngine): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36),h) }
  opaque predicate Matches(code: seq<Byte>) { Keep.Matches(code) && Swap.Matches(code) && Args.Matches(code) && Nonzero.Matches(code) && Short.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>,h: HashEngine) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Selector(DataWord(data,0)) == 0xc203edb3
    requires value == 0 && |data| >= 68 ==> HashDomain(h,DataWord(data,4),DataWord(data,36))
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 ==> state == Returned(Encode(h[SortedPair(DataWord(data,4),DataWord(data,36))],32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); var b := DataWord(data,36);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36);
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,b,h); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,b,h); }
    else if size < 68 { state := Args.Run(code,value,size,word,a,b,h); }
    else if a <= b { state := Keep.Run(code,value,size,word,a,b,h); }
    else { state := Swap.Run(code,value,size,word,a,b,h); }
  }
}
