// SPDX-License-Identifier: MIT
// Independent admitted RAW operand and concrete preparation heap, not trace fixtures.
include "Spec.dfy"
include "../Preparation.dfy"
include "../../assertions-resolution/raw/Connection.dfy"
include "../gather-composition/CallerElementSpec.dfy"
module AssertionsCondRawSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = AssertionsRawResolve
  import M = AssertionsRawResolveMemory
  import P = AssertionsPrimitivePreparation
  import D = AssertionsGatherCallerSpec
  import Q = BytecodeScanRepresentation
  import C = BytecodeCopyMemory
  type Word = S.Word
  type Byte = S.Byte
  datatype Operand = Operand(pointer: Word, bytesRelative: Word, constraintsRelative: Word, length: Word)
  predicate Span(data: seq<Byte>, operand: Operand) {
    |data| < 0x10000000000000000 && operand.pointer+128 <= |data| &&
    operand.pointer+operand.bytesRelative+32+operand.length <= |data| &&
    operand.pointer+operand.constraintsRelative+32 <= |data| &&
    S.DataWord(data,operand.pointer+32) == 0 &&
    S.DataWord(data,operand.pointer+64) == operand.bytesRelative &&
    S.DataWord(data,operand.pointer+96) == operand.constraintsRelative &&
    S.DataWord(data,operand.pointer+operand.bytesRelative) == operand.length &&
    S.DataWord(data,operand.pointer+operand.constraintsRelative) == 0
  }
  function Offset(operand: Operand): Word
    requires operand.pointer+operand.bytesRelative+32 < G.Modulus()
  { operand.pointer+operand.bytesRelative+32 }
  function Payload(data: seq<Byte>, operand: Operand): seq<Byte>
    requires Span(data,operand)
  { data[Offset(operand)..Offset(operand)+operand.length] }
  predicate Heap(mem: seq<Byte>, free: Word, operand: Operand) {
    |mem|%32 == 0 && 96 <= |mem| <= free+32 && free%32 == 0 && 128 <= free &&
    free+S.Round32(operand.length)+128 < 0x10000000000000000 && S.Load(mem,64) == free
  }
  lemma Labels()
    ensures 1770 in R.FullRuntimeDestinations() && 1815 in R.FullRuntimeDestinations() && 1017 in R.FullRuntimeDestinations()
    ensures 1783 in D.RuntimeDestinations()
  {
    reveal R.FullRuntimeDestinations(); reveal R.DestinationsChunk1(); reveal R.DestinationsChunk3();
    reveal D.RuntimeDestinations(); reveal D.Chunk3();
  }
  lemma Prepared(mem: seq<Byte>, free: Word, operand: Operand, data: seq<Byte>)
    requires Heap(mem,free,operand) && Span(data,operand)
    ensures S.Load(P.EmptyAssertion(mem,free),64) == free+32
    ensures S.Load(P.EmptyAssertion(mem,free),free) == 0
    ensures M.Fits(P.EmptyAssertion(mem,free),free+32,Offset(operand),operand.length,data)
  {
    hide S.DataWord(); hide S.Window(); hide G.Decode();
    P.AssertionObject(mem,free);
    C.Rounded(operand.length);
    assert |S.Store(mem,64,free+32)| == |mem|;
    assert |P.EmptyAssertion(mem,free)| == free+32;
  }
  lemma Admitted(ret: Word, entry: Word, index: Word, operand: Operand, free: Word, prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>)
    requires Span(data,operand) && Heap(mem,free,operand) && |prefix| <= 960
    requires ret in {1770,1815,1017}
    ensures R.Admitted(ret,operand.pointer,free,entry,index,operand.bytesRelative,operand.constraintsRelative,operand.length,free+32,prefix,P.EmptyAssertion(mem,free),data)
  {
    hide S.DataWord(); hide S.Window(); hide G.Decode();
    Labels(); Prepared(mem,free,operand,data);
  }
}
