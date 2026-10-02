include "Shl.generated.dfy"
include "rejections/ShlArgs.generated.dfy"
include "ShrU.generated.dfy"
include "rejections/ShrUArgs.generated.dfy"
include "ShrS.generated.dfy"
include "rejections/ShrSArgs.generated.dfy"
include "BitSet.generated.dfy"
include "rejections/BitSetArgs.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
module OperationsShiftConnection {
  import opened OperationsShiftMachine
  import Shl = OperationsShiftShl
  import ShlA = OperationsShiftRawShlArgs
  import ShrU = OperationsShiftShrU
  import ShrUA = OperationsShiftRawShrUArgs
  import ShrS = OperationsShiftShrS
  import ShrSA = OperationsShiftRawShrSArgs
  import BitSet = OperationsShiftBitSet
  import BitSetA = OperationsShiftRawBitSetArgs
  import N = OperationsShiftRawNonzero
  import S = OperationsShiftRawShort
  function DataWord(data: seq<Byte>, offset: nat): Word { Load(data,offset) }
  predicate Frame(data: seq<Byte>) { |data| < 0x10000000000000000 }
  function RawStep(code: seq<Byte>, destinations: set<nat>, state: State,
                   value: Word, data: seq<Byte>): State
    requires Frame(data)
  { Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36)) }
  lemma Projection(data: seq<Byte>, offset: nat)
    ensures DataWord(data,offset) == Decode(Grow(data,offset+32)[offset..offset+32])
    ensures offset+32 <= |data| ==> DataWord(data,offset) == Decode(data[offset..offset+32])
  { LoadProjection(data,offset); }
  function Expected(selector: Word,a: Word,b: Word): Word {
    if selector == 2644992239 then Shift(a,b)
    else if selector == 1978943386 then Right(a,b)
    else if selector == 461206296 then ArithmeticRight(a,b)
    else if selector == 2994757980 then (if (((Right(a,b) as bv256) & (1 as bv256)) as nat) == 1 then 1 else 0)
    else 0
  }
  predicate Assigned(selector: Word) { selector in {2644992239,1978943386,461206296,2994757980} }
  opaque predicate Matches(code: seq<Byte>) { Shl.Matches(code) && ShrU.Matches(code) && ShrS.Matches(code) && BitSet.Matches(code) && N.Matches(code) && S.Matches(code) && ShlA.Matches(code) && ShrUA.Matches(code) && ShrSA.Matches(code) && BitSetA.Matches(code) }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)),32))
  {
    reveal Matches();
    var size := |data| as Word; var word := DataWord(data,0);
    var a := DataWord(data,4); var b := DataWord(data,36);
    Projection(data,0); Projection(data,4); Projection(data,36);
    if value != 0 { state := N.Run(code,value,size,word,a,b); }
    else if size < 4 { state := S.Run(code,value,size,word,a,b); }
    else if size < 68 {
      if Selector(word) == 2644992239 { state := ShlA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 1978943386 { state := ShrUA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 461206296 { state := ShrSA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 2994757980 { state := BitSetA.Run(code,value,size,word,a,b); }
      else { assert false; }
    }
    else if Selector(word) == 2644992239 { state := Shl.Run(code,value,size,word,a,b); }
    else if Selector(word) == 1978943386 { state := ShrU.Run(code,value,size,word,a,b); }
    else if Selector(word) == 461206296 { state := ShrS.Run(code,value,size,word,a,b); }
    else if Selector(word) == 2994757980 { state := BitSet.Run(code,value,size,word,a,b); }
    else { assert false; }
  }
}
