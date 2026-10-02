#!/usr/bin/env python3
"""Complete bounded compositions of all exact strict-index control steps."""
import argparse,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--mapping-root',type=Path,default=HERE);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
for name in ['InvalidHigh','InvalidLow','Positive','Negative']:
 m=json.loads((a.mapping_root/(name+'.mapping.json')).read_text());nodes=m['states'];limit=len(nodes)-int(nodes[-1].get('frontier',False));terminal=nodes[-1].get('terminal',False)
 head='// SPDX-License-Identifier: MIT\n// Generated full strict-index path composition. Never edit directly.\ninclude "'+name+'.generated.dfy"\n'
 imports='  import opened OperationsByteAtMachine\n  import I = OperationsByteAtInputs\n  import N = OperationsByteAtIndices\n  import O = OperationsByteAtOutput\n  import R = OperationsByteAtIndex'+name+'\n'
 parts=[]
 for low in range(0,limit,20):
  high=min(low+20,limit);label=name+'Block'+str(low//20);mod='OperationsByteAtIndex'+label;parts.append((label,mod));post='state==Reverted(I.InvalidIndex(I.Index(data),I.Length(data)))' if terminal and high==limit else f'R.Good({high},state,value,data)';body='    state:=initial;trace:=[state];\n'
  for i in range(low,high):body+=f'    R.Advance{i}(code,state,value,data);\n    state:=Step(code,R.Destinations(),state,value,data);trace:=trace+[state];\n'
  text=head+'module '+mod+' {\n'+imports+f'''  ghost method Run(code:seq<Byte>,initial:State,value:Word,data:seq<Byte>) returns(state:State,trace:seq<State>)
    requires R.Admitted(value,data) && R.Matches(code) && R.Good({low},initial,value,data)
    ensures {post}
    ensures |trace|=={high-low+1} && trace[0]==initial && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==Step(code,R.Destinations(),trace[j],value,data)
  {{
{body}  }}
}}
''';(a.output/(label+'.generated.dfy')).write_text(text)
 text=head+'\n'.join('include "'+label+'.generated.dfy"' for label,_ in parts)+'\nmodule OperationsByteAtIndex'+name+'Entry {\n'+imports+''.join('  import B'+str(i)+' = '+mod+'\n' for i,(_,mod) in enumerate(parts))
 text+='''  lemma Append(code:seq<Byte>,x:seq<State>,y:seq<State>,value:Word,data:seq<Byte>)
    requires I.Frame(data) && |x|>0 && |y|>0 && x[|x|-1]==y[0]
    requires forall j:nat :: j+1<|x| ==> x[j+1]==Step(code,R.Destinations(),x[j],value,data)
    requires forall j:nat :: j+1<|y| ==> y[j+1]==Step(code,R.Destinations(),y[j],value,data)
    ensures forall j:nat :: j+1<|x+y[1..]| ==> (x+y[1..])[j+1]==Step(code,R.Destinations(),(x+y[1..])[j],value,data)
  {
    forall j:nat | j+1<|x+y[1..]|
      ensures (x+y[1..])[j+1]==Step(code,R.Destinations(),(x+y[1..])[j],value,data)
    { if j+1<|x| {} else if j+1==|x| { assert y[0]==x[|x|-1]; } else { assert (x+y[1..])[j]==y[j-|x|+1]; } }
  }
'''
 post='state==Reverted(I.InvalidIndex(I.Index(data),I.Length(data)))' if terminal else 'state==Running(7156,[0x9ae8e8ea,1362,I.Offset(data)+36,I.Length(data),I.Index(data),96,0,N.Position(I.Index(data),I.Length(data))],O.InitialHeap())'
 text+=f'''  ghost method Run(code:seq<Byte>,initial:State,value:Word,data:seq<Byte>) returns(state:State,trace:seq<State>)
    requires R.Admitted(value,data) && R.Matches(code)
    requires initial==Running(7143,[0x9ae8e8ea,1362,I.Offset(data)+36,I.Length(data),I.Index(data)],O.InitialHeap())
    ensures {post}
    ensures |trace|=={limit+1} && trace[0]==initial && trace[|trace|-1]==state
    ensures forall j:nat :: j+1<|trace| ==> trace[j+1]==Step(code,R.Destinations(),trace[j],value,data)
  {{
    R.Start(value,data);state:=initial;trace:=[state];
'''
 for i in range(len(parts)):text+=f'    var t{i}:seq<State>;state,t{i}:=B{i}.Run(code,state,value,data);Append(code,trace,t{i},value,data);trace:=trace+t{i}[1..];\n'
 if not terminal:text+='    R.Frontier(state,value,data);\n'
 text+='  }\n}\n';(a.output/(name+'Entry.generated.dfy')).write_text(text);print(name,limit,'actualsteps',len(parts),'blocks')
