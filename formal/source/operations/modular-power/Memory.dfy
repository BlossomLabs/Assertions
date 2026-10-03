include "../../../../proof-tools/dafnyevm/src/dafny/util/arrays.dfy"
include "Power.dfy"
module OperationsModularPowerMemory {
  import Arrays
  import B = OperationsBinaryLogModel
  import P = OperationsFullMulDivProduct
  import E = OperationsModularPowerEuclid
  function Radix(n: nat): nat
    ensures Radix(n) > 0
    decreases n
  { if n == 0 then 1 else 256*Radix(n-1) }
  lemma RadixBits(n: nat)
    ensures Radix(n) == B.Power(8*n)
    decreases n
  {
    B.KnownPowers();
    if n > 0 { RadixBits(n-1); B.PowerAdd(8,8*(n-1)); }
  }
  lemma WordRadix()
    ensures Radix(32) == B.Word
  { B.KnownPowers(); RadixBits(32); }
  predicate Bytes(s: seq<nat>) { forall i | 0 <= i < |s| :: s[i] < 256 }
  function Encode(value: nat,n: nat): seq<nat>
    ensures |Encode(value,n)| == n && Bytes(Encode(value,n))
    decreases n
  { if n == 0 then [] else Encode(P.Div(value,256),n-1)+[value%256] }
  function Pack(s: seq<nat>): nat
    decreases |s|
  { if |s| == 0 then 0 else Pack(s[..|s|-1])*256+s[|s|-1] }
  lemma RoundTrip(value: nat,n: nat)
    requires value < Radix(n)
    ensures Pack(Encode(value,n)) == value
    decreases n
  {
    if n > 0 {
      B.QuotientUpper(value,256,Radix(n-1));
      RoundTrip(P.Div(value,256),n-1);
      assert value == (value/256)*256+value%256;
    }
  }
  lemma PackBound(s: seq<nat>)
    requires Bytes(s)
    ensures Pack(s) < Radix(|s|)
    decreases |s|
  {
    if |s| > 0 {
      PackBound(s[..|s|-1]);
      B.ProductMonotone(Pack(s[..|s|-1])+1,Radix(|s|-1),256);
    }
  }
  function Word(value: nat): seq<nat>
    requires value < B.Word
    ensures |Word(value)| == 32 && Bytes(Word(value))
  { Encode(value,32) }
  lemma WordRoundTrip(value: nat)
    requires value < B.Word
    ensures Pack(Word(value)) == value
  { WordRadix(); RoundTrip(value,32); }
  function Store(memory: seq<nat>,offset: nat,value: nat): seq<nat>
    requires Bytes(memory) && value < B.Word && offset+32 <= |memory|
    ensures |Store(memory,offset,value)| == |memory| && Bytes(Store(memory,offset,value))
  {
    var encoded := Word(value);
    var result := Arrays.Copy(encoded,memory,offset);
    reveal Arrays.Copy();
    assert Bytes(result);
    result
  }
  function Load(memory: seq<nat>,offset: nat): nat
    requires Bytes(memory) && offset+32 <= |memory|
    ensures Load(memory,offset) < B.Word
  { WordRadix(); PackBound(memory[offset..offset+32]); Pack(memory[offset..offset+32]) }
  function CopyReply(memory: seq<nat>,offset: nat,data: seq<nat>): seq<nat>
    requires Bytes(memory) && Bytes(data) && offset+32 <= |memory|
    ensures |CopyReply(memory,offset,data)| == |memory| && Bytes(CopyReply(memory,offset,data))
  {
    var copied := if |data| < 32 then |data| else 32;
    var result := Arrays.Copy(data[..copied],memory,offset);
    reveal Arrays.Copy();
    assert Bytes(result);
    result
  }
  lemma ReplyLoad(memory: seq<nat>,offset: nat,value: nat)
    requires Bytes(memory) && offset+32 <= |memory| && value < B.Word
    ensures Load(CopyReply(memory,offset,Word(value)),offset) == value
  {
    WordRoundTrip(value);
    var reply := CopyReply(memory,offset,Word(value));
    forall i: nat | i < 32
      ensures reply[offset..offset+32][i] == Word(value)[i]
    { }
    assert reply[offset..offset+32] == Word(value);
  }
  predicate Heap(memory: seq<nat>,ptr: nat)
  { Bytes(memory) && 128 <= ptr && ptr+192 < B.Word && ptr+192 <= |memory| && memory[64..96] == Word(ptr) }
  lemma HeapPointer(memory: seq<nat>,ptr: nat)
    requires Heap(memory,ptr)
    ensures Load(memory,64) == ptr
  { WordRoundTrip(ptr); }
  function Request(base: nat,exponent: nat,modulus: nat): seq<nat>
    requires base < B.Word && exponent < B.Word && modulus < B.Word
    ensures |Request(base,exponent,modulus)| == 192
  { Word(32)+Word(32)+Word(32)+Word(base)+Word(exponent)+Word(modulus) }
}
