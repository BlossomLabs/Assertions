// SPDX-License-Identifier: MIT
// Generated complete exact successful hash body; never edit directly.
include "Kernel.dfy"
include "State.generated.dfy"
include "Opcodes.dfy"
module OperationsHashSuccessBlock0 {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import K = OperationsHashSuccessKernel
  import opened OperationsHashSuccessState
  import O = OperationsHashSuccessOpcodes
  lemma Advance0(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(0,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(1,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7568,[2854126814,1329,source,count],K.Initial());
    assert Fetch(code,7568)==Op(91,7569,0);
  }
  lemma Advance1(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(1,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(2,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7569,[2854126814,1329,source,count],K.Initial());
    assert Fetch(code,7569)==Op(95,7570,0);
  }
  lemma Advance2(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(2,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(3,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7570,[2854126814,1329,source,count,0],K.Initial());
    assert Fetch(code,7570)==Op(130,7571,0);
  }
  lemma Advance3(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(3,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(4,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7571,[2854126814,1329,source,count,0,source],K.Initial());
    assert Fetch(code,7571)==Op(130,7572,0);
  }
  lemma Advance4(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(4,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(5,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7572,[2854126814,1329,source,count,0,source,count],K.Initial());
    assert code[7573]==64;
    assert Fetch(code,7572)==Op(96,7574,64);
  }
  lemma Advance5(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(5,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(6,next,data,source,count,result)
  {
    O.LoadState(code,state,data,source,count,result,hashes);
  }
  lemma Advance6(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(6,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(7,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7575,[2854126814,1329,source,count,0,source,count,128],K.Initial());
    assert code[7576]==29;
    assert code[7577]==161;
    assert Fetch(code,7575)==Op(97,7578,7585);
  }
  lemma Advance7(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(7,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(8,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7578,[2854126814,1329,source,count,0,source,count,128,7585],K.Initial());
    assert Fetch(code,7578)==Op(146,7579,0);
  }
  lemma Advance8(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(8,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(9,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7579,[2854126814,1329,source,count,0,7585,count,128,source],K.Initial());
    assert Fetch(code,7579)==Op(145,7580,0);
  }
  lemma Advance9(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(9,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(10,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7580,[2854126814,1329,source,count,0,7585,source,128,count],K.Initial());
    assert Fetch(code,7580)==Op(144,7581,0);
  }
  lemma Advance10(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(10,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(11,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7581,[2854126814,1329,source,count,0,7585,source,count,128],K.Initial());
    assert code[7582]==78;
    assert code[7583]==79;
    assert Fetch(code,7581)==Op(97,7584,20047);
  }
  lemma Advance11(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(11,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(12,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7584,[2854126814,1329,source,count,0,7585,source,count,128,20047],K.Initial());
    assert Fetch(code,7584)==Op(86,7585,0);
    O.Jump(code,Destinations(),data,hashes,7584,[2854126814,1329,source,count,0,7585,source,count,128],20047,K.Initial());
    assert 20047 in Destinations() && code[20047]==0x5b;
  }
  lemma Advance12(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(12,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(13,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20047,[2854126814,1329,source,count,0,7585,source,count,128],K.Initial());
    assert Fetch(code,20047)==Op(91,20048,0);
  }
  lemma Advance13(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(13,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(14,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20048,[2854126814,1329,source,count,0,7585,source,count,128],K.Initial());
    assert Fetch(code,20048)==Op(129,20049,0);
  }
  lemma Advance14(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(14,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(15,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20049,[2854126814,1329,source,count,0,7585,source,count,128,count],K.Initial());
    assert Fetch(code,20049)==Op(131,20050,0);
  }
  lemma Advance15(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(15,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(16,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20050,[2854126814,1329,source,count,0,7585,source,count,128,count,source],K.Initial());
    assert Fetch(code,20050)==Op(130,20051,0);
  }
  lemma Advance16(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(16,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(17,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20051,[2854126814,1329,source,count,0,7585,source,count,128,count,source,128],K.Initial());
    assert Fetch(code,20051)==Op(55,20052,0);
    E.CopyOpcode(code,Destinations(),K.Initial(),data,0,0,hashes,20051,[2854126814,1329,source,count,0,7585,source,count,128],128,source,count);
  }
  lemma Advance17(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(17,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(18,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20052,[2854126814,1329,source,count,0,7585,source,count,128],K.Copied(data,source,count));
    assert Fetch(code,20052)==Op(95,20053,0);
  }
  lemma Advance18(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(18,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(19,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20053,[2854126814,1329,source,count,0,7585,source,count,128,0],K.Copied(data,source,count));
    assert Fetch(code,20053)==Op(145,20054,0);
  }
  lemma Advance19(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(19,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(20,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20054,[2854126814,1329,source,count,0,7585,source,0,128,count],K.Copied(data,source,count));
    assert Fetch(code,20054)==Op(1,20055,0);
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(0,initial,data,source,count,result)
    ensures Good(20,state,data,source,count,result)
  { state:=initial;
    Advance0(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance1(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance2(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance3(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance4(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance5(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance6(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance7(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance8(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance9(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance10(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance11(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance12(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance13(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance14(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance15(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance16(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance17(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance18(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance19(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
  }
}
