#!/usr/bin/env python3
"""Compose all exact UTF8 unit macros by finite-length induction; native pending."""
import argparse,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
DAFNY='/tmp/assertions-dafny-4.11.0/dafny/dafny'
PARAMS='prefix:seq<S.Word>,ret:S.Word,offset:S.Word,length:S.Word,cursor:S.Word,mem:seq<S.Byte>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>'
ARGS='prefix,ret,offset,length,cursor,mem,self,value,data,observations'
ENTRY_PARAMS=PARAMS.replace(',cursor:S.Word','');ENTRY_ARGS=ARGS.replace(',cursor,',',0,')
def generate(mapping,out):
 paths=json.loads(mapping.read_text())['paths'];aliases=[f'P{i}' for i in range(len(paths))]
 text='// SPDX-License-Identifier: MIT\n// Full finite calldata UTF8 instruction connection. Native verification pending.\n'
 text+=''.join(f'include "{p["name"]}.generated.dfy"\n' for p in paths)
 text+='module OperationsUtf8Execution {\n  import S = BytecodeScanMachine\n  import G = BytecodeGetterMachine\n  import M = BytecodeExternalMachine\n  import E = OperationsCaseFoldExecution\n  import I = OperationsUtf8Inputs\n  import K = OperationsUtf8Kernel\n'
 text+=''.join(f'  import {a} = OperationsUtf8{p["name"]}\n' for a,p in zip(aliases,paths))
 text+='  predicate Matches(code:seq<S.Byte>,ret:S.Word) { '+' && '.join(f'{a}.Matches(code,ret)' for a in aliases)+' }\n'
 text+='  function Destinations(ret:S.Word):set<nat> { '+'+'.join(f'{a}.Destinations(ret)' for a in aliases)+' }\n'
 text+='  function Loop(prefix:seq<S.Word>,ret:S.Word,offset:S.Word,length:S.Word,cursor:S.Word,mem:seq<S.Byte>):M.Frame { M.Frame(S.Running(11585,prefix+[ret,offset,length,cursor],mem),[],0) }\n'
 text+='  function Final(prefix:seq<S.Word>,ret:S.Word,mem:seq<S.Byte>,verdict:I.Verdict):M.Frame\n    requires verdict.Invalid? ==> verdict.at<G.Modulus()\n  { if verdict.Valid? then M.Frame(S.Running(ret,prefix,mem),[],0) else M.Frame(S.Reverted(K.Packet(verdict.at)),[],0) }\n'
 common='K.Common(prefix,ret,data,offset,length,cursor,mem)'
 text+=f'  lemma Coverage({PARAMS})\n    requires {common}\n    ensures '+' || '.join(f'{a}.Admitted({ARGS})' for a in aliases[1:])+'\n  {\n    if cursor<length {\n      var first:=K.Cell(data,offset,length,cursor,0);var width:=I.Width(first);\n      if width>0 && cursor+width<=length { var unit:=I.Unit(K.Payload(data,offset,length),cursor); }\n    }\n  }\n'
 text+=f'  ghost method One(code:seq<S.Byte>,destinations:set<nat>,{PARAMS}) returns(state:M.Frame,trace:seq<M.Frame>,outcome:I.UnitResult)\n    requires Matches(code,ret) && Destinations(ret)<=destinations && {common} && cursor<length\n    ensures outcome==I.Unit(K.Payload(data,offset,length),cursor)\n    ensures E.Trace(code,destinations,self,value,data,observations,trace) && trace[0]==Loop(prefix,ret,offset,length,cursor,mem) && trace[|trace|-1]==state\n    ensures outcome.Good? ==> state==Loop(prefix,ret,offset,length,cursor+outcome.width,mem)\n    ensures outcome.Bad? ==> state==M.Frame(S.Reverted(K.Packet(outcome.at)),[],0)\n  {{ Coverage({ARGS});outcome:=I.Unit(K.Payload(data,offset,length),cursor);\n'
 for i,(alias,path) in enumerate(zip(aliases[2:],paths[2:])):
  text+=f'    {"if" if i==0 else "else if"} {alias}.Admitted({ARGS}) {{ state,trace:={alias}.Run(code,destinations,{ARGS}); }}\n'
 text+='    else { assert false;state:=Loop(prefix,ret,offset,length,cursor,mem);trace:=[state]; }\n  }\n'
 text+=f'  ghost method From(code:seq<S.Byte>,destinations:set<nat>,{PARAMS}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code,ret) && Destinations(ret)<=destinations && {common}\n    ensures state==Final(prefix,ret,mem,I.Check(K.Payload(data,offset,length),cursor))\n    ensures E.Trace(code,destinations,self,value,data,observations,trace) && trace[0]==Loop(prefix,ret,offset,length,cursor,mem) && trace[|trace|-1]==state\n    decreases length-cursor\n  {{\n    if cursor==length {{ state,trace:=P1.Run(code,destinations,{ARGS}); }}\n    else {{\n      var first,part,outcome:=One(code,destinations,{ARGS});\n      if outcome.Bad? {{ state:=first;trace:=part; }}\n      else {{\n        var tail,last:=From(code,destinations,prefix,ret,offset,length,cursor+outcome.width,mem,self,value,data,observations);\n        E.Join(code,destinations,self,value,data,observations,part,last);state:=tail;trace:=part+last[1..];\n      }}\n    }}\n  }}\n'
 text+=f'  ghost method Run(code:seq<S.Byte>,destinations:set<nat>,{ENTRY_PARAMS}) returns(state:M.Frame,trace:seq<M.Frame>)\n    requires Matches(code,ret) && Destinations(ret)<=destinations && K.Common(prefix,ret,data,offset,length,0,mem)\n    ensures state==Final(prefix,ret,mem,I.Check(K.Payload(data,offset,length),0))\n    ensures E.Trace(code,destinations,self,value,data,observations,trace) && trace[0]==M.Frame(S.Running(11583,prefix+[ret,offset,length],mem),[],0) && trace[|trace|-1]==state\n  {{\n    var entered,entry:=P0.Run(code,destinations,{ENTRY_ARGS});\n    state,trace:=From(code,destinations,{ENTRY_ARGS});\n    E.Join(code,destinations,self,value,data,observations,entry,trace);trace:=entry+trace[1..];\n  }}\n}}\n'
 r=subprocess.run([DAFNY,'format','--stdin','--print'],input=text.replace('include "','//FORMAT_INCLUDE "'),capture_output=True,text=True)
 if r.returncode:raise RuntimeError(r.stdout+r.stderr)
 out.mkdir(parents=True,exist_ok=True);(out/'Execution.generated.dfy').write_text(r.stdout.replace('//FORMAT_INCLUDE "','include "'))
 print('Prepared finite UTF8 outer induction, 52-class exact control closure, generic PC11583 Run; native pending')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--mapping',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.mapping,a.output)
