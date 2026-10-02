/*
 * Copyright 2022 ConsenSys Software Inc.
 * Licensed under the Apache License, Version 2.0.
 * See ../upstream/evm-dafny-e2e52e86/source/LICENSE for the full license.
 * Address-inclusive expansion adapted from pinned DafnyEVM memory.dfy.
 * The bridge uses the existing byte model and freshly proves compatibility.
 */
include "../../bytecode/copy/Memory.dfy"
module SharedFoundationExpansionBridge {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  type Byte = S.Byte
  function ExpandAt(mem: seq<Byte>, address: nat): seq<Byte>
  {
    if address < |mem| then mem else
    var end := (address/32+1)*32;
    mem+seq(end-|mem|, i => 0)
  }
  lemma ExclusiveExtent(mem: seq<Byte>, length: nat)
    requires |mem|%32 == 0 && length > 0
    ensures ExpandAt(mem,length-1) == S.Expand(mem,length)
  {
    C.Rounded(length);
    assert ((length-1)/32+1)*32 == S.Round32(length);
    if length <= |mem| { assert S.Round32(length) <= |mem|; }
  }
  lemma ZeroExtent(mem: seq<Byte>)
    ensures S.Expand(mem,0) == mem
  {}
  lemma UnalignedDifference()
    ensures ExpandAt([7],0) == [7]
    ensures |S.Expand([7],1)| == 32
    ensures ExpandAt([7],0) != S.Expand([7],1)
  {}
}
