// SPDX-License-Identifier: MIT
include "DivUNonzero.generated.dfy"
include "DivUZero.generated.dfy"
include "ModUNonzero.generated.dfy"
include "ModUZero.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
include "rejections/DivUArgs.generated.dfy"
include "rejections/ModUArgs.generated.dfy"
module OperationsUnsignedDivisionConnection {
  import opened OperationsUnsignedDivisionMachine
  import DN = OperationsUnsignedDivisionDivUNonzero
  import DZ = OperationsUnsignedDivisionDivUZero
  import MN = OperationsUnsignedDivisionModUNonzero
  import MZ = OperationsUnsignedDivisionModUZero
  import DA = OperationsUnsignedDivisionRawDivUArgs
  import MA = OperationsUnsignedDivisionRawModUArgs
  import Nonzero = OperationsUnsignedDivisionRawNonzero
  import Short = OperationsUnsignedDivisionRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36)) }
  predicate Assigned(selector: Word) { selector in {0xa391c15b,0xf43f523a} }
  function Expected(selector: Word,a: Word,b: Word): Word {
    if selector == 0xa391c15b then Quotient(a,b) else Remainder(a,b)
  }
  opaque predicate Matches(code: seq<Byte>) { DN.Matches(code) && DZ.Matches(code) && MN.Matches(code) && MZ.Matches(code) && DA.Matches(code) && MA.Matches(code) && Nonzero.Matches(code) && Short.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 && DataWord(data,36) == 0 ==> state == Reverted(Panic(18))
    ensures value == 0 && |data| >= 68 && DataWord(data,36) > 0 ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)),32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); var b := DataWord(data,36);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36);
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,b); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,b); }
    else if size < 68 {
      if Selector(word) == 0xa391c15b { state := DA.Run(code,value,size,word,a,b); }
      else { state := MA.Run(code,value,size,word,a,b); }
    }
    else if Selector(word) == 0xa391c15b {
      if b == 0 { state := DZ.Run(code,value,size,word,a,b); }
      else { state := DN.Run(code,value,size,word,a,b); }
    }
    else {
      if b == 0 { state := MZ.Run(code,value,size,word,a,b); }
      else { state := MN.Run(code,value,size,word,a,b); }
    }
  }
}
