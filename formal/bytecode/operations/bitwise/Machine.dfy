// SPDX-License-Identifier: MIT
// Reviewed reached-opcode EVM model for Operations scalar bitwise entries. Adequate execution resources
// and truthful calldata/environment projections remain explicit premises.
module OperationsBitwiseMachine {
  type Byte = x: nat | x < 256 witness 0
  type Word = x: nat | x < 0x10000000000000000000000000000000000000000000000000000000000000000 witness 0
  function Modulus(): nat { 0x10000000000000000000000000000000000000000000000000000000000000000 }
  datatype State = Running(pc: nat, stack: seq<Word>, memory: seq<Byte>)
                 | Returned(data: seq<Byte>) | Reverted(data: seq<Byte>) | Bad
  datatype Instruction = Op(op: nat, next: nat, immediate: Word)

  function Pow256(n: nat): nat
    ensures Pow256(n) > 0
    decreases n
  { if n == 0 then 1 else 256 * Pow256(n-1) }

  function Encode(n: nat, width: nat): seq<Byte>
    ensures |Encode(n,width)| == width
    decreases width
  { if width == 0 then [] else Encode(n/256,width-1)+[n%256] }

  function Decode(bs: seq<Byte>): nat
    decreases |bs|
  { if |bs| == 0 then 0 else Decode(bs[..|bs|-1])*256+bs[|bs|-1] }

  lemma DecodeBound(bs: seq<Byte>)
    ensures Decode(bs) < Pow256(|bs|)
    decreases |bs|
  {
    if |bs| > 0 {
      DecodeBound(bs[..|bs|-1]);
    }
  }

  lemma RoundTrip(n: nat, width: nat)
    requires n < Pow256(width)
    ensures Decode(Encode(n,width)) == n
    decreases width
  {
    if width > 0 {
      assert n/256 < Pow256(width-1);
      RoundTrip(n/256,width-1);
    }
  }

  lemma WordPower()
    ensures Pow256(32) == Modulus()
  {
    assert Pow256(0) == 1;
    assert Pow256(1) == 256;
    assert Pow256(2) == 65536;
    assert Pow256(3) == 16777216;
    assert Pow256(4) == 4294967296;
    assert Pow256(5) == 1099511627776;
    assert Pow256(6) == 281474976710656;
    assert Pow256(7) == 72057594037927936;
    assert Pow256(8) == 18446744073709551616;
    assert Pow256(9) == 4722366482869645213696;
    assert Pow256(10) == 1208925819614629174706176;
    assert Pow256(11) == 309485009821345068724781056;
    assert Pow256(12) == 79228162514264337593543950336;
    assert Pow256(13) == 20282409603651670423947251286016;
    assert Pow256(14) == 5192296858534827628530496329220096;
    assert Pow256(15) == 1329227995784915872903807060280344576;
    assert Pow256(16) == 340282366920938463463374607431768211456;
    assert Pow256(17) == 87112285931760246646623899502532662132736;
    assert Pow256(18) == 22300745198530623141535718272648361505980416;
    assert Pow256(19) == 5708990770823839524233143877797980545530986496;
    assert Pow256(20) == 1461501637330902918203684832716283019655932542976;
    assert Pow256(21) == 374144419156711147060143317175368453031918731001856;
    assert Pow256(22) == 95780971304118053647396689196894323976171195136475136;
    assert Pow256(23) == 24519928653854221733733552434404946937899825954937634816;
    assert Pow256(24) == 6277101735386680763835789423207666416102355444464034512896;
    assert Pow256(25) == 1606938044258990275541962092341162602522202993782792835301376;
    assert Pow256(26) == 411376139330301510538742295639337626245683966408394965837152256;
    assert Pow256(27) == 105312291668557186697918027683670432318895095400549111254310977536;
    assert Pow256(28) == 26959946667150639794667015087019630673637144422540572481103610249216;
    assert Pow256(29) == 6901746346790563787434755862277025452451108972170386555162524223799296;
    assert Pow256(30) == 1766847064778384329583297500742918515827483896875618958121606201292619776;
    assert Pow256(31) == 452312848583266388373324160190187140051835877600158453279131187530910662656;
    assert Pow256(32) == 115792089237316195423570985008687907853269984665640564039457584007913129639936;
  }

