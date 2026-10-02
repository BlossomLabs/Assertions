// SPDX-License-Identifier: MIT
include "Model.dfy"
module CollectionsWordApplyProperties {
  import opened AbiFrames
  import opened CollectionsWordApplyModel
  import Call = CollectionsWordCallModel
  import C = CollectionsCallsModel
  import Mem = CollectionsWordMemoryModel
  lemma BytesLength(values: seq<nat>)
    ensures |Bytes(values)| == 32*|values|
    decreases |values|
  { if |values| > 0 { BytesLength(values[1..]); } }
  lemma BytesAppend(values: seq<nat>,value: nat)
    ensures Bytes(values+[value]) == Bytes(values)+Word(value)
    decreases |values|
  {
    if |values| > 0 {
      assert (values+[value])[1..] == values[1..]+[value];
      BytesAppend(values[1..],value);
    }
  }
  lemma AttachNext(values: seq<nat>,rows: seq<Row>,more: seq<nat>,row: Row,out: Outcome)
    ensures Attach(values,rows,Attach(more,[row],out)) == Attach(values+more,rows+[row],out)
  {}
  lemma Bounds(k: Config,index: nat,h: seq<C.Event>)
    requires Static(k) && index <= Count(k)
    ensures |Tail(k,index,h).rows| <= Count(k)-index
    ensures Tail(k,index,h).Finished? ==> |Tail(k,index,h).rows| == Count(k)-index && |Tail(k,index,h).values| <= Count(k)-index
    ensures Tail(k,index,h).Finished? && !k.filterMode ==> |Tail(k,index,h).values| == Count(k)-index
    ensures Tail(k,index,h).Failed? ==> |Tail(k,index,h).rows| > 0 && Tail(k,index,h).index == index+|Tail(k,index,h).rows|-1
    decreases Count(k)-index
  {
    if index < Count(k) && Checked(k,index,Answer(k,index,h)).Word? {
      Bounds(k,index+1,After(k,index,h));
    }
  }
  function Events(k: Config,rows: seq<Row>): seq<C.Event>
    decreases |rows|
  { if |rows| == 0 then [] else [C.External(k.target,rows[0].data)]+Events(k,rows[1..]) }
  lemma History(k: Config,index: nat,h: seq<C.Event>)
    requires Static(k) && index <= Count(k)
    ensures Tail(k,index,h).history == h+Events(k,Tail(k,index,h).rows)
    ensures |Tail(k,index,h).history| == |h|+|Tail(k,index,h).rows|
    decreases Count(k)-index
  {
    if index < Count(k) && Checked(k,index,Answer(k,index,h)).Word? {
      History(k,index+1,After(k,index,h));
    }
  }
  lemma RowAt(k: Config,index: nat,h: seq<C.Event>,j: nat)
    requires Static(k) && index <= Count(k) && j < |Tail(k,index,h).rows|
    ensures var rows := Tail(k,index,h).rows; rows[j].index == index+j && rows[j].index < Count(k)
    ensures var rows := Tail(k,index,h).rows; rows[j].data == Data(k,rows[j].index) && rows[j].answer == Answer(k,rows[j].index,rows[j].before)
    ensures var rows := Tail(k,index,h).rows; j == 0 ==> rows[j].before == h
    ensures var rows := Tail(k,index,h).rows; j > 0 ==> Checked(k,rows[j-1].index,rows[j-1].answer).Word? && rows[j].before == rows[j-1].before+[C.External(k.target,rows[j-1].data)]
    ensures var rows := Tail(k,index,h).rows; j < |rows|-1 ==> Checked(k,rows[j].index,rows[j].answer).Word?
    decreases j
  {
    assert index < Count(k);
    if j > 0 {
      assert Checked(k,index,Answer(k,index,h)).Word?;
      RowAt(k,index+1,After(k,index,h),j-1);
      var rest := Tail(k,index+1,After(k,index,h)).rows;
      var rows := Tail(k,index,h).rows;
      assert rows[j] == rest[j-1];
      if j > 1 { assert rows[j-1] == rest[j-2]; }
    }
  }
  lemma Last(k: Config,index: nat,h: seq<C.Event>)
    requires Static(k) && index <= Count(k)
    ensures var out := Tail(k,index,h); out.Failed? ==> |out.rows| > 0 && Checked(k,out.index,out.rows[|out.rows|-1].answer) == Call.Failure(out.reason) && out.rows[|out.rows|-1].index == out.index
    decreases Count(k)-index
  {
    if index < Count(k) && Checked(k,index,Answer(k,index,h)).Word? {
      Last(k,index+1,After(k,index,h));
      var rest := Tail(k,index+1,After(k,index,h));
      var out := Tail(k,index,h);
      if |rest.rows| > 0 { assert out.rows[|out.rows|-1] == rest.rows[|rest.rows|-1]; }
    }
  }
}
