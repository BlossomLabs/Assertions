// SPDX-License-Identifier: MIT
include "And.generated.dfy"
include "Or.generated.dfy"
include "Xor.generated.dfy"
include "../rejections/Nonzero.generated.dfy"
include "../rejections/Short.generated.dfy"
include "../rejections/AndArgs.generated.dfy"
include "../rejections/OrArgs.generated.dfy"
include "../rejections/XorArgs.generated.dfy"
module OperationsBitwiseConnection {
  import opened OperationsBitwiseMachine
  import A = OperationsBitwiseAnd
  import O = OperationsBitwiseOr
  import X = OperationsBitwiseXor
  import N = OperationsRawNonzero
  import S = OperationsRawShort
  import AS = OperationsRawAndArgs
  import OS = OperationsRawOrArgs
  import XS = OperationsRawXorArgs

  // CALLDATALOAD is the zero-padded 32-byte big-endian calldata window.
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

  function Expected(selector: Word, a: Word, b: Word): Word {
    if selector == 1972942088 then ((a as bv256) & (b as bv256)) as nat
    else if selector == 2955058326 then ((a as bv256) | (b as bv256)) as nat
    else ((a as bv256) ^ (b as bv256)) as nat
  }
  predicate Assigned(selector: Word) {
    selector in {1972942088,2955058326,1231954616}
  }
  opaque predicate Matches(code: seq<Byte>) {
    A.Matches(code) && O.Matches(code) && X.Matches(code) && N.Matches(code) && S.Matches(code) &&
    AS.Matches(code) && OS.Matches(code) && XS.Matches(code)
  }
  ghost method Run(code: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 ==>
              state == Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)),32))
  {
    reveal Matches();
    var size := |data| as Word;
    var word := DataWord(data,0);
    var a := DataWord(data,4);
    var b := DataWord(data,36);
    Projection(data,0); Projection(data,4); Projection(data,36);
    if value != 0 { state := N.Run(code,value,size,word,a,b); }
    else if size < 4 { state := S.Run(code,value,size,word,a,b); }
    else if size < 68 {
      if Selector(word) == 1972942088 { state := AS.Run(code,value,size,word,a,b); }
      else if Selector(word) == 2955058326 { state := OS.Run(code,value,size,word,a,b); }
      else { state := XS.Run(code,value,size,word,a,b); }
    } else if Selector(word) == 1972942088 { state := A.Run(code,value,size,word,a,b); }
    else if Selector(word) == 2955058326 { state := O.Run(code,value,size,word,a,b); }
    else { state := X.Run(code,value,size,word,a,b); }
  }
}
