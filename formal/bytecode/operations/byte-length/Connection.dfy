// SPDX-License-Identifier: MIT
include "Nonzero.generated.dfy"
include "Short.generated.dfy"
include "Args.generated.dfy"
include "OffsetBound.generated.dfy"
include "LengthWindow.generated.dfy"
include "LengthBound.generated.dfy"
include "PayloadWindow.generated.dfy"
include "Ok.generated.dfy"
module OperationsByteLengthConnection {
  import opened OperationsByteLengthMachine
  import Nonzero = OperationsByteLengthNonzero
  import Short = OperationsByteLengthShort
  import Args = OperationsByteLengthArgs
  import OffsetBound = OperationsByteLengthOffsetBound
  import LengthWindow = OperationsByteLengthLengthWindow
  import LengthBound = OperationsByteLengthLengthBound
  import PayloadWindow = OperationsByteLengthPayloadWindow
  import Ok = OperationsByteLengthOk
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  function Offset(data: seq<Byte>): Word { DataWord(data,4) }
  function Length(data: seq<Byte>): Word { DataWord(data,4+Offset(data)) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  predicate Valid(data: seq<Byte>) {
    |data| >= 36 && Offset(data) < 0x10000000000000000 && Offset(data)+36 <= |data| &&
    Length(data) < 0x10000000000000000 && Offset(data)+36+Length(data) <= |data|
  }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),Offset(data),Length(data)) }
  opaque predicate Matches(code: seq<Byte>) {
    Nonzero.Matches(code) && Short.Matches(code) && Args.Matches(code) &&
    OffsetBound.Matches(code) && LengthWindow.Matches(code) && LengthBound.Matches(code) &&
    PayloadWindow.Matches(code) && Ok.Matches(code)
  }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Selector(DataWord(data,0)) == 0x248d6c38
    ensures value != 0 || !Valid(data) ==> state == Reverted([])
    ensures value == 0 && Valid(data) ==> state == Returned(Encode(Length(data),32))
  {
    reveal Matches();
    var size := |data| as Word; var word := DataWord(data,0);
    var a := Offset(data); var b := Length(data);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,a+4);
    if a == 0 { assert b == a; }
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,b); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,b); }
    else if size < 36 { state := Args.Run(code,value,size,word,a,b); }
    else if a >= 0x10000000000000000 { state := OffsetBound.Run(code,value,size,word,a,b); }
    else if a+36 > size { state := LengthWindow.Run(code,value,size,word,a,b); }
    else if b >= 0x10000000000000000 { state := LengthBound.Run(code,value,size,word,a,b); }
    else if a+36+b > size { state := PayloadWindow.Run(code,value,size,word,a,b); }
    else { state := Ok.Run(code,value,size,word,a,b); }
  }
}
