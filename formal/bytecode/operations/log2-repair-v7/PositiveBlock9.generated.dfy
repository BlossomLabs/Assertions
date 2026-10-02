// SPDX-License-Identifier: MIT
// Generated complete exact log2 instruction block. Never edit directly.
include "PositiveState.generated.dfy"
module OperationsBytecodeLog2PositiveBlock9 {
  import opened OperationsBytecodeLog2Machine
  import opened OperationsBytecodeLog2PositiveState
  import K = OperationsBytecodeLog2Kernel
  import F = OperationsBytecodeLog2Math
  import B = OperationsBytecodeLog2BinaryKernel
  lemma Advance180(code: seq<Byte>,state: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(180,state,value,size,word,a,b,c)
    ensures state.Running? && |state.stack|<=11 && |state.memory|<=192
    ensures var next:=Step(code,Destinations(),state,value,size,word,a,b,c); next==Returned(Encode(Result(a),32))
  {
    reveal Good(); reveal Matches(); reveal Step();
    assert state==Running(1309,[1414971155,32,128],Store(Store([],64,128),128,BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a))));
    assert Fetch(code,1309)==Op(243,1310,0);
    var computed: Word := BitOr(ByteWord(Right(a,K.R4(a)),6928917744019834342450304135053993530982274426945361611473370484834304),K.R4(a));
    SymmetricBits(ByteWord(Right(a,K.R4(a)),K.Table),K.R4(a));
    K.Pipeline(a);
    assert computed==Result(a);
    assert state.memory==Store(Store([],64,128),128,Result(a));
    StoreLoad(Store([],64,128),128,Result(a));
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,value: Word,size: Word,word: Word,a: Word,b: Word,c: Word) returns(state: State)
    requires Matches(code) && Admitted(value,size,word,a,b,c) && Good(180,initial,value,size,word,a,b,c)
    ensures state==Returned(Encode(Result(a),32))
  {
    state:=initial;
    Advance180(code,state,value,size,word,a,b,c);
    state:=Step(code,Destinations(),state,value,size,word,a,b,c);
  }
}
