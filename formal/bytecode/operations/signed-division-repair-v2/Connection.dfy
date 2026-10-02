// SPDX-License-Identifier: MIT
include "DivSNonzero.generated.dfy"
include "DivSZero.generated.dfy"
include "DivSOverflow.generated.dfy"
include "ModSNonzero.generated.dfy"
include "ModSZero.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
include "rejections/DivSArgs.generated.dfy"
include "rejections/ModSArgs.generated.dfy"
module OperationsSignedDivisionConnection {
  import opened OperationsSignedDivisionMachine
  import DN = OperationsSignedDivisionDivSNonzero
  import DO = OperationsSignedDivisionDivSOverflow
  import DZ = OperationsSignedDivisionDivSZero
  import MN = OperationsSignedDivisionModSNonzero
  import MZ = OperationsSignedDivisionModSZero
  import DA = OperationsSignedDivisionRawDivSArgs
  import MA = OperationsSignedDivisionRawModSArgs
  import Nonzero = OperationsSignedDivisionRawNonzero
  import Short = OperationsSignedDivisionRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36)) }
  predicate Assigned(selector: Word) { selector in {0x43509138,0x24e28928} }
  function Expected(selector: Word,a: Word,b: Word): Word {
    if selector == 0x43509138 then SignedQuotient(a,b) else SignedRemainder(a,b)
  }
  predicate Overflow(selector: Word,a: Word,b: Word) { selector == 0x43509138 && a == Modulus()/2 && b == Modulus()-1 }
  opaque predicate Matches(code: seq<Byte>) { DN.Matches(code) && DO.Matches(code) && DZ.Matches(code) && MN.Matches(code) && MZ.Matches(code) && DA.Matches(code) && MA.Matches(code) && Nonzero.Matches(code) && Short.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 && DataWord(data,36) == 0 ==> state == Reverted(Panic(18))
    ensures value == 0 && |data| >= 68 && Overflow(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)) ==> state == Reverted(Panic(17))
    ensures value == 0 && |data| >= 68 && DataWord(data,36) > 0 && !Overflow(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)) ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)),32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); var b := DataWord(data,36);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36);
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,b); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,b); }
    else if size < 68 {
      if Selector(word) == 0x43509138 { state := DA.Run(code,value,size,word,a,b); }
      else { state := MA.Run(code,value,size,word,a,b); }
    }
    else if Selector(word) == 0x43509138 {
      if b == 0 { state := DZ.Run(code,value,size,word,a,b); }
      else if a == Modulus()/2 && b == Modulus()-1 { state := DO.Run(code,value,size,word,a,b); }
      else { state := DN.Run(code,value,size,word,a,b); }
    }
    else {
      if b == 0 { state := MZ.Run(code,value,size,word,a,b); }
      else { state := MN.Run(code,value,size,word,a,b); }
    }
  }
}
