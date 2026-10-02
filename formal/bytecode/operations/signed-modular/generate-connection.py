#!/usr/bin/env python3
"""Generate complete complementary class/raw-entry composition; native proof pending."""
import argparse
from pathlib import Path
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 cases=[('AddModS',18),('MulModS',9)];names=[family+'Case'+str(i) for family,count in cases for i in range(count)]
 include='\n'.join('include "'+n+'.generated.dfy"' for n in names)
 include+='\n'+ '\n'.join('include "rejections/'+n+'.generated.dfy"' for n in ['Nonzero','Short','AddModSArgs','MulModSArgs'])
 imports='\n'.join('  import '+n+' = OperationsSignedModularOpcode'+n for n in names)
 imports+='\n'+ '\n'.join('  import '+n+' = OperationsSignedModularOpcodeRaw'+n for n in ['Nonzero','Short','AddModSArgs','MulModSArgs'])
 matches=' && '.join(n+'.Matches(code)' for n in names+['Nonzero','Short','AddModSArgs','MulModSArgs'])
 dispatch=[]
 for family,count in cases:
  prefix='Add' if family.startswith('Add') else 'Mul'
  lines=['      P.'+prefix+'Partition(a,b,c);','      var id := P.'+prefix+'Class(a,b,c);']
  for i in range(count):lines.append(('      if' if i==0 else '      else if' if i<count-1 else '      else')+(' id == '+str(i) if i<count-1 else '')+' { state := '+family+'Case'+str(i)+'.Run(code,value,size,word,a,b,c); }')
  dispatch.append('\n'.join(lines))
 text=f'''// SPDX-License-Identifier: MIT
// Generated complete class/raw-entry composition. Never edit directly.
{include}
module OperationsSignedModularOpcodeConnection {{
  import opened OperationsSignedModularOpcodeMachine
  import S = OperationsSignedModularMath
  import P = OperationsSignedModularInputs
{imports}
  function DataWord(data: seq<Byte>,offset: nat): Word {{ Load(data,offset) }}
  predicate Frame(data: seq<Byte>) {{ |data| < 0x10000000000000000 }}
  function RawStep(code: seq<Byte>,destinations: set<nat>,state: State,value: Word,data: seq<Byte>): State
    requires Frame(data)
  {{ Step(code,destinations,state,value,|data| as Word,DataWord(data,0),DataWord(data,4),DataWord(data,36),DataWord(data,68)) }}
  predicate Assigned(selector: Word) {{ selector in {{0x289b860c,0x3daa08a5}} }}
  function Expected(selector: Word,a: Word,b: Word,c: Word): Word {{
    if c==0 then 0 else if selector==0x289b860c then S.Add(a,b,c) else S.Multiply(a,b,c)
  }}
  opaque predicate Matches(code: seq<Byte>) {{ {matches} }}
  ghost method Run(code: seq<Byte>,value: Word,data: seq<Byte>) returns (state: State)
    requires Frame(data) && Matches(code)
    requires value!=0 || |data|<4 || Assigned(Selector(DataWord(data,0)))
    ensures value!=0 || |data|<100 ==> state==Reverted([])
    ensures value==0 && |data|>=100 && DataWord(data,68)==0 ==> state==Reverted(Panic(18))
    ensures value==0 && |data|>=100 && DataWord(data,68)>0 ==> state==Returned(Encode(Expected(Selector(DataWord(data,0)),DataWord(data,4),DataWord(data,36),DataWord(data,68)),32))
  {{
    reveal Matches(); var size:=|data| as Word; var word:=DataWord(data,0);
    var a:=DataWord(data,4); var b:=DataWord(data,36); var c:=DataWord(data,68);
    LoadProjection(data,0); LoadProjection(data,4); LoadProjection(data,36); LoadProjection(data,68);
    if value!=0 {{ state:=Nonzero.Run(code,value,size,word,a,b,c); }}
    else if size<4 {{ state:=Short.Run(code,value,size,word,a,b,c); }}
    else if size<100 {{
      if Selector(word)==0x289b860c {{ state:=AddModSArgs.Run(code,value,size,word,a,b,c); }}
      else {{ state:=MulModSArgs.Run(code,value,size,word,a,b,c); }}
    }}
    else if Selector(word)==0x289b860c {{
{dispatch[0]}
    }} else {{
{dispatch[1]}
    }}
  }}
}}
'''
 (a.output/'Connection.generated.dfy').write_text(text)
if __name__=='__main__':main()
