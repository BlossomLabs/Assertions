// SPDX-License-Identifier: MIT
include "../callback-result-error/Scalar.dfy"
module BytecodeApplyCallbackOutOfGasReturnMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import H = BytecodeApplyWrongCallbackMemory
  import R = BytecodeScanRepresentation
  import E = BytecodeScanErrorBytes
  import SC = BytecodeScanScalar
  function Selector(): S.Word { 0xd271060e }
  function Header(): S.Word { 0xd271060e00000000000000000000000000000000000000000000000000000000 }
  function Packet(): seq<S.Byte> { G.Encode(Selector(),4) }
  function Complete(mem: seq<S.Byte>,free: S.Word): seq<S.Byte>
    requires H.Fits(mem,free)
  { S.Store(mem,free,Header()) }
  lemma Literal()
    ensures S.ShiftLeft(0x69388307,225) == Header()
  {
    hide G.Shift(); reveal S.ShiftLeft();
    SC.ShiftDefinition(0x69388307,225);
  }
  lemma Layout(mem: seq<S.Byte>,free: S.Word)
    requires H.Fits(mem,free)
    ensures |Complete(mem,free)| >= free+32 && |Complete(mem,free)| >= |mem|
    ensures |Complete(mem,free)|%32 == 0
    ensures S.Load(Complete(mem,free),64) == free
  {
    R.StoredWord(mem,free,Header());
    R.StoredFrame(mem,free,Header(),64);
  }
  lemma Bytes(mem: seq<S.Byte>,free: S.Word)
    requires H.Fits(mem,free)
    ensures Complete(mem,free)[free..free+4] == Packet()
  {
    G.WordPower(); E.ShiftedPrefix(Selector(),28);
    R.StoredWord(mem,free,Header());
    assert Header() == Selector()*G.Pow256(28);
    assert Complete(mem,free)[free..free+4] == G.Encode(Header(),32)[..4];
  }
}
