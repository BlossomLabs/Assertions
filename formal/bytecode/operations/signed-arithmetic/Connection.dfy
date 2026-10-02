// SPDX-License-Identifier: MIT
include "AddSOk.generated.dfy"
include "AddSOverflow.generated.dfy"
include "SubSOk.generated.dfy"
include "SubSOverflow.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
include "rejections/AddSArgs.generated.dfy"
include "rejections/SubSArgs.generated.dfy"
module OperationsSignedArithmeticConnection {
  import opened OperationsSignedArithmeticMachine
  import DN = OperationsSignedArithmeticAddSOk
  import DZ = OperationsSignedArithmeticAddSOverflow
  import MN = OperationsSignedArithmeticSubSOk
  import MZ = OperationsSignedArithmeticSubSOverflow
  import DA = OperationsSignedArithmeticRawAddSArgs
  import MA = OperationsSignedArithmeticRawSubSArgs
  import Nonzero = OperationsSignedArithmeticRawNonzero
  import Short = OperationsSignedArithmeticRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36)) }
  predicate Assigned(selector: Word) { selector in {0xa5f3c23b,0xadefc37b} }
  function Expected(selector: Word,a: Word,b: Word): Word {
    (if selector == 0xa5f3c23b then Signed(a)+Signed(b) else Signed(a)-Signed(b))%Modulus()
  }
  predicate Overflow(selector: Word,a: Word,b: Word) {
    var total := if selector == 0xa5f3c23b then Signed(a)+Signed(b) else Signed(a)-Signed(b);
    total < -(Modulus() as int)/2 || total >= Modulus()/2
  }
  opaque predicate Matches(code: seq<Byte>) { DN.Matches(code) && DZ.Matches(code) && MN.Matches(code) && MZ.Matches(code) && DA.Matches(code) && MA.Matches(code) && Nonzero.Matches(code) && Short.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 && Overflow(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)) ==> state == Reverted(Panic(17))
    ensures value == 0 && |data| >= 68 && !Overflow(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)) ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)),32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); var b := DataWord(data,36);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36);
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,b); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,b); }
    else if size < 68 {
      if Selector(word) == 0xa5f3c23b { state := DA.Run(code,value,size,word,a,b); }
      else { state := MA.Run(code,value,size,word,a,b); }
    }
    else if Selector(word) == 0xa5f3c23b {
      if Overflow(0xa5f3c23b,a,b) { state := DZ.Run(code,value,size,word,a,b); }
      else { SignedWordSum(a,b); state := DN.Run(code,value,size,word,a,b); }
    }
    else {
      if Overflow(0xadefc37b,a,b) { state := MZ.Run(code,value,size,word,a,b); }
      else { SignedWordDifference(a,b); state := MN.Run(code,value,size,word,a,b); }
    }
  }
}
