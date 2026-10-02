include "Model.dfy"
module OperationsSplitSource {
  import M = OperationsSplitModel
  import W = OperationsWordMatchModel
  import O = OperationsOccurrenceModel
  import C = OperationsOccurrenceSource
  import S = OperationsWordMatchSource
  method Split(data: seq<bv8>,delimiter: seq<bv8>,dataOffset: nat,delimiterOffset: nat,outsideData: seq<bv8>,outsideDelimiter: seq<bv8>) returns (out: M.Outcome)
    requires |data|+1 < W.Half && |delimiter| < W.Half
    requires |outsideData| == 32 && |outsideDelimiter| == 32
    requires dataOffset+|data|+32 < W.Word && delimiterOffset+|delimiter|+32 < W.Word
    ensures out == M.Spec(data,delimiter)
  {
    if $EMPTY$ { out := M.EmptyNeedle; return; }
    var count := C.Count(data,delimiter,dataOffset,delimiterOffset,outsideData,outsideDelimiter);
    O.PositionsBounds(data,delimiter,0);
    assert count+1 < W.Word;
    var parts: seq<seq<bv8>> := seq(count+1,i => []);
    var start := 0;
    var position := 0;
    var index := 0;
    M.TailProperties(data,delimiter,0,0);
    ghost var expected := M.Tail(data,delimiter,0,0);
    while $LOOP$
      invariant 0 <= start <= position <= |data|
      invariant 0 <= index < |parts|
      invariant |parts| == count+1 && |parts| == |expected|
      invariant expected == parts[..index]+M.Tail(data,delimiter,start,position)
      decreases |data|-position
    {
      assert position+|delimiter| < W.Word;
      var matched := S.Match(data,delimiter,position,dataOffset,delimiterOffset,outsideData,outsideDelimiter);
      if $FOUND$ {
        M.TailProperties(data,delimiter,position+|delimiter|,position+|delimiter|);
        var segment := $SEGMENT$;
        parts := parts[index := segment];
        assert parts[..index+1] == parts[..index]+[segment];
        assert index+1 < W.Word;
        index := index+1;
        position := $NEXT$;
        start := $START$;
      } else { position := position+1; }
    }
    assert M.Tail(data,delimiter,start,position) == [data[start..]];
    assert |parts| == index+1;
    parts := parts[index := $LAST$];
    assert parts == parts[..index]+[parts[index]];
    out := M.Parts(parts);
  }
  method SegmentWitness()
  {
    var data: seq<bv8> := [97,44,98];
    var delimiter: seq<bv8> := [44];
    var start := 0;
    var position := 1;
    var segment := $SEGMENT$;
    assert segment == [97];
  }
  method TailWitness()
  {
    var data: seq<bv8> := [97,44,98];
    var start := 2;
    var tail := $LAST$;
    assert tail == [98];
  }

}
