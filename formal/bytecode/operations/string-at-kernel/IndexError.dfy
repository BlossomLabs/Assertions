// SPDX-License-Identifier: MIT
// Exact strict-index custom error from fresh public-call memory. Native pending.
include "Kernel.dfy"
module OperationsStringAtIndexError {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import R = BytecodeScanRepresentation
  import I = OperationsStringAtInputs
  import K = OperationsStringAtKernel
  function Header():S.Word { 0xdf75cbae00000000000000000000000000000000000000000000000000000000 }
  function SelectorStored():seq<S.Byte> { S.Store(K.Initial(),128,Header()) }
  function IndexStored(word:S.Word):seq<S.Byte> { S.Store(SelectorStored(),132,word) }
  function Finished(word:S.Word,length:S.Word):seq<S.Byte> { S.Store(IndexStored(word),164,length) }
  lemma HeaderLiteral()
    ensures S.ShiftLeft(0x6fbae5d7,225)==Header()
    ensures G.Encode(Header(),32)[..4]==[0xdf,0x75,0xcb,0xae]
  { reveal S.ShiftLeft(); }
  lemma Frame(word:S.Word,length:S.Word)
    ensures |SelectorStored()|==160 && |IndexStored(word)|==192 && |Finished(word,length)|==224
    ensures S.Load(SelectorStored(),64)==128 && S.Load(IndexStored(word),64)==128 && S.Load(Finished(word,length),64)==128
    ensures S.Expand(K.Initial(),96)==K.Initial()
    ensures S.Expand(SelectorStored(),96)==SelectorStored()
    ensures S.Expand(IndexStored(word),96)==IndexStored(word)
    ensures S.Expand(Finished(word,length),96)==Finished(word,length)
  {
    K.InitialFits();R.StoredWord(K.Initial(),128,Header());R.StoredFrame(K.Initial(),128,Header(),64);
    R.StoredWord(SelectorStored(),132,word);R.StoredFrame(SelectorStored(),132,word,64);
    R.StoredWord(IndexStored(word),164,length);R.StoredFrame(IndexStored(word),164,length,64);
  }
  lemma Receipt(word:S.Word,length:S.Word)
    ensures G.Grow(Finished(word,length),196)[128..196]==I.Packet(I.InvalidByteIndex(word,length))
  {
    HeaderLiteral();Frame(word,length);
    R.StoredWord(K.Initial(),128,Header());R.StoredWord(SelectorStored(),132,word);R.StoredWord(IndexStored(word),164,length);
    assert SelectorStored()[128..132]==[0xdf,0x75,0xcb,0xae];
    assert IndexStored(word)[128..132]==SelectorStored()[128..132];
    assert Finished(word,length)[128..132]==IndexStored(word)[128..132];
    assert Finished(word,length)[132..164]==IndexStored(word)[132..164];
    assert Finished(word,length)[164..196]==G.Encode(length,32);
    assert Finished(word,length)[128..196]==Finished(word,length)[128..132]+Finished(word,length)[132..164]+Finished(word,length)[164..196];
  }
}
