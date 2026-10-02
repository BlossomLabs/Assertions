#!/usr/bin/env python3
"""Preserve byte-derived decimal raw states; use checked delegation and bounded traces."""
from pathlib import Path
import argparse,importlib.util,json,re
HERE=Path(__file__).resolve().parent;original=HERE.parent/'tostring-raw'
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output
s=importlib.util.spec_from_file_location('original_decimal_raw',original/'generate.py');g=importlib.util.module_from_spec(s);s.loader.exec_module(g);g.generate(out)
paths=json.loads((out/'raw.mapping.json').read_text())['paths'];assert (out/'raw.mapping.json').read_bytes()==(original/'raw.mapping.json').read_bytes()
for path in paths:
 file=out/(path['name']+'.generated.dfy');text=file.read_text();needle='reveal Good(); reveal F.Step(); reveal M.Step(); reveal C.Step(); reveal S.Step(); reveal G.Step();';replacement='reveal Good();F.Delegate(code,destinations,state,self,value,data,observations);M.Delegate(code,destinations,state,self,value,data,observations);C.Delegate(code,destinations,state.state,value,data);reveal S.Step();reveal G.Step();';n=len(path['nodes']);assert text.count(needle)==n;text=text.replace(needle,replacement)
 head,run=text.split('  ghost method Run(',1);signature,body=run.split('  {\n',1);lines=body.splitlines();steps=[l for l in lines if l.strip().startswith('Advance')];assert len(steps)==n
 req=next(l.strip() for l in signature.splitlines() if l.strip().startswith('requires '));params='code:seq<S.Byte>,destinations:set<nat>,self:S.Word,value:S.Word,data:seq<S.Byte>,observations:seq<M.Observation>';args='self,value,data,observations';chunks='';calls=[]
 for ci,lo in enumerate(range(0,n,16)):
  hi=min(lo+16,n);chunks+=f'  ghost method Chunk{ci}({params},initial:M.Frame) returns(state:M.Frame,trace:seq<M.Frame>)\n    {req} && Good({lo},initial,{args})\n    ensures Good({hi},state,{args})\n    ensures E.Trace(code,destinations,self,value,data,observations,trace) && |trace|=={hi-lo+1} && trace[0]==initial && trace[|trace|-1]==state\n  {{ state:=initial;trace:=[state];\n'
  for k,l in enumerate(steps[lo:hi],1):chunks+=re.sub(r'assert \|trace\|==\d+',f'assert |trace|=={k+1}',l).replace('assert trace[0]==M.Frame(S.Running(0,[],[]),[],0);','assert trace[0]==initial;')+'\n'
  chunks+='  }\n';calls.append(f'    var next{ci},part{ci}:=Chunk{ci}(code,destinations,{args},state);E.Join(code,destinations,self,value,data,observations,trace,part{ci});trace:=trace+part{ci}[1..];state:=next{ci};\n')
 initial=next(l for l in lines if l.strip().startswith('state:='));file.write_text(head+chunks+'  ghost method Run('+signature+'  {\n'+initial+'\n'+''.join(calls)+'    reveal Good();\n  }\n}\n')
print('Generated unchanged decimal raw contracts/states with checked delegation and sixteen-instruction trace chunks')
