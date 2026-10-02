// SPDX-License-Identifier: MIT
include "AbsUT.generated.dfy"
include "AbsUF.generated.dfy"
include "AbsST.generated.dfy"
include "AbsSF.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
include "rejections/AbsUArgs.generated.dfy"
include "rejections/AbsSArgs.generated.dfy"
module OperationsAbsoluteDifferenceConnection {
  import opened OperationsAbsoluteDifferenceMachine
  import UT = OperationsAbsoluteDifferenceAbsUT
  import UF = OperationsAbsoluteDifferenceAbsUF
  import ST = OperationsAbsoluteDifferenceAbsST
  import SF = OperationsAbsoluteDifferenceAbsSF
  import UA = OperationsAbsoluteDifferenceRawAbsUArgs
  import SA = OperationsAbsoluteDifferenceRawAbsSArgs
  import Nonzero = OperationsAbsoluteDifferenceRawNonzero
  import Short = OperationsAbsoluteDifferenceRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36)) }
  predicate Assigned(selector: Word) { selector in {0xa09ae0aa,0x1e4812c8} }
  function Expected(selector: Word,a: Word,b: Word): Word {
    if selector == 0xa09ae0aa then UnsignedDistance(a,b) else SignedDistance(a,b)
  }
  opaque predicate Matches(code: seq<Byte>) { UT.Matches(code) && UF.Matches(code) && ST.Matches(code) && SF.Matches(code) && UA.Matches(code) && SA.Matches(code) && Nonzero.Matches(code) && Short.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)),32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); var b := DataWord(data,36);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36);
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,b); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,b); }
    else if size < 68 {
      if Selector(word) == 0xa09ae0aa { state := UA.Run(code,value,size,word,a,b); }
      else { state := SA.Run(code,value,size,word,a,b); }
    }
    else if Selector(word) == 0xa09ae0aa {
      if a > b { state := UT.Run(code,value,size,word,a,b); }
      else { state := UF.Run(code,value,size,word,a,b); }
    }
    else {
      if Signed(a) > Signed(b) { state := ST.Run(code,value,size,word,a,b); }
      else { state := SF.Run(code,value,size,word,a,b); }
    }
  }
}
