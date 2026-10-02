#!/usr/bin/env python3
"""Derive bounded checked compositions of every admitted raw prefix step."""
import argparse,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--mapping-root',type=Path,default=HERE);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=json.loads((a.mapping_root/'Prefix.mapping.json').read_text());nodes=m['states'];assert len(nodes)==171 and nodes[-1]['pc']==7143
imports='  import opened OperationsByteAtMachine\n  import I = OperationsByteAtInputs\n  import R = OperationsByteAtSuccessPrefix\n'
head='// SPDX-License-Identifier: MIT\n// Generated complete raw prefix composition. Never edit directly.\ninclude "Prefix.generated.dfy"\n'
parts=[]
for low in range(0,len(nodes)-1,20):
 high=min(low+20,len(nodes)-1);label='PrefixBlock'+str(low//20);module='OperationsByteAtSuccess'+label;parts.append((label,module,low,high));body='    state:=initial; trace:=[state];\n'
 for i in range(low,high):body+=f'    R.Advance{i}(code,state,value,data);\n    state:=Step(code,R.Destinations(),state,value,data); trace:=trace+[state];\n'
 text=head+'module '+module+' {\n'+imports+f'''  ghost method Run(code: seq<Byte>,initial: State,value: Word,data: seq<Byte>) returns(state: State,trace: seq<State>)
    requires R.Admitted(value,data) && R.Matches(code) && R.Good({low},initial,value,data)
    ensures R.Good({high},state,value,data)
    ensures |trace|=={high-low+1} && trace[0]==initial && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==Step(code,R.Destinations(),trace[j],value,data)
  {{
{body}  }}
}}
'''
 (a.output/(label+'.generated.dfy')).write_text(text)
text=head+'\n'.join('include "'+label+'.generated.dfy"' for label,_,_,_ in parts)+'\nmodule OperationsByteAtSuccessPrefixEntry {\n'+imports
text+=''.join('  import B'+str(i)+' = '+module+'\n' for i,(_,module,_,_) in enumerate(parts))
text+='''  lemma Append(code: seq<Byte>,a: seq<State>,b: seq<State>,value: Word,data: seq<Byte>)
    requires I.Frame(data) && |a|>0 && |b|>0 && a[|a|-1]==b[0]
    requires forall j:nat :: j+1<|a| ==> a[j+1]==Step(code,R.Destinations(),a[j],value,data)
    requires forall j:nat :: j+1<|b| ==> b[j+1]==Step(code,R.Destinations(),b[j],value,data)
    ensures forall j:nat :: j+1<|a+b[1..]| ==> (a+b[1..])[j+1]==Step(code,R.Destinations(),(a+b[1..])[j],value,data)
  {
    forall j:nat | j+1<|a+b[1..]|
      ensures (a+b[1..])[j+1]==Step(code,R.Destinations(),(a+b[1..])[j],value,data)
    {
      if j+1<|a| {} else if j+1==|a| { assert b[0]==a[|a|-1]; } else { assert (a+b[1..])[j]==b[j-|a|+1]; }
    }
  }
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns(state: State,trace: seq<State>)
    requires R.Admitted(value,data) && R.Matches(code)
    ensures state==Running(7143,[0x9ae8e8ea,1362,I.Offset(data)+36,I.Length(data),I.Index(data)],OperationsByteAtMemory.Copy([],I.Encode(128,32),0,64,32))
    ensures |trace|==171 && trace[0]==Running(0,[],[]) && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==Step(code,R.Destinations(),trace[j],value,data)
  {
    R.Start(value,data);state:=Running(0,[],[]);trace:=[state];
'''
for i,(_,_,low,high) in enumerate(parts):text+=f'    var t{i}:seq<State>;state,t{i}:=B{i}.Run(code,state,value,data);\n    Append(code,trace,t{i},value,data);trace:=trace+t{i}[1..];\n'
text+='    R.Frontier(state,value,data);\n  }\n}\n';text=text.replace('  import I = OperationsByteAtInputs','  import Memory = OperationsByteAtMemory\n  import I = OperationsByteAtInputs').replace('OperationsByteAtMemory.Copy','Memory.Copy');(a.output/'Entry.generated.dfy').write_text(text)
print('Generated',len(parts),'blocks, all170actualPCzero steps')
