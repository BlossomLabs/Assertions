// SPDX-License-Identifier: MIT
// Exact signed prefix literal and full-width magnitude; native proof pending.
include "Memory.dfy"
include "Allocation.dfy"
module OperationsToStringSign {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import I = OperationsToStringInputs
  import K = OperationsToStringMemory
  import B = OperationsCaseFoldBinary
  function Prefix(word:S.Word):seq<S.Byte> { if I.Negative(word,true) then [45] else [] }
  function Free(word:S.Word):S.Word { if I.Negative(word,true) then 192 else 160 }
  function Allocated(word:S.Word):seq<S.Byte> { S.Store(K.Base(),64,Free(word)) }
  function Header(word:S.Word):seq<S.Byte> { S.Store(Allocated(word),128,|Prefix(word)|) }
  function Initial(word:S.Word):seq<S.Byte> {
    if I.Negative(word,true) then S.Store(Header(word),160,B.Cell(45)) else Header(word)
  }
  lemma EncodeTop(cell:S.Byte,width:nat)
    requires width>0
    ensures G.Encode(cell*G.Pow256(width-1),width)==[cell]+seq(width-1,i => 0)
    decreases width
  {
    if width>1 {
      assert cell*G.Pow256(width-1)==(cell*G.Pow256(width-2))*256;
      EncodeTop(cell,width-1);
      assert seq(width-2,i => 0)+[0]==seq(width-1,i => 0);
    }
  }
  lemma Ready(word:S.Word)
    ensures |Initial(word)|==Free(word) && |Initial(word)|%32==0
    ensures S.Load(Initial(word),64)==Free(word) && S.Load(Initial(word),128)==|Prefix(word)|
    ensures Initial(word)[160..160+|Prefix(word)|]==Prefix(word)
  {
    K.BaseFits();R.StoredWord(K.Base(),64,Free(word));R.StoredWord(Allocated(word),128,|Prefix(word)|);
    R.StoredFrame(Allocated(word),128,|Prefix(word)|,64);
    if I.Negative(word,true) {
      R.StoredWord(Header(word),160,B.Cell(45));R.StoredFrame(Header(word),160,B.Cell(45),64);R.StoredFrame(Header(word),160,B.Cell(45),128);
      B.CellWord(45);B.PowerLiteral();EncodeTop(45,32);
    }
  }
  lemma Magnitude(word:S.Word)
    ensures (G.Signed(word)<0) <==> I.Negative(word,true)
    ensures I.Magnitude(word,true)==(if I.Negative(word,true) then (G.Modulus()-word)%G.Modulus() else word)
    ensures I.Magnitude(word,true)<=G.Modulus()/2
  {}
}
