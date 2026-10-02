// SPDX-License-Identifier: MIT
include "Eq.generated.dfy"
include "rejections/EqArgs.generated.dfy"
include "Ne.generated.dfy"
include "rejections/NeArgs.generated.dfy"
include "LtU.generated.dfy"
include "rejections/LtUArgs.generated.dfy"
include "GtU.generated.dfy"
include "rejections/GtUArgs.generated.dfy"
include "LeU.generated.dfy"
include "rejections/LeUArgs.generated.dfy"
include "GeU.generated.dfy"
include "rejections/GeUArgs.generated.dfy"
include "LtS.generated.dfy"
include "rejections/LtSArgs.generated.dfy"
include "GtS.generated.dfy"
include "rejections/GtSArgs.generated.dfy"
include "LeS.generated.dfy"
include "rejections/LeSArgs.generated.dfy"
include "GeS.generated.dfy"
include "rejections/GeSArgs.generated.dfy"
include "rejections/Nonzero.generated.dfy"
include "rejections/Short.generated.dfy"
module OperationsComparisonConnection {
  import opened OperationsComparisonMachine
  import Eq = OperationsComparisonEq
  import EqA = OperationsComparisonRawEqArgs
  import Ne = OperationsComparisonNe
  import NeA = OperationsComparisonRawNeArgs
  import LtU = OperationsComparisonLtU
  import LtUA = OperationsComparisonRawLtUArgs
  import GtU = OperationsComparisonGtU
  import GtUA = OperationsComparisonRawGtUArgs
  import LeU = OperationsComparisonLeU
  import LeUA = OperationsComparisonRawLeUArgs
  import GeU = OperationsComparisonGeU
  import GeUA = OperationsComparisonRawGeUArgs
  import LtS = OperationsComparisonLtS
  import LtSA = OperationsComparisonRawLtSArgs
  import GtS = OperationsComparisonGtS
  import GtSA = OperationsComparisonRawGtSArgs
  import LeS = OperationsComparisonLeS
  import LeSA = OperationsComparisonRawLeSArgs
  import GeS = OperationsComparisonGeS
  import GeSA = OperationsComparisonRawGeSArgs
  import N = OperationsComparisonRawNonzero
  import S = OperationsComparisonRawShort
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
    if selector == 840207731 then (if a == b then 1 else 0)
    else if selector == 857022028 then (if a != b then 1 else 0)
    else if selector == 294635660 then (if a < b then 1 else 0)
    else if selector == 568685723 then (if a > b then 1 else 0)
    else if selector == 3546688765 then (if a <= b then 1 else 0)
    else if selector == 2246178412 then (if a >= b then 1 else 0)
    else if selector == 814219320 then (if Signed(a) < Signed(b) then 1 else 0)
    else if selector == 2886244157 then (if Signed(a) > Signed(b) then 1 else 0)
    else if selector == 1272760 then (if Signed(a) <= Signed(b) then 1 else 0)
    else if selector == 1699934599 then (if Signed(a) >= Signed(b) then 1 else 0)
    else 0
  }
  predicate Assigned(selector: Word) { selector in {840207731,857022028,294635660,568685723,3546688765,2246178412,814219320,2886244157,1272760,1699934599} }
  opaque predicate Matches(code: seq<Byte>) { Eq.Matches(code) && Ne.Matches(code) && LtU.Matches(code) && GtU.Matches(code) && LeU.Matches(code) && GeU.Matches(code) && LtS.Matches(code) && GtS.Matches(code) && LeS.Matches(code) && GeS.Matches(code) && N.Matches(code) && S.Matches(code) && EqA.Matches(code) && NeA.Matches(code) && LtUA.Matches(code) && GtUA.Matches(code) && LeUA.Matches(code) && GeUA.Matches(code) && LtSA.Matches(code) && GtSA.Matches(code) && LeSA.Matches(code) && GeSA.Matches(code) }
  ghost method Run(code: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value != 0 || |data| < 4 || Assigned(Selector(DataWord(data,0)))
    ensures value != 0 || |data| < 68 ==> state == Reverted([])
    ensures value == 0 && |data| >= 68 ==> state == Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36)),32))
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
      if Selector(word) == 840207731 { state := EqA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 857022028 { state := NeA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 294635660 { state := LtUA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 568685723 { state := GtUA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 3546688765 { state := LeUA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 2246178412 { state := GeUA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 814219320 { state := LtSA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 2886244157 { state := GtSA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 1272760 { state := LeSA.Run(code,value,size,word,a,b); }
      else if Selector(word) == 1699934599 { state := GeSA.Run(code,value,size,word,a,b); }
      else { assert false; }
    }
    else if Selector(word) == 840207731 { state := Eq.Run(code,value,size,word,a,b); }
    else if Selector(word) == 857022028 { state := Ne.Run(code,value,size,word,a,b); }
    else if Selector(word) == 294635660 { state := LtU.Run(code,value,size,word,a,b); }
    else if Selector(word) == 568685723 { state := GtU.Run(code,value,size,word,a,b); }
    else if Selector(word) == 3546688765 { state := LeU.Run(code,value,size,word,a,b); }
    else if Selector(word) == 2246178412 { state := GeU.Run(code,value,size,word,a,b); }
    else if Selector(word) == 814219320 { state := LtS.Run(code,value,size,word,a,b); }
    else if Selector(word) == 2886244157 { state := GtS.Run(code,value,size,word,a,b); }
    else if Selector(word) == 1272760 { state := LeS.Run(code,value,size,word,a,b); }
    else if Selector(word) == 1699934599 { state := GeS.Run(code,value,size,word,a,b); }
    else { assert false; }
  }
}
