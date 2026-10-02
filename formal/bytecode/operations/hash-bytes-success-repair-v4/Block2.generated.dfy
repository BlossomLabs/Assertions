// SPDX-License-Identifier: MIT
// Generated complete exact successful hash body; never edit directly.
include "Kernel.dfy"
include "State.generated.dfy"
include "Opcodes.dfy"
module OperationsHashSuccessBlock2 {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import K = OperationsHashSuccessKernel
  import opened OperationsHashSuccessState
  import O = OperationsHashSuccessOpcodes
  lemma Advance40(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(40,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(41,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7599,[2854126814,result,1329,count],K.Cleared(data,source,count));
    assert Fetch(code,7599)==Op(80,7600,0);
  }
  lemma Advance41(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(41,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(42,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(7600,[2854126814,result,1329],K.Cleared(data,source,count));
    assert Fetch(code,7600)==Op(86,7601,0);
    O.Jump(code,Destinations(),data,hashes,7600,[2854126814,result],1329,K.Cleared(data,source,count));
    assert 1329 in Destinations() && code[1329]==0x5b;
  }
  lemma Advance42(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(42,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(43,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1329,[2854126814,result],K.Cleared(data,source,count));
    assert Fetch(code,1329)==Op(91,1330,0);
  }
  lemma Advance43(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(43,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(44,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1330,[2854126814,result],K.Cleared(data,source,count));
    assert code[1331]==64;
    assert Fetch(code,1330)==Op(96,1332,64);
  }
  lemma Advance44(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(44,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(45,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1332,[2854126814,result,64],K.Cleared(data,source,count));
    assert Fetch(code,1332)==Op(81,1333,0);
    O.LoadMemory(code,Destinations(),data,hashes,1332,[2854126814,result],K.Cleared(data,source,count));
  }
  lemma Advance45(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(45,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(46,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1333,[2854126814,result,128],K.Cleared(data,source,count));
    assert Fetch(code,1333)==Op(144,1334,0);
  }
  lemma Advance46(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(46,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(47,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1334,[2854126814,128,result],K.Cleared(data,source,count));
    assert Fetch(code,1334)==Op(129,1335,0);
  }
  lemma Advance47(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(47,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(48,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1335,[2854126814,128,result,128],K.Cleared(data,source,count));
    assert Fetch(code,1335)==Op(82,1336,0);
  }
  lemma Advance48(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(48,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(49,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1336,[2854126814,128],K.Finished(data,source,count,result));
    assert code[1337]==32;
    assert Fetch(code,1336)==Op(96,1338,32);
  }
  lemma Advance49(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(49,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(50,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1338,[2854126814,128,32],K.Finished(data,source,count,result));
    assert Fetch(code,1338)==Op(1,1339,0);
  }
  lemma Advance50(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(50,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(51,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1339,[2854126814,160],K.Finished(data,source,count,result));
    assert code[1340]==5;
    assert code[1341]==21;
    assert Fetch(code,1339)==Op(97,1342,1301);
  }
  lemma Advance51(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(51,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(52,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1342,[2854126814,160,1301],K.Finished(data,source,count,result));
    assert Fetch(code,1342)==Op(86,1343,0);
    O.Jump(code,Destinations(),data,hashes,1342,[2854126814,160],1301,K.Finished(data,source,count,result));
    assert 1301 in Destinations() && code[1301]==0x5b;
  }
  lemma Advance52(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(52,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(53,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1301,[2854126814,160],K.Finished(data,source,count,result));
    assert Fetch(code,1301)==Op(91,1302,0);
  }
  lemma Advance53(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(53,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(54,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1302,[2854126814,160],K.Finished(data,source,count,result));
    assert code[1303]==64;
    assert Fetch(code,1302)==Op(96,1304,64);
  }
  lemma Advance54(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(54,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(55,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1304,[2854126814,160,64],K.Finished(data,source,count,result));
    assert Fetch(code,1304)==Op(81,1305,0);
    O.LoadMemory(code,Destinations(),data,hashes,1304,[2854126814,160],K.Finished(data,source,count,result));
  }
  lemma Advance55(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(55,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(56,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1305,[2854126814,160,128],K.Finished(data,source,count,result));
    assert Fetch(code,1305)==Op(128,1306,0);
  }
  lemma Advance56(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(56,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(57,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1306,[2854126814,160,128,128],K.Finished(data,source,count,result));
    assert Fetch(code,1306)==Op(145,1307,0);
  }
  lemma Advance57(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(57,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(58,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1307,[2854126814,128,128,160],K.Finished(data,source,count,result));
    assert Fetch(code,1307)==Op(3,1308,0);
  }
  lemma Advance58(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(58,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); Good(59,next,data,source,count,result)
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1308,[2854126814,128,32],K.Finished(data,source,count,result));
    assert Fetch(code,1308)==Op(144,1309,0);
  }
  lemma Advance59(code: seq<Byte>,state: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(59,state,data,source,count,result)
    ensures state.Running? && |state.stack|<=12
    ensures var next:=E.Execute(code,Destinations(),state,data,0,0,hashes); next==Returned(Encode(result,32))
  {
    reveal Good(); reveal Matches(); reveal E.Execute(); reveal Step();
    K.Heaps(data,source,count,result);
    assert state==Running(1309,[2854126814,32,128],K.Finished(data,source,count,result));
    assert Fetch(code,1309)==Op(243,1310,0);
    K.Receipt(data,source,count,result);
  }
  ghost method RunBlock(code: seq<Byte>,initial: State,data: seq<Byte>,source: Word,count: Word,result: Word,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires Matches(code) && K.Observed(data,source,count,result,hashes) && Good(40,initial,data,source,count,result)
    ensures state==Returned(Encode(result,32))
  { state:=initial;
    Advance40(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance41(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance42(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance43(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance44(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance45(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance46(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance47(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance48(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance49(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance50(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance51(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance52(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance53(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance54(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance55(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance56(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance57(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance58(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
    Advance59(code,state,data,source,count,result,hashes);
    state:=E.Execute(code,Destinations(),state,data,0,0,hashes);
  }
}
