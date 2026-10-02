// SPDX-License-Identifier: MIT
// Exact two-MCOPY signed decimal concatenation; native proof pending.
include "Sign.dfy"
include "../tostring-engine/Body.dfy"
module OperationsToStringConcatMemory {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import C = BytecodeCopyMemory
  import R = BytecodeScanRepresentation
  import I = OperationsToStringInputs
  import N = OperationsToStringSign
  import K = OperationsToStringFillMemory
  import D = OperationsToStringDecimal
  import B = OperationsToStringBody
  import Q = OperationsToStringReturnKernel
  import T = OperationsSerializerMemoryTranslation
  function Magnitude(word:S.Word):S.Word { I.Magnitude(word,true) }
  function Length(word:S.Word):S.Word
    ensures 1<=Length(word)<=78
  { B.Length(Magnitude(word)) }
  function Minus(word:S.Word):S.Word { |N.Prefix(word)| }
  function Free(word:S.Word):S.Word { N.Free(word)+32+S.Round32(Length(word)) }
  function End(word:S.Word):S.Word { Free(word)+32+Minus(word)+Length(word) }
  predicate Input(mem:seq<S.Byte>,word:S.Word) {
    K.Ready(mem,N.Free(word),Length(word)) &&
    K.Payload(mem,N.Free(word),Length(word))==I.Render(Magnitude(word),false) &&
    |mem|==Free(word) && S.Load(mem,128)==Minus(word) && mem[160..160+Minus(word)]==N.Prefix(word)
  }
  function FirstCopy(mem:seq<S.Byte>,word:S.Word):seq<S.Byte> { C.Memory(mem,Free(word)+32,160,Minus(word)) }
  function FirstZero(mem:seq<S.Byte>,word:S.Word):seq<S.Byte> { S.Store(FirstCopy(mem,word),Free(word)+32+Minus(word),0) }
  function SecondCopy(mem:seq<S.Byte>,word:S.Word):seq<S.Byte> { C.Memory(FirstZero(mem,word),Free(word)+32+Minus(word),N.Free(word)+32,Length(word)) }
  function SecondZero(mem:seq<S.Byte>,word:S.Word):seq<S.Byte> { S.Store(SecondCopy(mem,word),End(word),0) }
  function Header(mem:seq<S.Byte>,word:S.Word):seq<S.Byte> { S.Store(SecondZero(mem,word),Free(word),Minus(word)+Length(word)) }
  function Final(mem:seq<S.Byte>,word:S.Word):seq<S.Byte> { S.Store(Header(mem,word),64,End(word)) }
  lemma Bounds(word:S.Word)
    ensures 1<=Length(word)<=78 && Minus(word)<=1
    ensures N.Free(word)==160 || N.Free(word)==192
    ensures 224<=Free(word)<=320 && Free(word)%32==0
    ensures End(word)+128<G.Modulus()
    ensures N.Prefix(word)+I.Render(Magnitude(word),false)==I.Render(word,true)
  { D.WordDigits(Magnitude(word));D.Length(Magnitude(word)); }
  lemma StoreFrame(mem:seq<S.Byte>,at:S.Word,value:S.Word,low:nat,high:nat)
    requires low<=high<=|mem| && (high<=at || at+32<=low)
    ensures |S.Store(mem,at,value)|>=|mem| && S.Store(mem,at,value)[low..high]==mem[low..high]
  {
    var next:=S.Store(mem,at,value);var expanded:=S.Expand(mem,at+32);assert expanded[..|mem|]==mem;
    forall i:nat {:trigger next[i]} | low<=i<high ensures next[i]==mem[i] {
      if i<at { assert next[i]==expanded[i]; } else { assert at+32<=i;assert next[i]==expanded[i]; }
    }
  }
  lemma CopyFrame(mem:seq<S.Byte>,dst:S.Word,src:S.Word,count:S.Word,low:nat,high:nat)
    requires low<=high<=|mem| && (high<=dst || dst+count<=low)
    ensures |C.Memory(mem,dst,src,count)|>=|mem| && C.Memory(mem,dst,src,count)[low..high]==mem[low..high]
  {
    C.MemorySize(mem,dst,src,count);var next:=C.Memory(mem,dst,src,count);
    forall i:nat {:trigger next[i]} | low<=i<high ensures next[i]==mem[i] { C.MemoryFrame(mem,dst,src,count,i); }
  }
  lemma LoadFrame(mem:seq<S.Byte>,next:seq<S.Byte>,at:S.Word)
    requires at+32<=|mem| && at+32<=|next| && next[at..at+32]==mem[at..at+32]
    ensures S.Load(next,at)==S.Load(mem,at)
  { R.WordProjection(mem,at);R.WordProjection(next,at);R.WindowFits(mem,at,32);R.WindowFits(next,at,32); }
  lemma CopySpan(mem:seq<S.Byte>,dst:S.Word,src:S.Word,count:S.Word)
    requires count>0 && src+count<=|mem|
    ensures dst+count<=|C.Memory(mem,dst,src,count)| && C.Memory(mem,dst,src,count)[dst..dst+count]==mem[src..src+count]
  {
    C.MemorySize(mem,dst,src,count);var next:=C.Memory(mem,dst,src,count);
    forall i:nat {:trigger next[dst+i]} | i<count ensures next[dst+i]==mem[src+i] { C.MemoryValue(mem,dst,src,count,i); }
  }
  lemma Stage(mem:seq<S.Byte>,word:S.Word,id:nat)
    requires Input(mem,word) && id<=6
    ensures var next:=if id==0 then mem else if id==1 then FirstCopy(mem,word) else if id==2 then FirstZero(mem,word) else if id==3 then SecondCopy(mem,word) else if id==4 then SecondZero(mem,word) else if id==5 then Header(mem,word) else Final(mem,word);
            |next|>=|mem| && |next|%32==0 && |next|<G.Modulus() && S.Expand(next,96)==next
  {
    Bounds(word);var p:=Free(word);var m:=Minus(word);var n:=Length(word);
    C.MemorySize(mem,p+32,160,m);C.Rounded(p+32+m);
    R.StoredWord(FirstCopy(mem,word),p+32+m,0);
    C.MemorySize(FirstZero(mem,word),p+32+m,N.Free(word)+32,n);C.Rounded(p+32+m+n);
    R.StoredWord(SecondCopy(mem,word),End(word),0);R.StoredWord(SecondZero(mem,word),p,m+n);R.StoredWord(Header(mem,word),64,End(word));
    var next:=if id==0 then mem else if id==1 then FirstCopy(mem,word) else if id==2 then FirstZero(mem,word) else if id==3 then SecondCopy(mem,word) else if id==4 then SecondZero(mem,word) else if id==5 then Header(mem,word) else Final(mem,word);
    C.RoundedMonotone(96,|next|);
  }
  lemma First(mem:seq<S.Byte>,word:S.Word)
    requires Input(mem,word)
    ensures S.Load(FirstZero(mem,word),64)==Free(word)
    ensures S.Load(FirstZero(mem,word),N.Free(word))==Length(word)
    ensures FirstZero(mem,word)[N.Free(word)+32..N.Free(word)+32+Length(word)]==I.Render(Magnitude(word),false)
    ensures FirstZero(mem,word)[Free(word)+32..Free(word)+32+Minus(word)]==N.Prefix(word)
  {
    Bounds(word);var p:=Free(word);var base:=N.Free(word);var m:=Minus(word);var n:=Length(word);
    Stage(mem,word,1);Stage(mem,word,2);R.StoredWord(FirstCopy(mem,word),p+32+m,0);
    if m>0 { CopySpan(mem,p+32,160,m);StoreFrame(FirstCopy(mem,word),p+32+m,0,p+32,p+32+m); }
    else { assert N.Prefix(word)==[]; }
    CopyFrame(mem,p+32,160,m,64,96);StoreFrame(FirstCopy(mem,word),p+32+m,0,64,96);LoadFrame(mem,FirstZero(mem,word),64);
    CopyFrame(mem,p+32,160,m,base,base+32+n);StoreFrame(FirstCopy(mem,word),p+32+m,0,base,base+32+n);LoadFrame(mem,FirstZero(mem,word),base);
  }
  lemma FreePreserved(mem:seq<S.Byte>,word:S.Word,id:nat)
    requires Input(mem,word) && id<=5
    ensures var next:=if id==0 then mem else if id==1 then FirstCopy(mem,word) else if id==2 then FirstZero(mem,word) else if id==3 then SecondCopy(mem,word) else if id==4 then SecondZero(mem,word) else Header(mem,word);
            S.Load(next,64)==Free(word)
  {
    Bounds(word);var p:=Free(word);var m:=Minus(word);var n:=Length(word);
    CopyFrame(mem,p+32,160,m,64,96);LoadFrame(mem,FirstCopy(mem,word),64);
    StoreFrame(FirstCopy(mem,word),p+32+m,0,64,96);LoadFrame(FirstCopy(mem,word),FirstZero(mem,word),64);
    CopyFrame(FirstZero(mem,word),p+32+m,N.Free(word)+32,n,64,96);LoadFrame(FirstZero(mem,word),SecondCopy(mem,word),64);
    StoreFrame(SecondCopy(mem,word),End(word),0,64,96);LoadFrame(SecondCopy(mem,word),SecondZero(mem,word),64);
    StoreFrame(SecondZero(mem,word),p,m+n,64,96);LoadFrame(SecondZero(mem,word),Header(mem,word),64);
  }
  lemma Ready(mem:seq<S.Byte>,word:S.Word)
    requires Input(mem,word)
    ensures Q.Layout(Final(mem,word),I.Render(word,true),Free(word),End(word))
  {
    Bounds(word);First(mem,word);var p:=Free(word);var m:=Minus(word);var n:=Length(word);var end:=End(word);
    CopySpan(FirstZero(mem,word),p+32+m,N.Free(word)+32,n);
    CopyFrame(FirstZero(mem,word),p+32+m,N.Free(word)+32,n,p+32,p+32+m);
    StoreFrame(SecondCopy(mem,word),end,0,p+32,end);StoreFrame(SecondZero(mem,word),p,m+n,p+32,end);StoreFrame(Header(mem,word),64,end,p+32,end);
    assert Final(mem,word)[p+32..end]==N.Prefix(word)+I.Render(Magnitude(word),false);
    Stage(mem,word,4);Stage(mem,word,5);Stage(mem,word,6);
    R.StoredWord(SecondZero(mem,word),p,m+n);R.StoredFrame(Header(mem,word),64,end,p);R.StoredWord(Header(mem,word),64,end);
    T.Load(Final(mem,word),p);T.Load(Final(mem,word),64);
  }
}
