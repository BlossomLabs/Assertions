// SPDX-License-Identifier: MIT
// Unverified candidate full raw log2 entry connection; no public credit.
include "Positive.generated.dfy"
include "Zero.generated.dfy"
include "Args.generated.dfy"
include "Short.generated.dfy"
include "Nonzero.generated.dfy"
module OperationsBytecodeLog2Connection {
  import opened OperationsBytecodeLog2Machine
  import F = OperationsBytecodeLog2Math
  import K = OperationsBytecodeLog2Kernel
  import Positive = OperationsBytecodeLog2Positive
  import Zero = OperationsBytecodeLog2Zero
  import Args = OperationsBytecodeLog2Args
  import Short = OperationsBytecodeLog2Short
  import Nonzero = OperationsBytecodeLog2Nonzero
  predicate Frame(data: seq<Byte>) { |data|<0x10000000000000000 }
  function DataWord(data: seq<Byte>,offset: nat): Word { Load(data,offset) }
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36),DataWord(data,68)) }
  opaque predicate Matches(code: seq<Byte>) {
    Positive.Matches(code) && Zero.Matches(code) && Args.Matches(code) && Short.Matches(code) && Nonzero.Matches(code)
  }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns(state: State)
    requires Frame(data) && Matches(code)
    requires value!=0 || |data|<4 || Selector(DataWord(data,0))==0x5456bf13
    ensures value!=0 || |data|<36 ==> state==Reverted([])
    ensures value==0 && |data|>=36 && DataWord(data,4)==0 ==> state==Reverted(K.Undefined())
    ensures value==0 && |data|>=36 && DataWord(data,4)>0 ==>
              state==Returned(Encode(F.Log(DataWord(data,4)),32))
  {
    reveal Matches();
    var size:=|data| as Word;
    var word:=DataWord(data,0);
    var a:=DataWord(data,4);
    var b:=DataWord(data,36);
    var c:=DataWord(data,68);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36); LoadProjection(data,68);
    if value!=0 { state:=Nonzero.Run(code,value,size,word,a,b,c); }
    else if size<4 { state:=Short.Run(code,value,size,word,a,b,c); }
    else if size<36 { state:=Args.Run(code,value,size,word,a,b,c); }
    else if a==0 { state:=Zero.Run(code,value,size,word,a,b,c); }
    else { K.Pipeline(a); state:=Positive.Run(code,value,size,word,a,b,c); }
  }
}
