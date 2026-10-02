// SPDX-License-Identifier: MIT
// Unverified candidate opcode-to-floor-logarithm connection. No public credit.
include "Machine.dfy"
include "Math.dfy"
module OperationsBytecodeLog2Kernel {
  import opened OperationsBytecodeLog2Machine
  import F = OperationsBytecodeLog2Math
  import C = OperationsBytecodeLog2WordConversion
  const Table: Word := 6928917744019834342450304135053993530982274426945361611473370484834304
  function Bool(truth: bool): Word { if truth then 1 else 0 }
  function Flag(x: Word,previous: Word,threshold: Word,amount: Word): Word {
    Shift(Bool(Right(x,previous)>threshold),amount)
  }
  function R128(x: Word): Word { Flag(x,0,0xffffffffffffffffffffffffffffffff,7) }
  function R64(x: Word): Word { BitOr(R128(x),Flag(x,R128(x),0xffffffffffffffff,6)) }
  function R32(x: Word): Word { BitOr(R64(x),Flag(x,R64(x),0xffffffff,5)) }
  function R16(x: Word): Word { BitOr(R32(x),Flag(x,R32(x),0xffff,4)) }
  function R8(x: Word): Word { BitOr(R16(x),Flag(x,R16(x),0xff,3)) }
  function R4(x: Word): Word { BitOr(R8(x),Flag(x,R8(x),0xf,2)) }
  function Result(x: Word): Word { BitOr(R4(x),ByteWord(Right(x,R4(x)),Table)) }