  function Grow(mem: seq<Byte>, length: nat): seq<Byte>
    ensures |Grow(mem,length)| >= length && |Grow(mem,length)| >= |mem|
  { if |mem| >= length then mem else mem+seq(length-|mem|,i => 0) }

  function Store(mem: seq<Byte>, offset: nat, value: Word): seq<Byte> {
    var expanded := Grow(mem,offset+32);
    expanded[..offset]+Encode(value,32)+expanded[offset+32..]
  }

  function Load(mem: seq<Byte>, offset: nat): Word {
    Decode(Grow(mem,offset+32)[offset..offset+32]) % Modulus()
  }

  lemma LoadProjection(mem: seq<Byte>, offset: nat)
    ensures Load(mem,offset) == Decode(Grow(mem,offset+32)[offset..offset+32])
  {
    WordPower();
    DecodeBound(Grow(mem,offset+32)[offset..offset+32]);
  }

  lemma StoreLoad(mem: seq<Byte>, offset: nat, value: Word)
    ensures Load(Store(mem,offset,value),offset) == value
    ensures |Store(mem,offset,value)| >= offset+32
    ensures Store(mem,offset,value)[offset..offset+32] == Encode(value,32)
  {
    WordPower();
    RoundTrip(value,32);
    var expanded := Grow(mem,offset+32);
    assert |Store(mem,offset,value)| == |expanded|;
    assert Grow(Store(mem,offset,value),offset+32) == Store(mem,offset,value);
  }

  lemma StoreFrame(mem: seq<Byte>, offset: nat, value: Word, other: nat)
    requires other+32 <= |mem|
    requires other+32 <= offset || offset+32 <= other
    ensures Load(Store(mem,offset,value),other) == Load(mem,other)
  {
    var expanded := Grow(mem,offset+32);
    assert expanded[..|mem|] == mem;
    assert Store(mem,offset,value)[other..other+32] == mem[other..other+32];
  }

  function Selector(word: Word): Word {
    word / 0x100000000000000000000000000000000000000000000000000000000
  }

  function Signed(word: Word): int {
    if word < Modulus()/2 then word as int else word as int - Modulus()
  }

  function BitAnd(a: Word, b: Word): Word {
    ((a as bv256) & (b as bv256)) as nat
  }

  function BitXor(a: Word, b: Word): Word { ((a as bv256) ^ (b as bv256)) as nat }

  function BitOr(a: Word, b: Word): Word {
    ((a as bv256) | (b as bv256)) as nat
  }

  function Shift(a: Word, amount: Word): Word {
    if amount >= 256 then 0 else ((a as bv256) << (amount as nat)) as nat
  }

  function Fetch(code: seq<Byte>, pc: nat): Instruction
    requires pc < |code|
  {
    var op := code[pc];
    if op == 0x5f then Op(op,pc+1,0)
    else if op == 0x60 && pc+1 < |code| then Op(op,pc+2,code[pc+1] as nat)
    else if op == 0x61 && pc+2 < |code| then Op(op,pc+3,(code[pc+1] as nat)*256+(code[pc+2] as nat))
    else if op == 0x62 && pc+3 < |code| then Op(op,pc+4,((code[pc+1] as nat)*256+(code[pc+2] as nat))*256+(code[pc+3] as nat))
    else if op == 0x63 && pc+4 < |code| then Op(op,pc+5,(((code[pc+1] as nat)*256+(code[pc+2] as nat))*256+(code[pc+3] as nat))*256+(code[pc+4] as nat))
    else Op(op,pc+1,0)
  }

