// SPDX-License-Identifier: MIT
// Complete exact recursive type rejection from actual type entry to terminal error.
include "Semantics.dfy"
include "../descriptor-start-rejection/PAtLimit.generated.dfy"
include "../name-rejection/Connection.dfy"
module BytecodeCollectionsTypeRejectParser {
  import opened BytecodeScanMachine
  import G = BytecodeGetterMachine
  import E = BytecodeCollectionsArrayByteExecution
  import X = BytecodeCollectionsParserExecution
  import R = BytecodeCollectionsTypeRejectSemantics
  import T = BytecodeCollectionsTypeSemantics
  import TP = BytecodeCollectionsTuplePrefixBounds
  import Prefix = BytecodeCollectionsTuplePrefix
  import Start = BytecodeCollectionsDescriptorPAtLimit
  import Name = BytecodeCollectionsDescriptorNameRejection
  import Suffix = BytecodeCollectionsParserSuffixRejection
  import Separator = BytecodeCollectionsTupleSeparatorRejection
  import H = BytecodeCollectionsDescriptorErrorMemory
  predicate Matches(code: seq<Byte>) { Prefix.Matches(code) && Start.Matches(code) && Name.Matches(code) && Suffix.Matches(code) && Separator.Matches(code) }
  function Destinations(returnPc: Word): set<nat> { Prefix.Destinations(returnPc)+Start.Destinations()+Name.Destinations()+Suffix.Destinations(returnPc)+Separator.Destinations(returnPc) }
  ghost method Run(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,offset: Word,length: Word,p: Word,limit: Word,problem: R.Rejection,fp: Word,value: Word) returns (state: State,trace: seq<State>)
    requires Matches(code) && offset < 0x10000000000000000 && limit <= length < 0x10000000000000000
    requires R.Syntax(data,offset,p,limit,problem) && R.StackFits(|prefix|,problem)
    requires |mem|%32 == 0 && 96 <= fp && fp+64 < G.Modulus() && Load(mem,64) == fp
    ensures state == Reverted(H.Bytes(R.Position(data,offset,p,limit,problem)))
    ensures E.Trace(code,Destinations(returnPc),value,data,trace) && trace[0] == Running(13839,prefix+[returnPc,offset,length,p,limit],mem) && trace[|trace|-1] == state
    decreases problem
  {
    reveal Matches();
    if problem.AtLimit? {
      state,trace := Start.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,fp,value);
      X.LiftScan(code,Start.Destinations(),value,data,trace);
      X.WidenTrace(code,Start.Destinations(),Destinations(returnPc),value,data,trace);
    } else if problem.BadName? {
      state,trace := Name.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,fp,value);
      X.WidenTrace(code,Name.Destinations(),Destinations(returnPc),value,data,trace);
    } else if problem.NamedSuffix? {
      state,trace := Suffix.Named(code,data,mem,prefix,returnPc,offset,length,p,limit,problem.nameEnd,problem.closings,problem.q,problem.k,fp,value);
      X.WidenTrace(code,Suffix.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    } else if problem.TupleSuffix? {
      state,trace := Suffix.TupleType(code,data,mem,prefix,returnPc,offset,length,p,limit,problem.children,problem.closings,problem.q,problem.k,fp,value);
      X.WidenTrace(code,Suffix.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    } else if problem.Separator? {
      state,trace := Separator.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,problem.previous,problem.last,fp,value);
      X.WidenTrace(code,Separator.Destinations(returnPc),Destinations(returnPc),value,data,trace);
    } else {
      var previous := problem.previous;TP.Admission(data,offset,p,limit,previous);
      var q: Word := TP.Next(p,previous);var dyn: Word := T.Flags(previous);var sum: Word := T.Sum(previous);
      state,trace := Prefix.Run(code,data,mem,prefix,returnPc,offset,length,p,limit,previous,value);
      X.WidenTrace(code,Prefix.Destinations(returnPc),Destinations(returnPc),value,data,trace);
      var before := state;var part: seq<State>;
      var childPrefix := prefix+[returnPc,offset,length,p,limit,0,dyn,0,q,sum,0,0,0];
      state,part := Run(code,data,mem,childPrefix,13958,offset,length,q,limit,problem.inner,fp,value);
      assert Destinations(13958) <= Destinations(returnPc);
      X.WidenTrace(code,Destinations(13958),Destinations(returnPc),value,data,part);assert part[0] == before;
      X.Join(code,Destinations(returnPc),value,data,trace,part);trace := trace+part[1..];
    }
  }
}
