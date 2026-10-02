// SPDX-License-Identifier: MIT
// Unverified candidate exact raw decoder and original byte-memory support.
include "Machine.dfy"
include "Conversion.generated.dfy"
module OperationsByteAtAdmissionKernel {
  import opened OperationsByteAtMachine
  import I = OperationsByteAtInputs
  import B = OperationsByteAtMemory
  import C = OperationsByteAtWordConversion
  lemma Scale(left: nat,right: nat,factor: nat)
    requires left <= right
    ensures left*factor <= right*factor
  { assert (right-left)*factor >= 0; }
  lemma DivisionUnique(n: nat,d: nat,q: nat,r: nat)
    requires d > 0 && r < d && n == q*d+r
    ensures n/d == q
  {
    var actual := n/d;
    if actual < q {
      Scale(actual+1,q,d);
      assert n < (actual+1)*d;
      assert false;
    } else if q < actual {
      Scale(q+1,actual,d);
      assert n < (q+1)*d;
      assert false;
    }
  }
  lemma SplitLoad(data: seq<Byte>,offset: nat,front: nat,tail: nat)
    ensures I.Load(data,offset,front+tail) == I.Load(data,offset,front)*I.Power(tail)+I.Load(data,offset+front,tail)
    decreases tail
  {
    if tail > 0 {
      SplitLoad(data,offset,front,tail-1);
      assert I.Load(data,offset,front+tail) ==
             256*I.Load(data,offset,front+tail-1)+I.Cell(data,offset+front+tail-1);
    }
  }
  lemma BytePower(n: nat)
    ensures Power2(8*n) == I.Power(n)
    decreases n
  {
    if n > 0 {
      BytePower(n-1);
      assert Power2(8*n) == 2*Power2(8*n-1);
      assert Power2(8*n-1) == 2*Power2(8*n-2);
      assert Power2(8*n-2) == 2*Power2(8*n-3);
      assert Power2(8*n-3) == 2*Power2(8*n-4);
      assert Power2(8*n-4) == 2*Power2(8*n-5);
      assert Power2(8*n-5) == 2*Power2(8*n-6);
      assert Power2(8*n-6) == 2*Power2(8*n-7);
      assert Power2(8*n-7) == 2*Power2(8*(n-1));
    }
  }
  lemma AssignedSelector(data: seq<Byte>,value: Word)
    requires I.Assigned(data,value) && value == 0 && |data| >= 4
    ensures Right(I.DataWord(data,0),224) == 0x9ae8e8ea
  {
    assert data[..4] == [0x9a,0xe8,0xe8,0xea];
    assert data[0] == 0x9a && data[1] == 0xe8 && data[2] == 0xe8 && data[3] == 0xea;
    assert I.Load(data,0,4) == 0x9ae8e8ea;
    SplitLoad(data,0,4,28);
    DivisionUnique(I.Load(data,0,32),I.Power(28),I.Load(data,0,4),I.Load(data,4,28));
    BytePower(28);
  }
  lemma OffsetLimitShift()
    ensures Left(1,64) == U64
  {
    C.Nat256(1);
    C.Inverse256(0x10000000000000000 as bv256);
    assert ((1 as bv256)<<64) == (0x10000000000000000 as bv256);
    reveal Left();
  }
  function StoreWord(memory: seq<Byte>,offset: nat,value: Word): seq<Byte> {
    B.Copy(memory,I.Encode(value,32),0,offset,32)
  }
  lemma PaddedEncode(n: nat,width: nat,padding: nat)
    ensures I.Encode(n*I.Power(padding),width+padding) == I.Encode(n,width)+seq(padding,i => 0 as Byte)
    decreases padding
  {
    if padding > 0 {
      assert I.Power(padding) == 256*I.Power(padding-1);
      assert n*I.Power(padding) == (n*I.Power(padding-1))*256;
      DivisionUnique(n*I.Power(padding),256,n*I.Power(padding-1),0);
      assert (n*I.Power(padding))%256 == 0;
      PaddedEncode(n,width,padding-1);
    }
  }
  lemma EqualLoads(left: seq<Byte>,leftAt: nat,right: seq<Byte>,rightAt: nat,width: nat)
    requires forall at: nat | leftAt <= at < leftAt+width :: I.Cell(left,at) == I.Cell(right,rightAt+at-leftAt)
    ensures I.Load(left,leftAt,width) == I.Load(right,rightAt,width)
    decreases width
  {
    if width > 0 { EqualLoads(left,leftAt,right,rightAt,width-1); }
  }
  lemma EncodeRoundTrip(n: nat,width: nat)
    requires n < I.Power(width)
    ensures I.Load(I.Encode(n,width),0,width) == n
    decreases width
  {
    if width > 0 {
      assert n/256 < I.Power(width-1);
      EncodeRoundTrip(n/256,width-1);
      var full := I.Encode(n,width);
      var upper := I.Encode(n/256,width-1);
      assert full[..width-1] == upper;
      assert forall i: nat | i < width-1 :: I.Cell(full,i) == I.Cell(upper,i);
      EqualLoads(full,0,upper,0,width-1);
      assert I.Cell(full,width-1) == n%256;
      assert n == 256*(n/256)+n%256;
    }
  }
  lemma StoreWindow(memory: seq<Byte>,offset: nat,value: Word)
    ensures |StoreWord(memory,offset,value)| >= offset+32
    ensures StoreWord(memory,offset,value)[offset..offset+32] == I.Encode(value,32)
  {
    B.CopyLength(memory,I.Encode(value,32),0,offset,32);
    B.CopiedWindow(memory,I.Encode(value,32),0,offset,32);
  }
}
