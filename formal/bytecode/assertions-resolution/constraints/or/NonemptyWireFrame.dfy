// SPDX-License-Identifier: MIT
// Preserve the independent source child-array layout through one constructive decoder image.
include "NonemptyWire.dfy"
include "NonemptyBounds.dfy"
module AssertionsConstraintOrNonemptyWireFrame {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import N = AssertionsConstraintOrNonemptyMemory
  import B = AssertionsConstraintOrNonemptyBounds
  import W = AssertionsConstraintOrNonemptyWire
  type Word = S.Word
  type Byte = S.Byte
  lemma {:isolate_assertions} Read(mem: seq<Byte>, free: Word, kind: Word, source: Word, length: Word, slot: Word, location: Word)
    requires |mem|%32 == 0 && |mem| <= free+32 && 128 <= free && free%32 == 0
    requires 96 <= location && location+32 <= |mem| && location+32 <= free
    requires location+32 <= slot || slot+32 <= location
    requires 96 <= slot && slot+32 <= free && source+length <= free
    requires (free as nat)+128+S.Round32(length) < G.Modulus()
    ensures S.Load(N.Construct(mem,free,kind,source,length,slot),location) == S.Load(mem,location)
  {
    hide N.Construct();
    B.Size(mem,free,kind,source,length,slot);
    var image := N.Construct(mem,free,kind,source,length,slot);
    assert location+32 <= |image|;
    forall i: nat | location <= i < location+32
      ensures image[i] == mem[i]
    { N.SourceFrame(mem,free,kind,source,length,slot,i); }
    assert image[location..location+32] == mem[location..location+32];
    assert G.Grow(image,location+32) == image && G.Grow(mem,location+32) == mem;
  }
  lemma {:isolate_assertions} Layout(mem: seq<Byte>, start: Word, end: Word, relative: Word, children: seq<W.Child>,
                                    free: Word, kind: Word, source: Word, length: Word, slot: Word)
    requires W.Layout(mem,start,end,relative,children)
    requires |mem|%32 == 0 && |mem| <= free+32 && 128 <= free && free%32 == 0
    requires end <= slot && 96 <= slot && slot+32 <= free && source+length <= free
    requires (free as nat)+128+S.Round32(length) < G.Modulus()
    ensures W.Layout(N.Construct(mem,free,kind,source,length,slot),start,end,relative,children)
  {
    hide N.Construct();
    B.Size(mem,free,kind,source,length,slot);
    var body := W.Body(start,relative);
    assert body == start+relative;
    Read(mem,free,kind,source,length,slot,start);
    Read(mem,free,kind,source,length,slot,body);
    forall i {:trigger children[i]} | 0 <= i < |children|
      ensures S.Load(N.Construct(mem,free,kind,source,length,slot),body+32+i*32) == children[i].position
      ensures S.Load(N.Construct(mem,free,kind,source,length,slot),W.Offset(body,children[i])+32) == children[i].kind
      ensures S.Load(N.Construct(mem,free,kind,source,length,slot),W.Offset(body,children[i])+64) == children[i].referenceRelative
      ensures S.Load(N.Construct(mem,free,kind,source,length,slot),W.Offset(body,children[i])+children[i].referenceRelative+32) == children[i].length
    {
      W.Item(mem,start,end,relative,children,i);
      Read(mem,free,kind,source,length,slot,body+32+i*32);
      Read(mem,free,kind,source,length,slot,W.Offset(body,children[i])+32);
      Read(mem,free,kind,source,length,slot,W.Offset(body,children[i])+64);
      Read(mem,free,kind,source,length,slot,W.Offset(body,children[i])+children[i].referenceRelative+32);
    }
  }
}
