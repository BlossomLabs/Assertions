// SPDX-License-Identifier: MIT
// Candidate complete actual-calldata hash entry connection. No retained credit.
include "Entry.generated.dfy"
include "PrefixRaw.generated.dfy"
include "../hash-bytes-repair-v3/NonzeroRaw.generated.dfy"
include "../hash-bytes-repair-v3/ShortRaw.generated.dfy"
include "../hash-bytes-repair-v3/ArgsRaw.generated.dfy"
include "../hash-bytes-repair-v3/OffsetBoundRaw.generated.dfy"
include "../hash-bytes-repair-v3/LengthWindowRaw.generated.dfy"
include "../hash-bytes-repair-v3/LengthBoundRaw.generated.dfy"
include "../hash-bytes-repair-v3/PayloadWindowRaw.generated.dfy"
module OperationsHashFullConnection {
  import opened OperationsHashBytesMachine
  import E = OperationsHashBytesExecution
  import K = OperationsHashSuccessKernel
  import B = OperationsHashSuccessEntry
  import BS = OperationsHashSuccessState
  import P = OperationsHashRawEntryPrefix
  import PS = OperationsHashSuccessPrefix
  import RN = OperationsHashRawEntryNonzero
  import RS = OperationsHashRawEntryShort
  import RA = OperationsHashRawEntryArgs
  import RO = OperationsHashRawEntryOffsetBound
  import RW = OperationsHashRawEntryLengthWindow
  import RL = OperationsHashRawEntryLengthBound
  import RP = OperationsHashRawEntryPayloadWindow
  import N = OperationsHashBytesNonzero
  import S = OperationsHashBytesShort
  import A = OperationsHashBytesArgs
  import O = OperationsHashBytesOffsetBound
  import W = OperationsHashBytesLengthWindow
  import L = OperationsHashBytesLengthBound
  import Q = OperationsHashBytesPayloadWindow
  predicate Matches(code: seq<Byte>) {
    BS.Matches(code) && PS.Matches(code) && N.Matches(code) && S.Matches(code) &&
    A.Matches(code) && O.Matches(code) && W.Matches(code) && L.Matches(code) && Q.Matches(code)
  }
  function Offset(data: seq<Byte>): Word { E.DataWord(data,4) }
  function Length(data: seq<Byte>): Word { E.DataWord(data,(Offset(data) as nat)+4) }
  predicate Valid(data: seq<Byte>) {
    36<=|data|<0x10000000000000000 && Offset(data)<0x10000000000000000 &&
    Length(data)<0x10000000000000000 &&
    (Offset(data) as nat)+36+(Length(data) as nat)<=|data|
  }
  function Payload(data: seq<Byte>): seq<Byte>
    requires Valid(data)
  { data[(Offset(data) as nat)+36..(Offset(data) as nat)+36+(Length(data) as nat)] }
  lemma AliasedZero(data: seq<Byte>)
    ensures Offset(data)==0 ==> Length(data)==Offset(data)
  {}
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>,hashes: map<seq<Byte>,Word>) returns(state: State)
    requires Matches(code) && |data|<0x10000000000000000
    requires |data|>=4 ==> Selector(E.DataWord(data,0))==0xaa1e84de
    requires value==0 && Valid(data) ==> Payload(data) in hashes
    ensures if value!=0 || !Valid(data) then state==Reverted([])
            else state==Returned(Encode(hashes[Payload(data)],32))
  {
    var word:=E.DataWord(data,0); var a:=Offset(data); var b:=Length(data);
    AliasedZero(data);
    if value!=0 { state:=RN.Run(code,data,value,word,a,b,hashes); }
    else if |data|<4 { state:=RS.Run(code,data,value,word,a,b,hashes); }
    else if |data|<36 { state:=RA.Run(code,data,value,word,a,b,hashes); }
    else if a>=0x10000000000000000 { state:=RO.Run(code,data,value,word,a,b,hashes); }
    else if (a as nat)+36>|data| { state:=RW.Run(code,data,value,word,a,b,hashes); }
    else if b>=0x10000000000000000 { state:=RL.Run(code,data,value,word,a,b,hashes); }
    else if (a as nat)+36+(b as nat)>|data| { state:=RP.Run(code,data,value,word,a,b,hashes); }
    else {
      assert Valid(data);
      var source: Word:=(a as nat)+36; var result:=hashes[Payload(data)];
      state:=P.Run(code,data,value,word,a,b,hashes);
      assert state==Running(7568,[2854126814,1329,source,b],K.Initial());
      assert K.Observed(data,source,b,result,hashes);
      state:=B.Run(code,data,source,b,result,hashes,state);
    }
  }
}
