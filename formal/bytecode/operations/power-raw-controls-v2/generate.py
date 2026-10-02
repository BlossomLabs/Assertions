#!/usr/bin/env python3
"""Preserve exact raw power states and public contracts; compose bounded trace chunks."""
from pathlib import Path
import argparse,importlib.util,json,re,hashlib
HERE=Path(__file__).resolve().parent
original=HERE.parent/'power-raw-controls'
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output
spec=importlib.util.spec_from_file_location('original_power_raw',original/'generate.py');g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g);g.generate(out)
paths=json.loads((out/'raw.mapping.json').read_text())['paths'];assert (out/'raw.mapping.json').read_bytes()==(original/'raw.mapping.json').read_bytes()
args='code:seq<M.Byte>,destinations:set<nat>,value:M.Word,size:M.Word,word:M.Word,a:M.Word,b:M.Word'
vals='code,destinations,value,size,word,a,b';edge=lambda t:f'forall j:nat :: j+1<|{t}| ==> {t}[j+1]==E.Execute(code,destinations,{t}[j],value,size,word,a,b)'
join=f'''  lemma Join({args},left:seq<M.State>,right:seq<M.State>)
    requires |left|>0 && |right|>0 && left[|left|-1]==right[0]
    requires {edge('left')}
    requires {edge('right')}
    ensures {edge('(left+right[1..])')}
  {{
    forall j:nat | j+1<|left+right[1..]|
      ensures (left+right[1..])[j+1]==E.Execute(code,destinations,(left+right[1..])[j],value,size,word,a,b)
    {{
      if j+1<|left| {{ }} else {{
        var k:=j+1-|left|;
        assert k+1<|right|;
        assert (left+right[1..])[j]==right[k];
        assert (left+right[1..])[j+1]==right[k+1];
      }}
    }}
  }}
'''
records=[]
for p in paths:
 name=p['name'];file=out/(name+'.generated.dfy');text=file.read_text();head,run=text.split('  ghost method Run(',1);signature,body=run.split('  {\n',1);oldlines=body.splitlines();step=[l for l in oldlines if l.strip().startswith('Advance')];n=len(p['states']);assert len(step)==n
 req=next(l.strip() for l in signature.splitlines() if l.strip().startswith('requires '));chunks='';calls=[]
 for idx,lo in enumerate(range(0,n,16)):
  hi=min(lo+16,n);chunks+=f'''  ghost method Chunk{idx}({args},initial:M.State) returns(state:M.State,trace:seq<M.State>)
    {req} && Good({lo},initial,value,size,word,a,b)
    ensures Good({hi},state,value,size,word,a,b)
    ensures |trace|=={hi-lo+1} && trace[0]==initial && trace[|trace|-1]==state
    ensures {edge('trace')}
  {{ state:=initial;trace:=[state];
'''
  for i,l in enumerate(step[lo:hi],1):
   l=re.sub(r'assert \|trace\|==\d+',f'assert |trace|=={i+1}',l).replace('assert trace[0]==M.Running(0,[],[]);','assert trace[0]==initial;');chunks+=l+'\n'
  chunks+='  }\n';calls.append(f'    var next{idx},part{idx}:=Chunk{idx}({vals},state);Join({vals},trace,part{idx});trace:=trace+part{idx}[1..];state:=next{idx};\n')
 new=head+join+chunks+'  ghost method Run('+signature+'  {\n    state:=M.Running(0,[],[]);trace:=[state];Start(value,size,word,a,b);\n'+''.join(calls)+'    reveal Good();\n  }\n}\n'
 file.write_text(new);records.append(dict(name=name,instructions=n,chunks=len(calls),originalSha256=hashlib.sha256((original/file.name).read_bytes()).hexdigest(),preparedSha256=hashlib.sha256(new.encode()).hexdigest()))
print('Generated eight raw power owners with unchanged states/admission/terminal mapping and sixteen-instruction trace chunks')
