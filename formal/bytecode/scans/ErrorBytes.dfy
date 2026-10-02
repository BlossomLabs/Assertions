// SPDX-License-Identifier: MIT
// Exact selector-plus-word error bytes from overlapping physical MSTOREs.
include "Representation.dfy"
module BytecodeScanErrorBytes {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  lemma ShiftedPrefix(selector: nat, right: nat)
    ensures G.Encode(selector*G.Pow256(right),4+right)[..4] == G.Encode(selector,4)
    decreases right
  {
    if right > 0 {
      assert G.Pow256(right) == 256*G.Pow256(right-1);
      assert (selector*G.Pow256(right))/256 == selector*G.Pow256(right-1);
      ShiftedPrefix(selector,right-1);
      assert G.Encode(selector*G.Pow256(right),4+right) == G.Encode(selector*G.Pow256(right-1),3+right)+[0];
    }
  }
  lemma PhysicalError(mem: seq<Byte>, offset: Word, selector: Word, header: Word, argument: Word)
    requires |mem|%32 == 0 && (offset as nat)+36 < G.Modulus()
    requires header == (selector as nat)*0x100000000000000000000000000000000000000000000000000000000
    ensures Store(Store(mem,offset,header),offset+4,argument)[offset..offset+36] == G.Encode(selector,4)+G.Encode(argument,32)
    ensures |Store(Store(mem,offset,header),offset+4,argument)| >= (offset as nat)+36
  {
    G.WordPower();
    assert G.Pow256(28) == 0x100000000000000000000000000000000000000000000000000000000;
    ShiftedPrefix(selector,28);
    R.StoredWord(mem,offset,header);
    var first := Store(mem,offset,header);
    assert first[offset..offset+4] == G.Encode(header,32)[..4];
    var expanded := Expand(first,(offset as nat)+36);
    assert expanded[..|first|] == first;
    R.StoredWord(first,offset+4,argument);
    var second := Store(first,offset+4,argument);
    assert second[offset..offset+4] == first[offset..offset+4];
    assert second[offset+4..offset+36] == G.Encode(argument,32);
    assert second[offset..offset+36] == second[offset..offset+4]+second[offset+4..offset+36];
  }
}
