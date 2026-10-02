// SPDX-License-Identifier: MIT
// Compiler-gated exact public unpack source composition; edit this template only.
include "Control.generated.dfy"

module CollectionsValueCodecUnpackSource {
  import Exact = AbiExactOutcomeSpec
  import ExactSource = AbiExactOutcomeSource
  import Ctrl = CollectionsValueCodecControl
  import opened AbiFrames
  import opened AbiEncoding
  import opened AbiValidation
  import opened AbiByteSemantics
  import opened AbiBytesSource
  import opened AbiShapeSemantics
  import opened AbiParserSpec
  import opened AbiTupleSemantics
  import opened AbiConnectionModel
  import opened AbiConnectionStatic
  import opened AbiDynamicSemantics
  import opened AbiDynamicSource
  import opened AbiCursorSource
  import opened AbiCursorSemantics
  import opened AbiConstructionMemory
  import opened AbiConstructionSplitting

  ghost method StaticSliceWidth(words: nat) returns (width: nat)
    requires Uint(words*32)
    ensures width == words*32
  { width := (words * 32); }

  ghost method {:isolate_assertions} SplitLoop(t: seq<Byte>, encoded: seq<Byte>, s: Descriptor,
                                               count: nat, words: nat, initialTail: nat)
    returns (values: seq<seq<Byte>>, r: Outcome)
    requires Uint(|t|) && Uint(|encoded|) && Uint(count)
    requires Admissible(s) && t == Render(s)
    requires words == Width(s) && initialTail == count*words*32 && 64+initialTail <= |encoded|
    requires WellFormed(TypeOf(s))
    requires Types(TypesOf(Copies(s,count))) && Below(Array(TypeOf(s)),TypesOf(Copies(s,count)))
    requires !Dyn(s) ==> WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]).Parsed?
    ensures r.Panic? ==> r.code == 17 && !CursorRoom(s,|encoded|)
    ensures !r.Panic? ==> r.Ok? == WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]).Parsed?
    ensures Dyn(s) ==> r == Exact.Elements(s,encoded,64,count,0,initialTail)
    ensures !Dyn(s) ==> r == Ok(initialTail)
    ensures r.Ok? ==> r.used == WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]).used && 64+r.used <= |encoded|
    ensures r.Ok? ==> WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]).value.Items?
    ensures r.Ok? ==> (forall j :: 0 <= j < |WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]).value.values| ==>
                                     WellTyped(TypeOf(s),WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]).value.values[j]))
    ensures r.Ok? ==> values == Encodings(TypeOf(s),WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]).value.values)
  {
    ModelType(s); ArrayTypes(Dynamic(s),count); Positive(s);
    var owner := Array(TypeOf(s));
    var types := TypesOf(Copies(s,count));
    var bs := encoded[64..];
    var decoded: seq<Value> := [];
    values := [];
    var i: nat := 0;
    var tail := initialTail;
    while i < count
      invariant i <= count && initialTail <= tail && 64+tail <= |encoded|
      invariant i*words*32+ListHead(types[i..]) == initialTail
      invariant WalkFields(owner,types,bs,0,initialTail) == Prefix(decoded,WalkFields(owner,types[i..],bs,i*words*32,tail))
      invariant |decoded| == i && (forall j :: 0 <= j < i ==> WellTyped(TypeOf(s),decoded[j]))
      invariant values == Encodings(TypeOf(s),decoded)
      invariant Dyn(s) ==> Exact.Elements(s,encoded,64,count,0,initialTail) == Exact.Elements(s,encoded,64,count,i,tail)
      invariant !Dyn(s) ==> tail == initialTail
      decreases count-i
    {
      var rest := types[i..];
      assert rest[0] == TypeOf(s) && rest[1..] == types[i+1..];
      HeadAppend(types,i);
      var position := ArrayPosition(encoded,64,count,words,i);
      var start := if Dyn(s) then tail else i*words*32;
      var child: Outcome;
      var nextTail := tail;
      var nextValue: seq<Byte>;
      if Dyn(s) {
        var offset := ArrayOffset(encoded,position.used,tail);
        assert bs[i*words*32..i*words*32+32] == encoded[position.used..position.used+32];
        if !offset.Ok? { r := offset; return; }
        child := ExactSource.FullBody(t,0,|t|,encoded,64+tail,s);
        if child.Panic? { r := child; return; }
        assert bs[tail..] == encoded[64+tail..];
        if !child.Ok? { r := child; return; }
        assert position.used == 64+i*Width(s)*32;
        assert WordSpec(encoded,64+i*Width(s)*32) == Ok(tail);
        Exact.ElementsStep(s,encoded,64,count,i,tail,child);
        var sliced: seq<Byte>; var copied: Outcome;
        sliced,copied := Slice(encoded,64+tail,child.used);
        nextValue := Word(32)+sliced;
        var advanced := ArrayTailAdvance(encoded,64,tail,child.used);
        nextTail := advanced.used;
      } else {
        assert WalkFields(owner,types,bs,0,initialTail).Fields?;
        assert WalkFields(owner,rest,bs,i*words*32,tail).Fields?;
        assert Walk(TypeOf(s),bs[start..]).Parsed?;
        StaticExtent(TypeOf(s),bs[start..]);
        child := Ok(words*32);
        var copied: Outcome;
        var width := StaticSliceWidth(words);
        nextValue,copied := Slice(encoded,position.used,width);
      }
      var parsed := Walk(TypeOf(s),bs[start..]);
      assert parsed.Parsed? && parsed.used == child.used;
      WalkSound(TypeOf(s),bs[start..]);
      assert bs[start..][..child.used] == encoded[64+start..64+start+child.used];
      assert nextValue == Encode(TypeOf(s),parsed.value);
      var remaining := WalkFields(owner,rest[1..],bs,(i+1)*words*32,nextTail);
      assert WalkFields(owner,rest,bs,i*words*32,tail) == Prefix([parsed.value],remaining);
      PrefixStep(decoded,parsed.value,remaining);
      EncodingsAppend(TypeOf(s),decoded,parsed.value);
      decoded := decoded+[parsed.value];
      values := values+[nextValue];
      tail := nextTail;
      i := i+1;
    }
    r := Ok(tail);
  }

  ghost method {:isolate_assertions} UnpackParsed(t: seq<Byte>, encoded: seq<Byte>, s: Descriptor)
    returns (values: seq<seq<Byte>>, r: Outcome)
    requires Uint(|t|) && Uint(|encoded|) && Admissible(s) && t == Render(s)
    ensures WellFormed(Array(TypeOf(s)))
    ensures r == Exact.Validate(Dynamic(s),encoded)
    ensures r.Panic? ==> r.code == 17 && !CursorRoom(s,|encoded|)
    ensures !r.Panic? ==> r.Ok? == Validate(Array(TypeOf(s)),encoded).Parsed?
    ensures r.Ok? ==> Validate(Array(TypeOf(s)),encoded).value.Items?
    ensures r.Ok? ==> WellTyped(Array(TypeOf(s)),Validate(Array(TypeOf(s)),encoded).value)
    ensures r.Ok? ==> values == Encodings(TypeOf(s),Validate(Array(TypeOf(s)),encoded).value.values)
  {
    reveal Exact.Body();
    ModelType(s); Positive(s);
    values := [];
    var first := ReadWord(encoded,0);
    if !first.Ok? { r := first; return; }
    assert Ctrl.FirstMismatch(first.used) == (first.used != 32);
    if Ctrl.FirstMismatch(first.used) { r := Invalid(0); return; }
    var counted := ReadWord(encoded,32);
    if !counted.Ok? { r := counted; return; }
    var count := counted.used;
    var words := Width(s);
    ArrayTypes(Dynamic(s),count);
    ArrayEncodingView(s,encoded,count);
    var frame := WalkFrame(Array(TypeOf(s)),TypesOf(Copies(s,count)),encoded[64..]);
    var head := ArrayHead(encoded,64,count,words);
    if !head.Ok? { assert frame.Rejected?; r := head; return; }
    AbiTupleWords.CursorArithmetic(64,words,count);
    assert encoded[32..][32..] == encoded[64..];
    if !Dyn(s) {
      var checked := StaticCopies(t,0,|t|,encoded,64,s,count);
      if checked.Panic? { r := checked; return; }
      StaticFrame(s,count,Array(TypeOf(s)),encoded,64);
      if !checked.Ok? { assert frame.Rejected?; r := checked; return; }
    }
    values,r := SplitLoop(t,encoded,s,count,words,head.used);
    if !r.Ok? { assert !r.Panic? ==> frame.Rejected?; return; }
    assert Ctrl.TailMismatch(r.used,|encoded|) == (64+r.used != |encoded|);
    if Ctrl.TailMismatch(r.used,|encoded|) { r := Invalid(64+r.used); return; }
    ValidationSound(Array(TypeOf(s)),encoded);
    r := Ok(0);
  }
}
