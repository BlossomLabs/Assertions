// SPDX-License-Identifier: MIT
include "MulSOk.generated.dfy"
include "MulSOverflow.generated.dfy"
include "MulSMinimumOverflow.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
include "rejections/MulSArgs.generated.dfy"
module OperationsSignedMultiplyConnection {
  import opened OperationsSignedMultiplyMachine
  import Ok = OperationsSignedMultiplyMulSOk
  import Overflow = OperationsSignedMultiplyMulSOverflow
  import Minimum = OperationsSignedMultiplyMulSMinimumOverflow
  import Args = OperationsSignedMultiplyRawMulSArgs
  import Nonzero = OperationsSignedMultiplyRawNonzero
  import Short = OperationsSignedMultiplyRawShort
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36)) }
  opaque predicate Matches(code: seq<Byte>) { Ok.Matches(code) && Overflow.Matches(code) && Minimum.Matches(code) && Args.Matches(code) && Nonzero.Matches(code) && Short.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Selector(DataWord(data,0)) == 0xbbe93d91
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 && !( -(Modulus()/2) <= Signed(DataWord(data,4))*Signed(DataWord(data,36)) < Modulus()/2 ) ==> state == Reverted(Panic(17))
    ensures value == 0 && |data| >= 68 && -(Modulus()/2) <= Signed(DataWord(data,4))*Signed(DataWord(data,36)) < Modulus()/2 ==> state == Returned(Encode(SignedProduct(DataWord(data,4),DataWord(data,36)),32))
  {
    reveal Matches(); var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); var b := DataWord(data,36);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36);
    if value != 0 { state := Nonzero.Run(code,value,size,word,a,b); }
    else if size < 4 { state := Short.Run(code,value,size,word,a,b); }
    else if size < 68 { state := Args.Run(code,value,size,word,a,b); }
    else if -(Modulus()/2) <= Signed(a)*Signed(b) < Modulus()/2 { SignedProductProjection(a,b); state := Ok.Run(code,value,size,word,a,b); }
    else if Signed(a) < 0 && b == Modulus()/2 { state := Minimum.Run(code,value,size,word,a,b); }
    else { state := Overflow.Run(code,value,size,word,a,b); }
  }
}
