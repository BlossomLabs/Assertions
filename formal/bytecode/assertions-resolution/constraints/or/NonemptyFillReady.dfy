// SPDX-License-Identifier: MIT
// Isolate one child decoder's physical input from loop trace bookkeeping.
include "NonemptyFillHeap.dfy"
include "NonemptyItem.generated.dfy"
module AssertionsConstraintOrNonemptyFillReady {
  import S = BytecodeScanMachine
  import W = AssertionsConstraintOrNonemptyWire
  import H = AssertionsConstraintOrNonemptyFillHeap
  import I = AssertionsConstraintOrNonemptyItem
  type Word = S.Word
  type Byte = S.Byte
  lemma {:isolate_assertions} Ready(start: Word, end: Word, relative: Word, arrayptr: Word, initial: Word,
                                   children: seq<W.Child>, i: nat, prefix: seq<Word>, mem: seq<Byte>)
    requires i < |children| && |prefix| <= 949
    requires (initial as nat)+W.Cost(children)+160 < 0x10000000000000000
    requires H.Partial(mem,arrayptr,initial,children,i) && W.Layout(mem,start,end,relative,children) && end <= arrayptr
    ensures var body := W.Body(start,relative); var c := children[i];
      I.Admitted(end,start,body,body+32+|children|*32,body+32+i*32,arrayptr+32+i*32,arrayptr,c.position,W.Offset(body,c),c.kind,c.referenceRelative,c.length,W.Source(body,c),W.Free(initial,children,i),prefix+[7777],mem)
  {
    hide S.Store(); hide S.Load();
    W.Item(mem,start,end,relative,children,i);
    W.FreeStep(initial,children,i);
    assert initial <= W.Free(initial,children,i);
  }
}
