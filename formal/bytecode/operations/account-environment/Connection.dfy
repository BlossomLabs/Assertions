// SPDX-License-Identifier: MIT
include "Balance.generated.dfy"
include "CodeHash.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
include "rejections/BalanceArgs.generated.dfy"
include "rejections/CodeHashArgs.generated.dfy"
include "rejections/BalanceBadAddress.generated.dfy"
include "rejections/CodeHashBadAddress.generated.dfy"
module OperationsAccountEnvironmentConnection {
  import opened OperationsAccountEnvironmentMachine
  import B = OperationsAccountEnvironmentBalance
  import C = OperationsAccountEnvironmentCodeHash
  import BA = OperationsAccountEnvironmentRawBalanceArgs
  import CA = OperationsAccountEnvironmentRawCodeHashArgs
  import BD = OperationsAccountEnvironmentRawBalanceBadAddress
  import CD = OperationsAccountEnvironmentRawCodeHashBadAddress
  import Nonzero = OperationsAccountEnvironmentRawNonzero
  import Short = OperationsAccountEnvironmentRawShort
  import Mask = OperationsAccountMask
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>,world: World): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),world) }
  predicate Assigned(selector: Word) { selector in {0xe3d670d7,0x3dc44827} }
  function Expected(selector: Word,world: World,a: Word): Word {
    if selector == 0xe3d670d7 then Balance(world,a) else CodeHash(world,a)
  }
  opaque predicate Matches(code: seq<Byte>) { B.Matches(code) && C.Matches(code) && BA.Matches(code) && CA.Matches(code) && BD.Matches(code) && CD.Matches(code) && Nonzero.Matches(code) && Short.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>,world: World) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 36 || DataWord(data,4) >= Mask.Bound() ==> state == Reverted([])
    ensures value == 0 && |data| >= 36 && DataWord(data,4) < Mask.Bound() ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),world,DataWord(data,4)),32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); LoadProjection(data,0); LoadProjection(data,4);
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,world); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,world); }
    else if size < 36 {
      if Selector(word) == 0xe3d670d7 { state := BA.Run(code,value,size,word,a,world); }
      else { state := CA.Run(code,value,size,word,a,world); }
    }
    else if a >= Mask.Bound() {
      if Selector(word) == 0xe3d670d7 { state := BD.Run(code,value,size,word,a,world); }
      else { state := CD.Run(code,value,size,word,a,world); }
    }
    else if Selector(word) == 0xe3d670d7 { state := B.Run(code,value,size,word,a,world); }
    else { state := C.Run(code,value,size,word,a,world); }
  }
}
