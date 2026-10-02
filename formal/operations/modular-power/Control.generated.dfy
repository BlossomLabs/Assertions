include "Model.dfy"
include "World.dfy"
module OperationsModularPowerSource {
  import B = OperationsBinaryLogModel
  import E = OperationsModularPowerEuclid
  import I = OperationsFullMulDivBits
  import M = OperationsModularPowerModel
  import Q = OperationsFullMulDivModel
  import P = OperationsModularPowerPower
  import H = OperationsFullMulDivSignedHelpers
  import S = OperationsFullMulDivSource
  import V = OperationsModularPowerInverseModel
  import T = OperationsFullMulDivInverse
  import C = OperationsModularPowerInverseConnection
  import R = OperationsModularPowerMemory
  import W = OperationsModularPowerWorld
  lemma AndOne(n: nat)
    ensures I.And(n,1) == n%2
  { }
  lemma BoolAnd(a: bool,b: bool)
    ensures I.And(B.Bool(a),B.Bool(b)) == B.Bool(a && b)
  { }
  lemma SignedParity(v: int)
    ensures I.And(v%B.Word,1) == Q.Abs(v)%2
  {
    B.KnownPowers();
    var residue := v%B.Word;
    AndOne(residue);
    T.Nested(v,B.Word,2);
    if v < 0 { E.DifferenceResidue(0,v,2); }
  }
  method Request(memory: seq<nat>,ptr: nat,base: nat,exponent: nat,modulus: nat)
    returns (updated: seq<nat>)
    requires R.Heap(memory,ptr) && base < B.Word && exponent < B.Word && modulus < B.Word
    ensures R.Bytes(updated) && |updated| == |memory|
    ensures updated[ptr..ptr+192] == R.Request(base,exponent,modulus)
    ensures forall i | 0 <= i < |memory| && (i < ptr || ptr+192 <= i) :: updated[i] == memory[i]
  {
    R.HeapPointer(memory,ptr);
    var p: nat := R.Load(memory,64);
    assert p == ptr;
    var state1 := R.Store(memory,p,32);
    var state2 := R.Store(state1,((p + 32) % B.Word),32);
    var state3 := R.Store(state2,((p + 64) % B.Word),32);
    var state4 := R.Store(state3,((p + 96) % B.Word),base);
    var state5 := R.Store(state4,((p + 128) % B.Word),exponent);
    var state6 := R.Store(state5,((p + 160) % B.Word),modulus);
    updated := state6;
    forall i: nat | i < 192
      ensures updated[ptr..ptr+192][i] == R.Request(base,exponent,modulus)[i]
    {
      if i < 32 { assert updated[ptr+i] == R.Word(32)[i]; }
      else if i < 64 { assert updated[ptr+i] == R.Word(32)[i-32]; }
      else if i < 96 { assert updated[ptr+i] == R.Word(32)[i-64]; }
      else if i < 128 { assert updated[ptr+i] == R.Word(base)[i-96]; }
      else if i < 160 { assert updated[ptr+i] == R.Word(exponent)[i-128]; }
      else { assert updated[ptr+i] == R.Word(modulus)[i-160]; }
    }
    forall i | 0 <= i < |memory| && (i < ptr || ptr+192 <= i)
      ensures updated[i] == memory[i]
    { }
  }
  method Attempt(base: nat,exponent: nat,modulus: nat,memory: seq<nat>,ptr: nat,reply: W.Reply)
    returns (done: bool,result: nat)
    requires base < B.Word && exponent < B.Word && 0 < modulus < B.Word
    requires R.Heap(memory,ptr) && W.Valid(base,exponent,modulus,reply)
    ensures done == (reply.success && |reply.data| == 32)
    ensures done ==> result == P.Power(base,exponent)%modulus
  {
    var state := Request(memory,ptr,base,exponent,modulus);
    var p: nat := ptr;
    assert reply.target == 5 && reply.input == state[p..p+192];
    // The source's let success executes STATICCALL before this size query.
    var success: nat := B.Bool(reply.success);
    ghost var previous := state;
    state := R.CopyReply(state,p,reply.data);
    var returnedSize: nat := |reply.data|;
    done := false; result := 0;
    BoolAnd(reply.success,returnedSize == 32);
    if I.And(success,B.Bool(returnedSize == 32)) != 0 {
      assert reply.success && |reply.data| == 32;
      R.ReplyLoad(previous,ptr,P.Power(base,exponent)%modulus);
      result := R.Load(state,p);
      done := true;
    }
  }
  method Pow(entryBase: nat,entryExponent: nat,modulus: nat,memory: seq<nat>,ptr: nat,world: (nat,nat,nat) -> W.Reply)
    returns (out: M.Outcome)
    requires entryBase < B.Word && entryExponent < B.Word && modulus < B.Word
    requires R.Heap(memory,ptr) && W.World(world)
    ensures out == M.UnsignedUnsigned(entryBase,entryExponent,modulus)
    ensures out.Value? ==> 0 <= out.result < modulus
  {
    B.KnownPowers();
    var base: nat := entryBase;
    var exponent: nat := entryExponent;
    if modulus == 0 { out := M.Panic(18); return; }
    var result: nat := (1%modulus);
    base := (base%modulus);
    P.Start(entryBase,entryExponent,modulus);
    if (exponent >= 4294967296) {
      var done,value := Attempt(base,exponent,modulus,memory,ptr,world(base,exponent,modulus));
      if done {
        assert value == P.Power(entryBase,entryExponent)%modulus;
        out := M.Value(value); return;
      }
    }
    while (exponent != 0)
      invariant base < modulus && result < modulus && exponent <= entryExponent
      invariant P.Multiply(result,P.Power(base,exponent))%modulus == P.Power(entryBase,entryExponent)%modulus
      decreases exponent
    {
      P.TailState(result,base,exponent,modulus);
      AndOne(exponent);
      if (I.And(exponent,1) != 0) { result := P.Multiply(result,base)%modulus; }
      exponent := (exponent/B.Power(1));
      if (exponent != 0) { base := P.Multiply(base,base)%modulus; }
    }
    P.Finish(result,base,modulus);
    assert result == P.Power(entryBase,entryExponent)%modulus;
    out := M.Value(result);
  }
  method Inverse(base: nat,modulus: nat) returns (out: M.Outcome)
    requires base < B.Word && modulus < B.Word
    ensures out == (if modulus == 0 then M.Panic(18)
                    else if modulus > 1 && E.Gcd(modulus,base%modulus) != 1 then M.MissingInverse(base,modulus)
                    else M.Value(V.Spec(base,modulus)))
    ensures out.Value? ==> 0 <= out.result < B.Word
  {
    var inverse: nat := C.Connection(base,modulus);
    if (inverse == 0) {
      if modulus == 0 { out := M.Panic(18); return; }
      if ((1%modulus) != 0) { out := M.MissingInverse(base,modulus); return; }
    }
    out := M.Value(inverse);
  }
  method Restore(value: nat,negative: bool) returns (result: int)
    requires value < Q.Half
    ensures result == (if negative then -(value as int) else value as int)
    ensures Q.Signed(result)
  {
    H.SignedMagnitudeCorrect(value,negative);
    var restored := H.SignedMagnitudeImpl(value,negative);
    assert restored.Ok?;
    result := restored.value;
  }
  method UnsignedUnsigned(a: nat,exponent: nat,m: nat,memory: seq<nat>,ptr: nat,world: (nat,nat,nat) -> W.Reply)
    returns (out: M.Outcome)
    requires a < B.Word && exponent < B.Word && m < B.Word
    requires R.Heap(memory,ptr) && W.World(world)
    ensures out == M.UnsignedUnsigned(a,exponent,m)
  { out := Pow(a,exponent,m,memory,ptr,world); }
  method SignedUnsigned(a: int,exponent: nat,m: int,memory: seq<nat>,ptr: nat,world: (nat,nat,nat) -> W.Reply)
    returns (out: M.Outcome)
    requires Q.Signed(a) && exponent < B.Word && Q.Signed(m)
    requires R.Heap(memory,ptr) && W.World(world)
    ensures out == M.SignedUnsigned(a,exponent,m)
  {
    Q.Magnitude(a); Q.Magnitude(m);
    H.MagnitudeCorrect(a); H.MagnitudeCorrect(m);
    var base: nat := H.MagnitudeImpl(a) as nat;
    var modulus: nat := H.MagnitudeImpl(m) as nat;
    out := Pow(base,exponent,modulus,memory,ptr,world);
    if out.Panic? { return; }
    AndOne(exponent);
    var result := Restore(out.result as nat,((a < 0) && (I.And(exponent,1) != 0)));
    out := M.Value(result);
  }
  method UnsignedSigned(a: nat,exponent: int,m: nat,memory: seq<nat>,ptr: nat,world: (nat,nat,nat) -> W.Reply)
    returns (out: M.Outcome)
    requires a < B.Word && Q.Signed(exponent) && m < B.Word
    requires R.Heap(memory,ptr) && W.World(world)
    ensures out == M.UnsignedSigned(a,exponent,m)
  {
    Q.Magnitude(exponent); H.MagnitudeCorrect(exponent);
    var base: nat := a;
    if (exponent < 0) {
      out := Inverse(a,m);
      if !out.Value? { return; }
      base := out.result as nat;
    }
    var power: nat := H.MagnitudeImpl(exponent) as nat;
    out := Pow(base,power,m,memory,ptr,world);
  }
  method SignedSigned(a: int,exponent: int,m: int,memory: seq<nat>,ptr: nat,world: (nat,nat,nat) -> W.Reply)
    returns (out: M.Outcome)
    requires Q.Signed(a) && Q.Signed(exponent) && Q.Signed(m)
    requires R.Heap(memory,ptr) && W.World(world)
    ensures out == M.SignedSigned(a,exponent,m)
  {
    Q.Magnitude(a); Q.Magnitude(exponent); Q.Magnitude(m);
    H.MagnitudeCorrect(a); H.MagnitudeCorrect(exponent); H.MagnitudeCorrect(m);
    var base: nat := H.MagnitudeImpl(a) as nat;
    var modulus: nat := H.MagnitudeImpl(m) as nat;
    if (exponent < 0) {
      out := Inverse(base,modulus);
      if !out.Value? { return; }
      base := out.result as nat;
    }
    var power: nat := H.MagnitudeImpl(exponent) as nat;
    out := Pow(base,power,modulus,memory,ptr,world);
    if out.Panic? { return; }
    SignedParity(exponent);
    var result := Restore(out.result as nat,((a < 0) && (I.And(((exponent)%B.Word),1) != 0)));
    out := M.Value(result);
  }
  method SquareWitness()
  {
    var base: nat := 2;
    var result: nat := 3;
    var modulus: nat := 5;
    var square := P.Multiply(base,base)%modulus;
    assert square == 4;
  }
}
