// SPDX-License-Identifier: MIT
include "Source.generated.dfy"
module CollectionsWordFoldLoopConnection {
  import opened AbiFrames
  import opened CollectionsWordFoldLoopModel
  import S = CollectionsWordFoldLoopSource
  import Mem = CollectionsWordMemoryModel
  import C = CollectionsCallsModel
  import Call = CollectionsWordCallModel
  lemma Bounds(k: Config,index: nat,acc: nat,h: seq<C.Event>)
    requires Static(k) && index <= k.count
    ensures |Tail(k,index,acc,h).rows| <= k.count-index
    ensures Tail(k,index,acc,h).Finished? ==> Tail(k,index,acc,h).stop == index+|Tail(k,index,acc,h).rows|
    ensures Tail(k,index,acc,h).Failed? ==> |Tail(k,index,acc,h).rows| > 0 && Tail(k,index,acc,h).index == index+|Tail(k,index,acc,h).rows|-1
    decreases k.count-index
  {
    if index < k.count && Answer(k,index,acc,h).Word? && !Stop(k.exit,Answer(k,index,acc,h).value) {
      Bounds(k,index+1,Answer(k,index,acc,h).value,After(k,index,acc,h));
    }
  }
  function Events(k: Config,rows: seq<Row>): seq<C.Event>
    decreases |rows|
  { if |rows| == 0 then [] else [C.External(k.target,rows[0].data)]+Events(k,rows[1..]) }
  lemma History(k: Config,index: nat,acc: nat,h: seq<C.Event>)
    requires Static(k) && index <= k.count
    ensures Tail(k,index,acc,h).history == h+Events(k,Tail(k,index,acc,h).rows)
    ensures |Tail(k,index,acc,h).history| == |h|+|Tail(k,index,acc,h).rows|
    decreases k.count-index
  {
    if index < k.count && Answer(k,index,acc,h).Word? && !Stop(k.exit,Answer(k,index,acc,h).value) {
      History(k,index+1,Answer(k,index,acc,h).value,After(k,index,acc,h));
    }
  }
  lemma RowAt(k: Config,index: nat,acc: nat,h: seq<C.Event>,j: nat)
    requires Static(k) && index <= k.count && j < |Tail(k,index,acc,h).rows|
    ensures var rows := Tail(k,index,acc,h).rows; rows[j].index == index+j && rows[j].index < k.count
    ensures var rows := Tail(k,index,acc,h).rows; rows[j].data == Data(k,rows[j].index,rows[j].acc) && rows[j].answer == Answer(k,rows[j].index,rows[j].acc,rows[j].before)
    ensures var rows := Tail(k,index,acc,h).rows; j == 0 ==> rows[j].acc == acc && rows[j].before == h
    ensures var rows := Tail(k,index,acc,h).rows; j > 0 ==> rows[j-1].answer.Word? && !Stop(k.exit,rows[j-1].answer.value) && rows[j].acc == rows[j-1].answer.value && rows[j].before == rows[j-1].before+[C.External(k.target,rows[j-1].data)]
    ensures var rows := Tail(k,index,acc,h).rows; j < |rows|-1 ==> rows[j].answer.Word? && !Stop(k.exit,rows[j].answer.value)
    decreases j
  {
    assert index < k.count;
    if j > 0 {
      var a := Answer(k,index,acc,h);
      assert a.Word? && !Stop(k.exit,a.value);
      RowAt(k,index+1,a.value,After(k,index,acc,h),j-1);
      var rest := Tail(k,index+1,a.value,After(k,index,acc,h)).rows;
      var rows := Tail(k,index,acc,h).rows;
      assert rows[j] == rest[j-1];
      if j > 1 { assert rows[j-1] == rest[j-2]; }
    }
  }
  lemma Last(k: Config,index: nat,acc: nat,h: seq<C.Event>)
    requires Static(k) && index <= k.count
    ensures Tail(k,index,acc,h).Finished? && |Tail(k,index,acc,h).rows| == 0 ==> Tail(k,index,acc,h).value == acc && index == k.count
    ensures var out := Tail(k,index,acc,h); out.Finished? && |out.rows| > 0 ==> out.rows[|out.rows|-1].answer == Call.Word(out.value) && (out.stop == k.count || Stop(k.exit,out.value))
    ensures var out := Tail(k,index,acc,h); out.Failed? ==> |out.rows| > 0 && out.rows[|out.rows|-1].answer == Call.Failure(out.reason) && out.rows[|out.rows|-1].index == out.index
    decreases k.count-index
  {
    if index < k.count && Answer(k,index,acc,h).Word? && !Stop(k.exit,Answer(k,index,acc,h).value) {
      var a := Answer(k,index,acc,h);
      Last(k,index+1,a.value,After(k,index,acc,h));
      var rest := Tail(k,index+1,a.value,After(k,index,acc,h));
      var out := Tail(k,index,acc,h);
      if |rest.rows| > 0 { assert out.rows[|out.rows|-1] == rest.rows[|rest.rows|-1]; }
    }
  }
  ghost method Run(k: Config,initial: nat,h: seq<C.Event>,memory: seq<Byte>,base: nat)
    returns (out: Outcome,after: seq<Byte>)
    requires Static(k) && Mem.Fits(initial) && Budget(k,0,initial,h)
    requires Mem.Fits(|memory|) && Mem.Frame(memory,base,k.template)
    ensures out == Tail(k,0,initial,h)
    ensures out.history == h+Events(k,out.rows) && |out.history| == |h|+|out.rows|
    ensures |out.rows| <= k.count
    ensures out.Finished? ==> Mem.Fits(out.value) && out.stop == |out.rows|
    ensures out.Finished? && |out.rows| > 0 ==> out.rows[|out.rows|-1].answer == Call.Word(out.value) && (out.stop == k.count || Stop(k.exit,out.value))
    ensures out.Failed? ==> |out.rows| > 0 && out.index == |out.rows|-1 && out.rows[|out.rows|-1].answer == Call.Failure(out.reason)
    ensures forall j :: 0 <= j < |out.rows| ==> out.rows[j].index == j && j < k.count && out.rows[j].data == Data(k,j,out.rows[j].acc) && out.rows[j].answer == Answer(k,j,out.rows[j].acc,out.rows[j].before)
    ensures forall j :: 0 <= j < |out.rows|-1 ==> out.rows[j].answer.Word? && !Stop(k.exit,out.rows[j].answer.value)
    ensures k.count == 0 ==> out == Finished(initial,0,h,[])
    ensures out.Finished? && k.exit == Full ==> out.stop == k.count
    ensures |after| == |memory| && after[..base+32] == memory[..base+32] && after[base+32+|k.template|..] == memory[base+32+|k.template|..]
  {
    out,after := S.Run(k,initial,h,memory,base);
    Bounds(k,0,initial,h); History(k,0,initial,h); Last(k,0,initial,h);
    forall j | 0 <= j < |out.rows|
      ensures out.rows[j].index == j && j < k.count && out.rows[j].data == Data(k,j,out.rows[j].acc) && out.rows[j].answer == Answer(k,j,out.rows[j].acc,out.rows[j].before)
      ensures j < |out.rows|-1 ==> out.rows[j].answer.Word? && !Stop(k.exit,out.rows[j].answer.value)
    { RowAt(k,0,initial,h,j); }
  }

}
