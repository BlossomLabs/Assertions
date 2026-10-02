// SPDX-License-Identifier: MIT
// Independent decimal/raw specification; native proof pending.
include "../charset-inputs/Inputs.dfy"
module OperationsToStringInputs {
  import S = BytecodeScanMachine
  import G = BytecodeGetterMachine
  import I = OperationsCharsetInputs
  function Selector(signed:bool):S.Word { if signed then 0xa322c40e else 0x6900a3ae }
  function RawWord(data:seq<S.Byte>):S.Word { I.Load(data,4) }
  predicate Frame(data:seq<S.Byte>) { |data|<0x10000000000000000 }
  predicate Assigned(data:seq<S.Byte>,value:S.Word,signed:bool) {
    value!=0 || |data|<4 || S.ShiftRight(S.DataWord(data,0),224)==Selector(signed)
  }
  datatype Case = Nonzero | Short | Args | Accepted
  function Admission(data:seq<S.Byte>,value:S.Word):Case {
    if value!=0 then Nonzero else if |data|<4 then Short else if |data|<36 then Args else Accepted
  }
  function Negative(word:S.Word,signed:bool):bool { signed && word>=G.Modulus()/2 }
  function Magnitude(word:S.Word,signed:bool):S.Word {
    if Negative(word,signed) then G.Modulus()-word else word
  }
  function Digit(n:nat):S.Byte { 48+n%10 }
  function Digits(n:nat):seq<S.Byte>
    decreases n
  { if n==0 then [] else Digits(n/10)+[Digit(n)] }
  function Render(word:S.Word,signed:bool):seq<S.Byte> {
    (if Negative(word,signed) then [45] else [])+
    (if Magnitude(word,signed)==0 then [48] else Digits(Magnitude(word,signed)))
  }
  function Result(data:seq<S.Byte>,signed:bool):seq<S.Byte> { Render(RawWord(data),signed) }
  lemma Word(data:seq<S.Byte>) ensures RawWord(data)==S.DataWord(data,4) { I.Word(data,4); }
  lemma Admitted(data:seq<S.Byte>,value:S.Word)
    ensures Admission(data,value)==Accepted <==> value==0 && |data|>=36
  {}
}
