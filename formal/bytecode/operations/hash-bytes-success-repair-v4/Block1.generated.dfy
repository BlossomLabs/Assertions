// SPDX-License-Identifier: MIT
// Generated complete exact successful hash body; never edit directly.
include "Kernel.dfy"
include "State.generated.dfy"
include "Opcodes.dfy"
module OperationsHashSuccessBlock1 {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import K = OperationsHashSuccessKernel
  import opened OperationsHashSuccessState
  import O = OperationsHashSuccessOpcodes
  lemma Advance20(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(20,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(21,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20055,[2854126814,1329,source,count,0,7585,source,0,128+(count as nat)],K.Copied(data,source,count));
    assert Fetch(code,20055)==Op(144,20056,0);
  }
  lemma Advance21(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(21,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(22,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20056,[2854126814,1329,source,count,0,7585,source,128+(count as nat),0],K.Copied(data,source,count));
    assert Fetch(code,20056)==Op(129,20057,0);
  }
  lemma Advance22(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(22,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(23,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20057,[2854126814,1329,source,count,0,7585,source,128+(count as nat),0,128+(count as nat)],K.Copied(data,source,count));
    assert Fetch(code,20057)==Op(82,20058,0);
  }
  lemma Advance23(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(23,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(24,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20058,[2854126814,1329,source,count,0,7585,source,128+(count as nat)],K.Cleared(data,source,count));
    assert Fetch(code,20058)==Op(145,20059,0);
  }
  lemma Advance24(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(24,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(25,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20059,[2854126814,1329,source,count,0,128+(count as nat),source,7585],K.Cleared(data,source,count));
    assert Fetch(code,20059)==Op(144,20060,0);
  }
  lemma Advance25(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(25,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(26,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20060,[2854126814,1329,source,count,0,128+(count as nat),7585,source],K.Cleared(data,source,count));
    assert Fetch(code,20060)==Op(80,20061,0);
  }
  lemma Advance26(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(26,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(27,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(20061,[2854126814,1329,source,count,0,128+(count as nat),7585],K.Cleared(data,source,count));
    assert Fetch(code,20061)==Op(86,20062,0);
    O.Jump(code,Destinations(),data,hashes,20061,[2854126814,1329,source,count,0,128+(count as nat)],7585,K.Cleared(data,source,count));
    assert 7585 in Destinations() && code[7585]==0x5b;
  }
  lemma Advance27(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(27,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(28,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7585,[2854126814,1329,source,count,0,128+(count as nat)],K.Cleared(data,source,count));
    assert Fetch(code,7585)==Op(91,7586,0);
  }
  lemma Advance28(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(28,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(29,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7586,[2854126814,1329,source,count,0,128+(count as nat)],K.Cleared(data,source,count));
    assert code[7587]==64;
    assert Fetch(code,7586)==Op(96,7588,64);
  }
  lemma Advance29(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(29,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(30,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7588,[2854126814,1329,source,count,0,128+(count as nat),64],K.Cleared(data,source,count));
    assert Fetch(code,7588)==Op(81,7589,0);
    O.LoadMemory(code,Destinations(),data,hashes,7588,[2854126814,1329,source,count,0,128+(count as nat)],K.Cleared(data,source,count));
  }
  lemma Advance30(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(30,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(31,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7589,[2854126814,1329,source,count,0,128+(count as nat),128],K.Cleared(data,source,count));
    assert Fetch(code,7589)==Op(128,7590,0);
  }
  lemma Advance31(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(31,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(32,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7590,[2854126814,1329,source,count,0,128+(count as nat),128,128],K.Cleared(data,source,count));
    assert Fetch(code,7590)==Op(145,7591,0);
  }
  lemma Advance32(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(32,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(33,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7591,[2854126814,1329,source,count,0,128,128,128+(count as nat)],K.Cleared(data,source,count));
    assert Fetch(code,7591)==Op(3,7592,0);
  }
  lemma Advance33(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(33,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(34,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7592,[2854126814,1329,source,count,0,128,count],K.Cleared(data,source,count));
    assert Fetch(code,7592)==Op(144,7593,0);
  }
  lemma Advance34(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(34,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(35,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7593,[2854126814,1329,source,count,0,count,128],K.Cleared(data,source,count));
    assert Fetch(code,7593)==Op(32,7594,0);
    K.Payload(data,source,count,result,hashes);
    E.HashOpcode(code,Destinations(),K.Cleared(data,source,count),data,0,0,hashes,7593,[2854126814,1329,source,count,0],128,count);
  }
  lemma Advance35(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(35,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(36,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7594,[2854126814,1329,source,count,0,result],K.Cleared(data,source,count));
    assert Fetch(code,7594)==Op(144,7595,0);
  }
  lemma Advance36(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(36,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(37,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7595,[2854126814,1329,source,count,result,0],K.Cleared(data,source,count));
    assert Fetch(code,7595)==Op(80,7596,0);
  }
  lemma Advance37(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(37,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(38,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7596,[2854126814,1329,source,count,result],K.Cleared(data,source,count));
    assert Fetch(code,7596)==Op(146,7597,0);
  }
  lemma Advance38(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(38,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(39,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7597,[2854126814,result,source,count,1329],K.Cleared(data,source,count));
    assert Fetch(code,7597)==Op(145,7598,0);
  }
  lemma Advance39(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(39,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(40,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7598,[2854126814,result,1329,count,source],K.Cleared(data,source,count));
    assert Fetch(code,7598)==Op(80,7599,0);
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(20,initial,data,source,count,result)
    ensures Good(40,state,data,source,count,result)
  { state:=initial;
    Advance20(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance21(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance22(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance23(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance24(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance25(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance26(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance27(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance28(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance29(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance30(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance31(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance32(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance33(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance34(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance35(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance36(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance37(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance38(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance39(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
  }
}
