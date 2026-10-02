// SPDX-License-Identifier: MIT
include "AddUOk.generated.dfy"
include "AddUOverflow.generated.dfy"
include "SubUOk.generated.dfy"
include "SubUOverflow.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
include "rejections/AddUArgs.generated.dfy"
include "rejections/SubUArgs.generated.dfy"
module OperationsUnsignedArithmeticConnection {
  import opened OperationsUnsignedArithmeticMachine
  import DN = OperationsUnsignedArithmeticAddUOk
  import DZ = OperationsUnsignedArithmeticAddUOverflow
  import MN = OperationsUnsignedArithmeticSubUOk
  import MZ = OperationsUnsignedArithmeticSubUOverflow
  import DA = OperationsUnsignedArithmeticRawAddUArgs
  import MA = OperationsUnsignedArithmeticRawSubUArgs
  import Nonzero = OperationsUnsignedArithmeticRawNonzero
  import Short = OperationsUnsignedArithmeticRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36)) }
  predicate Assigned(selector: Word) { selector in {0x771602f7,0xb67d77c5} }
  function Expected(selector: Word,a: Word,b: Word): nat {
    if selector == 0x771602f7 then a+b else if a>=b then a-b else 0
  }
  predicate Overflow(selector: Word,a: Word,b: Word) {
    if selector == 0x771602f7 then a+b >= Modulus() else a < b
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
      if Selector(word) == 0x771602f7 { state := DA.Run(code,value,size,word,a,b); }
      else { state := MA.Run(code,value,size,word,a,b); }
    }
    else if Selector(word) == 0x771602f7 {
      if a+b >= Modulus() { state := DZ.Run(code,value,size,word,a,b); }
      else { CheckedSum(a,b); state := DN.Run(code,value,size,word,a,b); }
    }
    else {
      if a < b { state := MZ.Run(code,value,size,word,a,b); }
      else { CheckedDifference(a,b); state := MN.Run(code,value,size,word,a,b); }
    }
  }
}
