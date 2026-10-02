// SPDX-License-Identifier: MIT
// Generated complete exact log2 block composition. Never edit directly.
include "PositiveState.generated.dfy"
include "PositiveBlock0.generated.dfy"
include "PositiveBlock1.generated.dfy"
include "PositiveBlock2.generated.dfy"
include "PositiveBlock3.generated.dfy"
include "PositiveBlock4.generated.dfy"
include "PositiveBlock5.generated.dfy"
include "PositiveBlock6.generated.dfy"
include "PositiveBlock7.generated.dfy"
include "PositiveBlock8.generated.dfy"
include "PositiveBlock9.generated.dfy"
module OperationsBytecodeLog2Positive {
  import opened OperationsBytecodeLog2Machine
  import opened OperationsBytecodeLog2PositiveState
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  import D = OperationsBytecodeLog2PositiveState
  predicate Matches(code: seq<Byte>) { D.Matches(code) }
  import P0 = OperationsBytecodeLog2PositiveBlock0
  import P1 = OperationsBytecodeLog2PositiveBlock1
  import P2 = OperationsBytecodeLog2PositiveBlock2
  import P3 = OperationsBytecodeLog2PositiveBlock3
  import P4 = OperationsBytecodeLog2PositiveBlock4
  import P5 = OperationsBytecodeLog2PositiveBlock5
  import P6 = OperationsBytecodeLog2PositiveBlock6
  import P7 = OperationsBytecodeLog2PositiveBlock7
  import P8 = OperationsBytecodeLog2PositiveBlock8
  import P9 = OperationsBytecodeLog2PositiveBlock9
  lemma SemanticResult(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(168,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|>=2 && state.stack[|state.stack|-1]==128
    ensures state.stack[|state.stack|-2]==Result(a)
  { reveal Good(); K.Pipeline(a);  SymmetricBits(ByteWord(Right(a,K.R4(a)),K.Table),K.R4(a)); }
  lemma SemanticWitness(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(168,state,value,size,word,a,b,c)
    requires a==4
    ensures state.Running? && |state.stack|>=2 && state.stack[|state.stack|-1]==128
    ensures state.stack[|state.stack|-2]==Result(a)
  { reveal Good(); K.Pipeline(a); K.FourthInput(); K.OrZero(Right(K.Table,4)); SymmetricBits(ByteWord(Right(a,K.R4(a)),K.Table),K.R4(a)); }
  ghost method Run(code: seq<Byte>,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c)
    ensures state==Returned(Encode(Result(a),32))
  {
    reveal Good(); state:=Running(0,[],[]); assert Good(0,state,value,size,word,a,b,c);
    state:=P0.RunBlock(code,state,value,size,word,a,b,c);
    state:=P1.RunBlock(code,state,value,size,word,a,b,c);
    state:=P2.RunBlock(code,state,value,size,word,a,b,c);
    state:=P3.RunBlock(code,state,value,size,word,a,b,c);
    state:=P4.RunBlock(code,state,value,size,word,a,b,c);
    state:=P5.RunBlock(code,state,value,size,word,a,b,c);
    state:=P6.RunBlock(code,state,value,size,word,a,b,c);
    state:=P7.RunBlock(code,state,value,size,word,a,b,c);
    state:=P8.RunBlock(code,state,value,size,word,a,b,c);
    state:=P9.RunBlock(code,state,value,size,word,a,b,c);
  }
}