  opaque function Step(code: seq<Byte>, destinations: set<nat>, state: State,
                       value: Word, size: Word, word: Word, a: Word, b: Word): State {
    if !state.Running? then state
    else if state.pc >= |code| then Bad
    else
      var ins := Fetch(code,state.pc);
      var s := state.stack;
      var n := |s|;
      var mem := state.memory;
      if ins.op in {0x5f,0x60,0x61,0x62,0x63} && n < 1024 then Running(ins.next,s+[ins.immediate],mem)
      else if ins.op == 0x5b then Running(ins.next,s,mem)
      else if ins.op == 0x34 && n < 1024 then Running(ins.next,s+[value],mem)
      else if ins.op == 0x36 && n < 1024 then Running(ins.next,s+[size],mem)
      else if 0x80 <= ins.op <= 0x8f && n >= ins.op-0x7f && n < 1024 then Running(ins.next,s+[s[n-(ins.op-0x7f)]],mem)
      else if 0x90 <= ins.op <= 0x9f && n >= ins.op-0x8f+1 then
        var k := ins.op-0x8f;
        Running(ins.next,s[n-1:=s[n-1-k]][n-1-k:=s[n-1]],mem)
      else if ins.op == 0x50 && n >= 1 then Running(ins.next,s[..n-1],mem)
      else if ins.op == 0x15 && n >= 1 then Running(ins.next,s[..n-1]+[if s[n-1] == 0 then 1 else 0],mem)
      else if ins.op == 0x35 && n >= 1 && s[n-1] in {0,4,36} then Running(ins.next,s[..n-1]+[if s[n-1] == 0 then word else if s[n-1] == 4 then a else b],mem)
      else if ins.op == 0x1c && n >= 2 && s[n-1] == 224 then Running(ins.next,s[..n-2]+[Selector(s[n-2])],mem)
      else if ins.op == 0x1b && n >= 2 then Running(ins.next,s[..n-2]+[Shift(s[n-2],s[n-1])],mem)
      else if ins.op == 0x16 && n >= 2 then Running(ins.next,s[..n-2]+[BitAnd(s[n-1],s[n-2])],mem)
      else if ins.op == 0x18 && n >= 2 then Running(ins.next,s[..n-2]+[BitXor(s[n-1],s[n-2])],mem)
      else if ins.op == 0x17 && n >= 2 then Running(ins.next,s[..n-2]+[BitOr(s[n-1],s[n-2])],mem)
      else if ins.op == 0x01 && n >= 2 then Running(ins.next,s[..n-2]+[((s[n-1] as nat)+(s[n-2] as nat))%Modulus()],mem)
      else if ins.op == 0x03 && n >= 2 then Running(ins.next,s[..n-2]+[(s[n-1]+Modulus()-s[n-2])%Modulus()],mem)
      else if ins.op in {0x10,0x11,0x12,0x14} && n >= 2 then
        var truth := if ins.op == 0x10 then s[n-1] < s[n-2]
                     else if ins.op == 0x11 then s[n-1] > s[n-2]
                     else if ins.op == 0x12 then Signed(s[n-1]) < Signed(s[n-2])
                     else s[n-1] == s[n-2];
        Running(ins.next,s[..n-2]+[if truth then 1 else 0],mem)
      else if ins.op == 0x52 && n >= 2 then Running(ins.next,s[..n-2],Store(mem,s[n-1],s[n-2]))
      else if ins.op == 0x51 && n >= 1 then Running(ins.next,s[..n-1]+[Load(mem,s[n-1])],mem)
      else if ins.op == 0x56 && n >= 1 then
        if s[n-1] in destinations && s[n-1] < |code| && code[s[n-1]] == 0x5b then Running(s[n-1],s[..n-1],mem) else Bad
      else if ins.op == 0x57 && n >= 2 then
        if s[n-2] == 0 then Running(ins.next,s[..n-2],mem)
        else if s[n-1] in destinations && s[n-1] < |code| && code[s[n-1]] == 0x5b then Running(s[n-1],s[..n-2],mem)
        else Bad
      else if ins.op in {0xf3,0xfd} && n >= 2 then
        var bytes := Grow(mem,(s[n-1] as nat)+(s[n-2] as nat))[s[n-1]..(s[n-1] as nat)+(s[n-2] as nat)];
        if ins.op == 0xf3 then Returned(bytes) else Reverted(bytes)
      else Bad
  }
}
