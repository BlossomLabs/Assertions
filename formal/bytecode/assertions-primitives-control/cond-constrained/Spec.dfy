// SPDX-License-Identifier: MIT
// Independent constrained RAW operand shape; no resolved/result premise.
include "Heap.dfy"
include "../cond-class/RawSpec.dfy"
module AssertionsCondConstrainedSpec {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import L = AssertionsConstraintLoopSpec
  import R = AssertionsConstrainedRawConnection
  import B = AssertionsConstrainedRawBefore
  import D = AssertionsCondRawSpec
  import P = AssertionsPrimitivePreparation
  import M = AssertionsRawResolveMemory
  import C = BytecodeCopyMemory
  type Word = S.Word
  type Byte = S.Byte
  datatype Operand = Operand(pointer: Word, bytesRelative: Word,
                             constraintsRelative: Word, length: Word,
                             constraints: seq<L.Constraint>)
  predicate Head(data: seq<Byte>, operand: Operand) {
    |data| < 0x10000000000000000 &&
    (operand.pointer as nat)+128 <= |data| &&
    (operand.pointer as nat)+operand.bytesRelative+32+operand.length <= |data| &&
    (operand.pointer as nat)+operand.constraintsRelative+32 <= |data| &&
    S.DataWord(data,operand.pointer+32) == 0 &&
    S.DataWord(data,operand.pointer+64) == operand.bytesRelative &&
    S.DataWord(data,operand.pointer+96) == operand.constraintsRelative &&
    S.DataWord(data,operand.pointer+operand.bytesRelative) == operand.length &&
    S.DataWord(data,operand.pointer+operand.constraintsRelative) == |operand.constraints|
  }
  function Offset(operand: Operand): Word
    requires (operand.pointer as nat)+operand.bytesRelative+32 < G.Modulus()
  { operand.pointer+operand.bytesRelative+32 }
  function Payload(data: seq<Byte>, operand: Operand): seq<Byte>
    requires Head(data,operand)
  { data[Offset(operand)..Offset(operand)+operand.length] }
  predicate Span(data: seq<Byte>, operand: Operand) {
    Head(data,operand) && |operand.constraints|*32 <= operand.length &&
    L.Layout(data,R.Base(operand.pointer,operand.constraintsRelative),operand.constraints) &&
    L.Passes(Payload(data,operand),data,R.Base(operand.pointer,operand.constraintsRelative),operand.constraints)
  }
  predicate Budget(free: Word, operand: Operand) {
    free%32 == 0 && 128 <= free &&
    (free as nat)+64+S.Round32(operand.length)+L.Cost(operand.constraints)+160 < 0x10000000000000000
  }
  predicate Heap(mem: seq<Byte>, free: Word, operand: Operand) {
    Budget(free,operand) && |mem|%32 == 0 && 96 <= |mem| <= free+32 && S.Load(mem,64) == free
  }
  lemma Prepared(ret: Word, entry: Word, index: Word, operand: Operand, free: Word,
                 prefix: seq<Word>, mem: seq<Byte>, data: seq<Byte>)
    requires Span(data,operand) && Heap(mem,free,operand) && |prefix| <= 944
    requires ret in {1770,1815,1017}
    ensures R.Admitted(ret,operand.pointer,free,entry,index,operand.bytesRelative,
                       operand.constraintsRelative,operand.length,free+32,operand.constraints,prefix,
                       P.EmptyAssertion(mem,free),data)
  {
    hide S.DataWord(); hide S.Window(); hide G.Decode();
    D.Labels();
    reveal B.FullRuntimeDestinations();
    reveal B.DestinationsChunk1(); reveal B.DestinationsChunk3();
    P.AssertionObject(mem,free);
    C.Rounded(operand.length);
    assert |S.Store(mem,64,free+32)| == |mem|;
    assert |P.EmptyAssertion(mem,free)| == free+32;
    assert M.Fits(P.EmptyAssertion(mem,free),free+32,Offset(operand),operand.length,data);
  }
}
