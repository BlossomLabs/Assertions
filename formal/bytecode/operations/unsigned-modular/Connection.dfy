// SPDX-License-Identifier: MIT
include "AddModUNonzero.generated.dfy"
include "AddModUZero.generated.dfy"
include "MulModUNonzero.generated.dfy"
include "MulModUZero.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
include "rejections/AddModUArgs.generated.dfy"
include "rejections/MulModUArgs.generated.dfy"
module OperationsUnsignedModularConnection {
  import opened OperationsUnsignedModularMachine
  import DN = OperationsUnsignedModularAddModUNonzero
  import DZ = OperationsUnsignedModularAddModUZero
  import MN = OperationsUnsignedModularMulModUNonzero
  import MZ = OperationsUnsignedModularMulModUZero
  import DA = OperationsUnsignedModularRawAddModUArgs
  import MA = OperationsUnsignedModularRawMulModUArgs
  import Nonzero = OperationsUnsignedModularRawNonzero
  import Short = OperationsUnsignedModularRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36),DataWord(data,68)) }
  predicate Assigned(selector: Word) { selector in {0xb12fe826,0xa4ad2ee9} }
  function Expected(selector: Word,a: Word,b: Word,c: Word): Word {
    if selector == 0xb12fe826 then AddModulo(a,b,c) else MulModulo(a,b,c)
  }
  opaque predicate Matches(code: seq<Byte>) { DN.Matches(code) && DZ.Matches(code) && MN.Matches(code) && MZ.Matches(code) && DA.Matches(code) && MA.Matches(code) && Nonzero.Matches(code) && Short.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 100 ==> state == Reverted([])
    ensures value == 0 && |data| >= 100 && DataWord(data,68) == 0 ==> state == Reverted(Panic(18))
    ensures value == 0 && |data| >= 100 && DataWord(data,68) > 0 ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36),DataWord(data,68)),32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); var b := DataWord(data,36); var c := DataWord(data,68);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36); LoadProjection(data,68);
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,b,c); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,b,c); }
    else if size < 100 {
      if Selector(word) == 0xb12fe826 { state := DA.Run(code,value,size,word,a,b,c); }
      else { state := MA.Run(code,value,size,word,a,b,c); }
    }
    else if Selector(word) == 0xb12fe826 {
      if c == 0 { state := DZ.Run(code,value,size,word,a,b,c); }
      else { state := DN.Run(code,value,size,word,a,b,c); }
    }
    else {
      if c == 0 { state := MZ.Run(code,value,size,word,a,b,c); }
      else { state := MN.Run(code,value,size,word,a,b,c); }
    }
  }
}