  const ErrorSelector: Word := 0x7e8300b0
  const ErrorWord: Word := 0x7e8300b000000000000000000000000000000000000000000000000000000000
  function Undefined(): seq<Byte> { Encode(ErrorSelector,4)+Encode(0,32) }
  lemma InitialOpcode(x: Word)
    ensures R128(x)==Shift(Bool(x>0xffffffffffffffffffffffffffffffff),7)
  { reveal Right(); }
  lemma FixedShift(input: Word,amount: Word,result: Word)
    requires (input==1 && amount==64 && result==0x10000000000000000) ||
             (input==0x101020202020303030303030303 && amount==128 && result==Table) ||
             (input==0x7e8300b && amount==228 && result==ErrorWord)
    ensures Shift(input,amount)==result
  {
    C.Nat256(input);
    var bits:=input as bv256;
    assert ((bits<<(amount as nat)) as nat)==result;
    ShiftBridgeAt(input,amount,amount,bits,result);
  }
  lemma ErrorStores(mem: seq<Byte>)
    ensures Store(Store(mem,128,ErrorWord),132,0)[128..164]==Undefined()
  {
    WordPower();
    StoreLoad(mem,128,ErrorWord);
    StoreLoad(Store(mem,128,ErrorWord),132,0);
    var first:=Store(mem,128,ErrorWord);
    var second:=Store(first,132,0);
    StorePrefix(first,132,0,132);
    assert second[..132]==first[..132];
    assert second[128..132]==first[128..132];
    assert second[128..164]==first[128..132]+second[132..164];
    EncodeConcat(ErrorWord,4,28);
    assert ErrorWord/Pow256(28)==ErrorSelector;
  }
  lemma Powers(n: nat)
    ensures Pow2(n)==F.Power(n)
    decreases n
  { if n>0 { Powers(n-1); } }
  lemma ShiftBool(truth: bool,amount: Word)
    requires amount in {2,3,4,5,6,7}
    ensures Shift(Bool(truth),amount)==(if truth then Pow2(amount) else 0)
  {
    reveal Shift();
    if truth {
      C.Nat256(1);
      if amount==2 { assert Pow2(2)==4; }
      else if amount==3 { assert Pow2(3)==8; }
      else if amount==4 { assert Pow2(4)==16; }
      else if amount==5 { assert Pow2(5)==32; }
      else if amount==6 { assert Pow2(6)==64; }
      else if amount==7 { assert Pow2(7)==128; }
    } else { C.Nat256(0); }
  }
  lemma OrSmall(left: Word,right: Word)
    requires left<256 && right<256
    ensures BitOr(left,right)<256
    ensures (BitOr(left,right) as bv8)==F.Or(left as bv8,right as bv8)
    ensures BitOr(left,right)==(F.Or(left as bv8,right as bv8) as nat)
  {
    var l:=left as bv8; var r:=right as bv8;
    C.Nat8(left); C.Nat8(right);
    C.Nat256(left); C.Nat256(right);
    C.Inverse256(l as bv256); C.Inverse256(r as bv256);
    assert (l as bv256)==(left as bv256);
    assert (r as bv256)==(right as bv256);
    F.ZeroExtendOr(l,r);
    var narrow:=F.Or(l,r);
    var result:=narrow as nat;
    C.Nat8(result); C.Nat256(result);
    C.Inverse256(narrow as bv256);
    assert (narrow as bv256)==(result as bv256);
    SymmetricBits(left,right);
    assert BitOr(left,right)==result;
    assert (result as bv8)==narrow;
  }
  lemma RightPower(x: Word,previous: Word)
    requires previous<256
    ensures Right(x,previous)==x/F.Power(previous)
  { reveal Right(); Powers(previous); }
  lemma InitialFlag(x: Word)
    ensures R128(x)==(if x>=F.Power(128) then 128 else 0)
    ensures R128(x)<256
  {
    F.KnownPowers(); reveal Right();
    ShiftBool(x>0xffffffffffffffffffffffffffffffff,7);
  }
  lemma StageFlag(x: Word,previous: Word,step: Word,amount: Word,threshold: Word)
    requires previous<256 && step in {4,8,16,32,64}
    requires (step==4 && amount==2 && threshold==0xf) ||
             (step==8 && amount==3 && threshold==0xff) ||
             (step==16 && amount==4 && threshold==0xffff) ||
             (step==32 && amount==5 && threshold==0xffffffff) ||
             (step==64 && amount==6 && threshold==0xffffffffffffffff)
    ensures Flag(x,previous,threshold,amount)==
            (if x/F.Power(previous)>=F.Power(step) then step else 0)
    ensures Flag(x,previous,threshold,amount)<256
  {
    F.KnownPowers();
    RightPower(x,previous);
    ShiftBool(Right(x,previous)>threshold,amount);
  }
  lemma ByteTable(index: Word)
    requires index<16
    ensures ByteWord(index,Table)==F.Log(index)
    ensures ByteWord(index,Table)<4
  { Powers(8*(31-index)); F.Table(index,Table); F.SmallLog(index); }
  lemma Pipeline(x: Word)
    ensures Result(x)==F.Log(x) && Result(x)<256
  {
    F.KnownPowers();
    var r: bv8:=0;
    assert F.Log(x)==(r as nat)+F.Log(x/F.Power(r as nat));
    assert x/F.Power(r as nat)<F.Power(256);
    InitialFlag(x);
    var previous:=r;
    r:=R128(x) as bv8;
    C.Nat8(R128(x));
    assert r==F.Or(previous,if x/F.Power(previous as nat)>=F.Power(128) then 128 as bv8 else 0);
    F.Stage(x,previous,128,r);
    assert r&(127 as bv8)==0;
    previous:=r;
    assert (previous as nat)==R128(x);
    StageFlag(x,R128(x),64,6,0xffffffffffffffff);
    OrSmall(R128(x),Flag(x,R128(x),0xffffffffffffffff,6));
    r:=R64(x) as bv8;
    C.Nat8(R64(x));
    assert r==F.Or(previous,if x/F.Power(previous as nat)>=F.Power(64) then 64 as bv8 else 0);
    assert previous&(64 as bv8)==0 && (previous as nat)+64<256;
    F.Stage(x,previous,64,r);
    assert r&(63 as bv8)==0;
    assert F.Log(x)==(r as nat)+F.Log(x/F.Power(r as nat));
    previous:=r;
    assert (previous as nat)==R64(x);
    StageFlag(x,R64(x),32,5,0xffffffff);
    OrSmall(R64(x),Flag(x,R64(x),0xffffffff,5));
    r:=R32(x) as bv8;
    C.Nat8(R32(x));
    assert r==F.Or(previous,if x/F.Power(previous as nat)>=F.Power(32) then 32 as bv8 else 0);
    assert previous&(32 as bv8)==0 && (previous as nat)+32<256;
    F.Stage(x,previous,32,r);
    assert r&(31 as bv8)==0;
    assert F.Log(x)==(r as nat)+F.Log(x/F.Power(r as nat));
    previous:=r;
    assert (previous as nat)==R32(x);
    StageFlag(x,R32(x),16,4,0xffff);
    OrSmall(R32(x),Flag(x,R32(x),0xffff,4));
    r:=R16(x) as bv8;
    C.Nat8(R16(x));
    assert r==F.Or(previous,if x/F.Power(previous as nat)>=F.Power(16) then 16 as bv8 else 0);
    assert previous&(16 as bv8)==0 && (previous as nat)+16<256;
    F.Stage(x,previous,16,r);
    assert r&(15 as bv8)==0;
    assert F.Log(x)==(r as nat)+F.Log(x/F.Power(r as nat));
    previous:=r;
    assert (previous as nat)==R16(x);
    StageFlag(x,R16(x),8,3,0xff);
    OrSmall(R16(x),Flag(x,R16(x),0xff,3));
    r:=R8(x) as bv8;
    C.Nat8(R8(x));
    assert r==F.Or(previous,if x/F.Power(previous as nat)>=F.Power(8) then 8 as bv8 else 0);
    assert previous&(8 as bv8)==0 && (previous as nat)+8<256;
    F.Stage(x,previous,8,r);
    assert r&(7 as bv8)==0;
    assert F.Log(x)==(r as nat)+F.Log(x/F.Power(r as nat));
    previous:=r;
    assert (previous as nat)==R8(x);
    StageFlag(x,R8(x),4,2,0xf);
    OrSmall(R8(x),Flag(x,R8(x),0xf,2));
    r:=R4(x) as bv8;
    C.Nat8(R4(x));
    assert r==F.Or(previous,if x/F.Power(previous as nat)>=F.Power(4) then 4 as bv8 else 0);
    assert previous&(4 as bv8)==0 && (previous as nat)+4<256;
    F.Stage(x,previous,4,r);
    assert r&(3 as bv8)==0;
    assert F.Log(x)==(r as nat)+F.Log(x/F.Power(r as nat));
    assert (r as nat)==R4(x);
    RightPower(x,R4(x));
    var q:=Right(x,R4(x));
    assert q<16;
    ByteTable(q);
    assert r&(ByteWord(q,Table) as bv8)==0;
    assert (r as nat)+ByteWord(q,Table)<256;
    OrSmall(R4(x),ByteWord(q,Table));
    F.OrClear(r,ByteWord(q,Table) as bv8);
    assert Result(x)==(r as nat)+F.Log(q);
  }
  lemma OrIdentityBits(bits: bv256)
    ensures (bits|0)==bits
  {}
  lemma ProjectionCongruence(left: bv256,right: bv256)
    requires left==right
    ensures (left as nat)==(right as nat)
  {}
  lemma OrProjection(left: Word,right: Word,l: bv256,r: bv256,result: bv256)
    requires l==(left as bv256) && r==(right as bv256) && result==(l|r)
    ensures BitOr(left,right)==(result as nat)
  {
    var actual: bv256 := (left as bv256)|(right as bv256);
    assert result==actual;
    SymmetricBits(left,right);
    ProjectionCongruence(actual,result);
  }
  lemma OrZero(input: Word)
    ensures BitOr(input,0)==input
  {
    var bits:=input as bv256;
    OrIdentityBits(bits);
    assert (0 as bv256)==0;
    OrProjection(input,0,bits,0,bits);
    C.Nat256(input);
    assert (bits as nat)==input;
  }
  lemma FourthInput()
    ensures R128(4)==0 && R64(4)==0 && R32(4)==0 && R16(4)==0 && R8(4)==0 && R4(4)==0
    ensures Right(4,R4(4))==4 && ByteWord(4,Table)==2 && Result(4)==2
    ensures Right(Table,4)!=Result(4)
  {
    F.KnownPowers(); InitialFlag(4);
    StageFlag(4,0,64,6,0xffffffffffffffff); OrZero(0);
    StageFlag(4,0,32,5,0xffffffff); OrZero(0);
    StageFlag(4,0,16,4,0xffff); OrZero(0);
    StageFlag(4,0,8,3,0xff); OrZero(0);
    StageFlag(4,0,4,2,0xf); OrZero(0);
    RightPower(4,0); ByteTable(4); F.SmallLog(4);
    SymmetricBits(0,2); OrZero(2);
    RightPower(Table,4);
    assert Table/16>2;
  }

}
