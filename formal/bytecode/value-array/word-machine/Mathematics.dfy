// SPDX-License-Identifier: MIT
// Checked algebra for the exact sign-extension word representation.
include "Euclidean.dfy"
include "../byte-machine/Execution.dfy"
include "../../../abi/words/Semantics.dfy"
module BytecodeCollectionsArrayWordMathematics {
  import U = BytecodeCollectionsWordEuclidean
  import G = BytecodeGetterMachine
  import F = AbiFrames
  import A = AbiEncoding
  lemma PowerAgreement(n: nat)
    ensures G.Pow256(n) == F.Pow256(n)
    decreases n
  { if n > 0 { PowerAgreement(n-1); } }
  lemma PowerMonotone(n: nat,m: nat)
    requires n <= m
    ensures G.Pow256(n) <= G.Pow256(m)
    decreases m-n
  { if n < m { PowerMonotone(n,m-1); } }
  lemma PowerProduct(n: nat,m: nat)
    ensures G.Pow256(n+m) == G.Pow256(n)*G.Pow256(m)
    decreases m
  { if m > 0 { PowerProduct(n,m-1); } }
  lemma EightBits(n: nat)
    ensures A.Pow2(n+8) == 256*A.Pow2(n)
  {
    assert A.Pow2(n+1) == 2*A.Pow2(n);
    assert A.Pow2(n+2) == 4*A.Pow2(n);
    assert A.Pow2(n+3) == 8*A.Pow2(n);
    assert A.Pow2(n+4) == 16*A.Pow2(n);
    assert A.Pow2(n+5) == 32*A.Pow2(n);
    assert A.Pow2(n+6) == 64*A.Pow2(n);
    assert A.Pow2(n+7) == 128*A.Pow2(n);
    assert A.Pow2(n+8) == 256*A.Pow2(n);
  }
  lemma ByteBits(n: nat)
    ensures G.Pow256(n) == A.Pow2(8*n)
    decreases n
  { if n > 0 { ByteBits(n-1);EightBits(8*(n-1)); } }
  lemma PowerBound(n: nat)
    requires n <= 32
    ensures 0 < G.Pow256(n) <= G.Modulus()
  { G.WordPower();PowerMonotone(n,32); }
  lemma PowerDivides(n: nat)
    requires n <= 32
    ensures G.Modulus()%G.Pow256(n) == 0
  {
    G.WordPower();PowerProduct(n,32-n);
    var divisor := G.Pow256(n);var quotient := G.Pow256(32-n);
    assert G.Modulus() == divisor*quotient;
    hide G.Pow256();
    U.Multiple(divisor,quotient);
  }
  lemma PowerEven(n: nat)
    requires n > 0
    ensures G.Pow256(n)%2 == 0
  {
    var previous := G.Pow256(n-1);
    assert G.Pow256(n) == 256*previous && 256*previous == 2*(128*previous);
    hide G.Pow256();
    U.Multiple(2,128*previous);
  }
  function SignExtend(index: G.Word,word: G.Word): G.Word {
    if index >= 32 then word else
    PowerBound(index+1);
    var width := G.Pow256(index+1);
    var low := word%width;
    if low < width/2 then low else G.Modulus()-width+low
  }
  lemma TopRemainder(word: G.Word,width: nat)
    requires 0 < width <= G.Modulus() && G.Modulus()%width == 0
    requires G.Modulus()-width <= word
    ensures word%width == word-(G.Modulus()-width)
  {
    U.TopRemainder(word,G.Modulus(),width);
  }
  lemma FixedMeaning(index: G.Word,word: G.Word)
    requires index < 32
    ensures SignExtend(index,word) == word <==>
            word < G.Pow256(index+1)/2 || word >= G.Modulus()-G.Pow256(index+1)/2
  {
    PowerBound(index+1);PowerDivides(index+1);PowerEven(index+1);
    var width := G.Pow256(index+1);
    hide G.Pow256();hide SignExtend();
    U.SignFixed(word,G.Modulus(),width);
    reveal SignExtend();
  }
  lemma CanonicalSigned(bits: nat,word: G.Word)
    requires 8 <= bits <= 256 && bits%8 == 0
    ensures SignExtend(bits/8-1,word) == word <==> A.CanonicalWord(A.Signed(bits),word)
  {
    var index := bits/8-1;
    assert index < 32 && 8*(index+1) == bits;
    FixedMeaning(index,word);ByteBits(index+1);PowerAgreement(32);G.WordPower();
    assert G.Pow256(index+1) == A.Pow2(bits);
    assert A.Pow2(bits) == 2*A.Pow2(bits-1);
    assert G.Pow256(index+1)/2 == A.Pow2(bits-1);
  }
  lemma WideIdentity(index: G.Word,word: G.Word)
    requires index >= 31
    ensures SignExtend(index,word) == word
  {
    if index == 31 {
      G.WordPower();
      assert word%G.Pow256(32) == word;
    }
  }
}
