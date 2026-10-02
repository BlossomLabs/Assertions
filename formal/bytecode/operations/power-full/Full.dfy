// SPDX-License-Identifier: MIT
// Complete raw integer-power connection candidate. Native retention pending.
include "../power-raw-controls/UnsignedNonzero.generated.dfy"
include "../power-raw-controls/UnsignedShort.generated.dfy"
include "../power-raw-controls/UnsignedArgs.generated.dfy"
include "../power-raw-controls/UnsignedAccepted.generated.dfy"
include "../power-raw-controls/SignedNonzero.generated.dfy"
include "../power-raw-controls/SignedShort.generated.dfy"
include "../power-raw-controls/SignedArgs.generated.dfy"
include "../power-raw-controls/SignedAccepted.generated.dfy"
include "../power-unsigned-body/Body.dfy"
include "../power-signed-loop-controls/Engine.dfy"
include "../power-return-controls/Unsigned.generated.dfy"
include "../power-return-controls/Signed.generated.dfy"
module OperationsPowerFull {
  import opened OperationsSignedMultiplyMachine
  import E = OperationsPowerExecution
  import P = OperationsCheckedPowerModel
  import K = OperationsPowerWordKernel
  import U = OperationsPowerUnsignedBody
  import S = OperationsPowerSignedLoopEngine
  import J = OperationsPowerUnsignedLoopEngine
  import RU = OperationsPowerReturnUnsigned
  import RS = OperationsPowerReturnSigned
  import UN = OperationsPowerRawUnsignedNonzero
  import US = OperationsPowerRawUnsignedShort
  import UA = OperationsPowerRawUnsignedArgs
  import UC = OperationsPowerRawUnsignedAccepted
  import SN = OperationsPowerRawSignedNonzero
  import SS = OperationsPowerRawSignedShort
  import SA = OperationsPowerRawSignedArgs
  import SC = OperationsPowerRawSignedAccepted
  predicate Frame(data:seq<Byte>) { |data|<0x10000000000000000 }
  function DataWord(data:seq<Byte>,at:nat):Word { Load(data,at) }
  function RawStep(code:seq<Byte>,destinations:set<nat>,state:State,value:Word,data:seq<Byte>):State
    requires Frame(data)
  { E.Execute(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36)) }
  function Destinations():set<nat> {
    {15,143,213,353,655,968,1130,1211,1266,1301,1329,1411,1425,
     2793,2812,2831,2850,2877,2896,2910,3247,9089,18650,18667}+
    U.Destinations()+S.Destinations()+RU.Destinations()+RS.Destinations()
  }
  opaque predicate MatchesUnsigned(code:seq<Byte>) {
    UN.Matches(code) && US.Matches(code) && UA.Matches(code) && UC.Matches(code) &&
    U.Matches(code) && RU.Matches(code)
  }
  opaque predicate MatchesSigned(code:seq<Byte>) {
    SN.Matches(code) && SS.Matches(code) && SA.Matches(code) && SC.Matches(code) &&
    S.Matches(code) && RS.Matches(code)
  }
  predicate Outcome(state:State,math:P.Outcome) {
    if math.Panic? then state==Reverted(Panic(17))
    else state==Returned(Encode(K.Encode(math.result),32))
  }

  ghost method RunUnsigned(code:seq<Byte>,value:Word,data:seq<Byte>) returns(state:State,trace:seq<State>)
    requires Frame(data) && MatchesUnsigned(code)
    requires value!=0 || |data|<4 || Selector(DataWord(data,0))==0xf5f565f8
    ensures value!=0 || |data|<68 ==> state==Reverted([])
    ensures value==0 && |data|>=68 ==> Outcome(state,P.Unsigned(DataWord(data,4),DataWord(data,36)))
    ensures |trace|>0 && trace[0]==Running(0,[],[]) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==RawStep(code,Destinations(),trace[j],value,data)
  {
    reveal MatchesUnsigned();
    var size:=|data| as Word;var word:=DataWord(data,0);
    var a:=DataWord(data,4);var b:=DataWord(data,36);var destinations:=Destinations();
    if value!=0 { state,trace:=UN.Run(code,destinations,value,size,word,a,b); }
    else if size<4 { state,trace:=US.Run(code,destinations,value,size,word,a,b); }
    else if size<68 { state,trace:=UA.Run(code,destinations,value,size,word,a,b); }
    else {
      state,trace:=UC.Run(code,destinations,value,size,word,a,b);
      var tail:seq<State>;
      state,tail:=U.Run(code,destinations,[0xf5f565f8],a,b,value,size,word,a,b);
      J.Join(code,destinations,trace,tail,value,size,word,a,b);trace:=trace+tail[1..];
      if state.Running? {
        var result:=state.stack[1];
        state,tail:=RU.Run(code,destinations,[0xf5f565f8],a,b,result,value,size,word,a,b);
        J.Join(code,destinations,trace,tail,value,size,word,a,b);trace:=trace+tail[1..];
      }
    }
  }

  ghost method RunSigned(code:seq<Byte>,value:Word,data:seq<Byte>) returns(state:State,trace:seq<State>)
    requires Frame(data) && MatchesSigned(code)
    requires value!=0 || |data|<4 || Selector(DataWord(data,0))==0x185af0ad
    ensures value!=0 || |data|<68 ==> state==Reverted([])
    ensures value==0 && |data|>=68 ==> Outcome(state,P.SignedSpec(K.Signed(DataWord(data,4)),DataWord(data,36)))
    ensures |trace|>0 && trace[0]==Running(0,[],[]) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==RawStep(code,Destinations(),trace[j],value,data)
  {
    reveal MatchesSigned();
    var size:=|data| as Word;var word:=DataWord(data,0);
    var a:=DataWord(data,4);var b:=DataWord(data,36);var destinations:=Destinations();
    if value!=0 { state,trace:=SN.Run(code,destinations,value,size,word,a,b); }
    else if size<4 { state,trace:=SS.Run(code,destinations,value,size,word,a,b); }
    else if size<68 { state,trace:=SA.Run(code,destinations,value,size,word,a,b); }
    else {
      state,trace:=SC.Run(code,destinations,value,size,word,a,b);
      var tail:seq<State>;
      state,tail:=S.Run(code,destinations,[0x185af0ad,1329],a,b,value,size,word,a,b);
      J.Join(code,destinations,trace,tail,value,size,word,a,b);trace:=trace+tail[1..];
      if state.Running? {
        var factor:=state.stack[2];var remaining:=state.stack[3];var result:=state.stack[4];
        state,tail:=RS.Run(code,destinations,[0x185af0ad],factor,remaining,result,value,size,word,a,b);
        J.Join(code,destinations,trace,tail,value,size,word,a,b);trace:=trace+tail[1..];
      }
    }
  }
}
