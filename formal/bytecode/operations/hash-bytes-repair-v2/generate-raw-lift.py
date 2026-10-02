#!/usr/bin/env python3
"""Generate complete actual-calldata rejection lifts; generation provides no proof credit."""
import argparse,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
NAMES=['Nonzero','Short','Args','OffsetBound','LengthWindow','LengthBound','PayloadWindow']
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--mapping-root',type=Path,default=HERE);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
for name in NAMES:
 mapping=json.loads((a.mapping_root/(name+'.mapping.json')).read_text());nodes=mapping['states'];assert nodes[-1].get('reverted')
 args='code: seq<Byte>,initial: State,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>'
 actual='|data|<0x10000000000000000 && word==E.DataWord(data,0) && a==E.DataWord(data,4) && b==E.DataWord(data,(a as nat)+4)'
 params='code,state,value,|data|,word,a,b'
 imports='  import opened OperationsHashBytesMachine\n  import E = OperationsHashBytesExecution\n  import R = OperationsHashBytes'+name+'\n'
 header='// SPDX-License-Identifier: MIT\n// Generated actual calldata trace lift. Never edit directly.\ninclude "Execution.dfy"\ninclude "'+name+'.generated.dfy"\n'
 includes=[];calls=[];entryimports=imports
 for low in range(0,len(nodes),20):
  high=min(low+20,len(nodes));label=name+'RawBlock'+str(low//20);mod='OperationsHashRawBlock'+name+str(low//20)
  post='R.Good('+str(high)+',state,value,|data|,word,a,b)' if high<len(nodes) else 'state==Reverted([])'
  body='    var size: Word:=|data|; state:=initial;\n'
  for i in range(low,high):
   n=nodes[i];assert n['opcode'] not in [0x20,0x37]
   body+='    R.Advance'+str(i)+'('+params+');\n    reveal R.Good(); reveal R.Matches();\n'
   body+='    assert state==Running('+str(n['pc'])+',['+','.join(n['stack'])+'],'+n['memory']+');\n'
   body+='    E.RawAgreement(code,R.Destinations(),state,data,value,a,hashes);\n'
   body+='    state:=E.Execute(code,R.Destinations(),state,data,value,a,hashes);\n'
  text=header+'module '+mod+' {\n'+imports+'  ghost method RunBlock('+args+') returns(state: State)\n'
  text+='    requires '+actual+'\n    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b) && R.Good('+str(low)+',initial,value,|data|,word,a,b)\n    ensures '+post+'\n  {\n'+body+'  }\n}\n'
  (a.output/(label+'.generated.dfy')).write_text(text)
  includes.append('include "'+label+'.generated.dfy"');entryimports+='  import B'+str(low//20)+' = '+mod+'\n';calls.append('    state:=B'+str(low//20)+'.RunBlock(code,state,data,value,word,a,b,hashes);')
 text=header+'\n'.join(includes)+'\nmodule OperationsHashRawEntry'+name+' {\n'+entryimports
 text+='  ghost method Run(code: seq<Byte>,data: seq<Byte>,value: Word,word: Word,a: Word,b: Word,hashes: map<seq<Byte>,Word>) returns(state: State)\n'
 text+='    requires '+actual+'\n    requires R.Matches(code) && R.Admitted(value,|data|,word,a,b)\n    ensures state==Reverted([])\n  {\n    R.Start(value,|data|,word,a,b); state:=Running(0,[],[]);\n'+'\n'.join(calls)+'\n  }\n}\n'
 (a.output/(name+'Raw.generated.dfy')).write_text(text)
 print(name,len(nodes),'physical actual-calldata instructions')
