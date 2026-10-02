// SPDX-License-Identifier: MIT
// Exact shared descriptor error packet in arbitrary represented aligned memory.
include "../../scans/ErrorBytes.dfy"
module BytecodeCollectionsDescriptorErrorMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import ER = BytecodeScanErrorBytes
  function Selector(): S.Word { 2590495014 }
  function Header(): S.Word { 69839607418959649974994886373187129380178483871789262225004511567993345409024 }
  function Bytes(position: S.Word): seq<S.Byte> { G.Encode(Selector(),4)+G.Encode(position,32) }
  function First(mem: seq<S.Byte>,fp: S.Word): seq<S.Byte> { S.Store(mem,fp,Header()) }
  function Complete(mem: seq<S.Byte>,fp: S.Word,position: S.Word): seq<S.Byte>
    requires fp+4 < G.Modulus()
  { S.Store(First(mem,fp),fp+4,position) }
  lemma DecodeZero(bytes: seq<S.Byte>)
    requires forall i :: 0 <= i < |bytes| ==> bytes[i] == 0
    ensures G.Decode(bytes) == 0
    decreases |bytes|
  { if |bytes| > 0 { DecodeZero(bytes[..|bytes|-1]); } }
  lemma PointerMemory(mem: seq<S.Byte>,fp: S.Word)
    requires |mem|%32 == 0 && 96 <= fp && S.Load(mem,64) == fp
    ensures 96 <= |mem| && S.Expand(mem,96) == mem
  {
    if |mem| < 96 {
      assert |mem| <= 64;
      var expanded := G.Grow(mem,96);
      assert forall i :: 64 <= i < 96 ==> expanded[i] == 0;
      assert forall i :: 0 <= i < |expanded[64..96]| ==> expanded[64..96][i] == 0;
      DecodeZero(expanded[64..96]);
      assert S.Load(mem,64) == 0;
      assert false;
    }
  }
  lemma Frames(mem: seq<S.Byte>,fp: S.Word,position: S.Word)
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && S.Load(mem,64) == fp
    ensures S.Load(First(mem,fp),64) == fp && S.Load(Complete(mem,fp,position),64) == fp
    ensures |Complete(mem,fp,position)| >= fp+36
    ensures Complete(mem,fp,position)[fp..fp+36] == Bytes(position)
    ensures 96 <= |mem| && S.Expand(mem,96) == mem
  {
    PointerMemory(mem,fp);
    R.StoredWord(mem,fp,Header());R.StoredFrame(mem,fp,Header(),64);
    R.StoredWord(First(mem,fp),fp+4,position);R.StoredFrame(First(mem,fp),fp+4,position,64);
    ER.PhysicalError(mem,fp,Selector(),Header(),position);
  }
}
