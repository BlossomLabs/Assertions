// SPDX-License-Identifier: MIT
include "../../copy/Execution.dfy"
include "../../scans/Representation.dfy"
module BytecodeApplyTemplateMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import M = BytecodeCopyMachine
  import R = BytecodeScanRepresentation
  function Quot(length: S.Word): S.Word
    requires length < 0x10000000000000000
  { ((length as nat)+31)/32 }
  function Rounded(length: S.Word): S.Word
    requires length < 0x10000000000000000
  { Quot(length)*32 }
  function Free(fp: S.Word,length: S.Word): S.Word
    requires fp < 0x20000000000000000 && length < 0x10000000000000000
  { fp+Rounded(length)+32 }
  function Pointer(mem: seq<S.Byte>,fp: S.Word,length: S.Word): seq<S.Byte>
    requires fp < 0x20000000000000000 && length < 0x10000000000000000
  { S.Store(mem,64,Free(fp,length)) }
  function Head(mem: seq<S.Byte>,fp: S.Word,length: S.Word): seq<S.Byte>
    requires fp < 0x20000000000000000 && length < 0x10000000000000000
  { S.Store(Pointer(mem,fp,length),fp,length) }
  function Copied(mem: seq<S.Byte>,fp: S.Word,offset: S.Word,length: S.Word,data: seq<S.Byte>): seq<S.Byte>
    requires fp < 0x20000000000000000 && length < 0x10000000000000000
  { C.Calldata(Head(mem,fp,length),fp+32,offset,length,data) }
  function Complete(mem: seq<S.Byte>,fp: S.Word,offset: S.Word,length: S.Word,data: seq<S.Byte>): seq<S.Byte>
    requires fp < 0x20000000000000000 && length < 0x10000000000000000
  { S.Store(Copied(mem,fp,offset,length,data),fp+32+length,0) }
  lemma Arithmetic(fp: S.Word,length: S.Word)
    requires fp < 0x20000000000000000 && length < 0x10000000000000000
    ensures Quot(length) == (length+31)/32
    ensures Rounded(length) == ((length as nat)+31)/32*32
    ensures length <= Rounded(length) < length+32
    ensures Free(fp,length) == fp+Rounded(length)+32 < 0x40000000000000000
    ensures fp+32+length < G.Modulus()
  {}
  lemma Bounds(mem: seq<S.Byte>,fp: S.Word,length: S.Word)
    requires |mem| < 0x40000000000000000 && |mem|%32 == 0
    requires fp < 0x20000000000000000 && length < 0x10000000000000000
    ensures |Head(mem,fp,length)| < G.Modulus()
    ensures M.Fits(Head(mem,fp,length),fp+32,0,length,false)
  {
    Arithmetic(fp,length);
    R.StoredWord(mem,64,Free(fp,length));
    R.StoredWord(Pointer(mem,fp,length),fp,length);
    C.Rounded(fp+32+length);
  }
}
