// SPDX-License-Identifier: MIT
// Operations-specific representation bridges; mathematical development only.
// Existing machine semantics remain unchanged and consumer bytecode closure is separate.
include "../../../foundations/v3/MemoryFrames.dfy"
include "../../../foundations/v1/WordArithmetic.dfy"
include "/home/sem/assertions/proof-workspace/work/operations-code-closure-v3/sources/proof-workspace/work/code-bytecode-preparation/native/Machine.dfy"
module OperationsFoundationMemoryBridgeV1 {
  import M = OperationsCodeMachine
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import F = SharedFoundationMemoryFramesV3
  import W = SharedFoundationWordArithmetic

  lemma ModulusBridge()
    ensures M.Modulus() == G.Modulus()
  {}

  lemma EncodingBridge(value: nat, width: nat)
    ensures M.Encode(value,width) == G.Encode(value,width)
    decreases width
  {
    if width > 0 { EncodingBridge(value/256,width-1); }
  }

  lemma DecodingBridge(bytes: seq<M.Byte>)
    ensures M.Decode(bytes) == G.Decode(bytes)
    decreases |bytes|
  {
    if |bytes| > 0 { DecodingBridge(bytes[..|bytes|-1]); }
  }

  lemma ExpansionBridge(mem: seq<M.Byte>, extent: nat)
    requires |mem|%32 == 0
    ensures M.Grow(mem,extent) == S.Expand(mem,extent)
  {
    C.Rounded(extent);
    assert M.Round32(extent) == S.Round32(extent);
    if extent <= |mem| { assert S.Round32(extent) <= |mem|; }
  }

  lemma StoreBridge(mem: seq<M.Byte>, offset: M.Word, value: M.Word)
    requires |mem|%32 == 0
    ensures M.Store(mem,offset,value) == S.Store(mem,offset,value)
  {
    ExpansionBridge(mem,offset+32);
    EncodingBridge(value,32);
    assert G.Grow(S.Expand(mem,offset+32),offset+32) == S.Expand(mem,offset+32);
  }

  lemma CopyBridge(mem: seq<M.Byte>, destination: M.Word, source: M.Word, count: M.Word)
    requires |mem|%32 == 0
    ensures M.CopyMemory(mem,destination,source,count) == C.Memory(mem,destination,source,count)
  {
    if count > 0 {
      var extent := if destination >= source then destination+count else source+count;
      ExpansionBridge(mem,extent);
      var expanded := S.Expand(mem,extent);
      assert source+count <= |expanded| && destination+count <= |expanded|;
      assert S.Window(expanded,source,count) == expanded[source..source+count] by {
        forall i | 0 <= i < count
          ensures S.Window(expanded,source,count)[i] == expanded[source..source+count][i]
        {}
      }
      assert S.Expand(expanded,destination+count) == expanded;
    }
  }

  lemma StoreSpanFrame(mem: seq<M.Byte>, destination: M.Word, value: M.Word, start: nat, length: nat)
    requires |mem|%32 == 0 && start+length <= |mem|
    requires length == 0 || start+length <= destination || destination+32 <= start
    ensures M.Store(mem,destination,value)[start..start+length] == mem[start..start+length]
  {
    StoreBridge(mem,destination,value);
    F.StoreSpanFrame(mem,destination,value,start,length);
  }

  lemma CopySpanFrame(mem: seq<M.Byte>, destination: M.Word, source: M.Word, count: M.Word, start: nat, length: nat)
    requires |mem|%32 == 0 && start+length <= |mem|
    requires length == 0 || start+length <= destination || destination+count <= start
    ensures M.CopyMemory(mem,destination,source,count)[start..start+length] == mem[start..start+length]
  {
    CopyBridge(mem,destination,source,count);
    F.CopySpanFrame(mem,destination,source,count,start,length);
  }

  lemma WordRoundTrip(value: M.Word)
    ensures |M.Encode(value,32)| == 32
    ensures M.Decode(M.Encode(value,32)) == value
  {
    EncodingBridge(value,32);
    DecodingBridge(M.Encode(value,32));
    W.WordEncoding(value);
  }

  lemma AdditionOverflow(left: M.Word, right: M.Word)
    ensures M.Modulus() <= left+right <==> (left+right)%M.Modulus() < left
  {
    ModulusBridge();
    W.AdditionOverflow(left,right);
  }
}
