#!/usr/bin/env python3
"""Generate actual checked-add successful path for the sum loop continuation."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];MOD=1<<256

def generate(out):
    code=bytes.fromhex(json.loads((ROOT/'artifacts/contracts/Collections.sol/Collections.json').read_text())['deployedBytecode'][2:])
    assert hashlib.sha256(code).hexdigest()==json.loads((ROOT/'formal/bytecode/dispatch/inventory.json').read_text())['Collections']['runtimeSha256']
    ins={};pc=0
    while pc<len(code):
        op=code[pc];w=op-95 if 96<=op<=127 else 0;ins[pc]=(op,pc+1+w,int.from_bytes(code[pc+1:pc+1+w].ljust(w,b'\0'),'big'));pc+=1+w
    destinations={p for p,(op,_,_) in ins.items() if op==91}
    s=[(0xb58,'2904'),(3,'a'),(7,'b')];pc=0x5c34;states=[];required={};targets=set();seen=set()
    while pc!=0xb58:
        assert pc not in seen;seen.add(pc);op,nxt,imm=ins[pc]
        for p in range(pc,nxt):required[p]=code[p]
        states.append({'id':len(states),'pc':pc,'stack':[e[1] for e in s],'op':op,'next':nxt,'immediate':imm})
        if op==0x5b:pass
        elif op==0x5f or 96<=op<=127:s.append((imm,str(imm)))
        elif 0x80<=op<=0x8f:s.append(s[-(op-0x7f)])
        elif 0x90<=op<=0x9f:k=op-0x8f;s[-1],s[-1-k]=s[-1-k],s[-1]
        elif op==0x50:s.pop()
        elif op==0x01:x,y=s.pop(),s.pop();s.append(((x[0]+y[0])%MOD,'Sum(a,b)'))
        elif op==0x11:x,y=s.pop(),s.pop();s.append((int(x[0]>y[0]),str(int(x[0]>y[0]))))
        elif op==0x15:x=s.pop();s.append((int(x[0]==0),str(int(x[0]==0))))
        elif op==0x57:
            dest,truth=s.pop(),s.pop();assert dest[1].isdecimal() and dest[0] in destinations;targets.add(dest[0]);required[dest[0]]=code[dest[0]]
            if truth[0]:nxt=dest[0]
        elif op==0x56:
            dest=s.pop();assert dest[1].isdecimal() and dest[0] in destinations;targets.add(dest[0]);required[dest[0]]=code[dest[0]];nxt=dest[0]
        else:raise ValueError((pc,op))
        pc=nxt
    assert [x[1] for x in s]==['Sum(a,b)']
    matches=' &&\n    '.join(f'code[{p}] == {v}' for p,v in sorted(required.items()))
    good='\n'.join('    '+('if' if n['id']==0 else 'else if')+f" id == {n['id']} then state == Running({n['pc']},prefix+[{','.join(n['stack'])}],mem)" for n in states)+'\n    else false'
    text=f'''// SPDX-License-Identifier: MIT
// Generated from the pinned current Collections checked-add helper.
include "Fetch.dfy"
module BytecodeScanCheckedAdd {{
  import opened BytecodeScanMachine
  import F = BytecodeScanFetch
  import G = BytecodeGetterMachine
  function Sum(a: Word, b: Word): Word {{ ((a as nat)+(b as nat))%G.Modulus() }}
  predicate Admitted(prefix: seq<Word>, a: Word, b: Word) {{ |prefix| <= 1000 && (a as nat)+(b as nat) < G.Modulus() }}
  opaque predicate Matches(code: seq<Byte>) {{ |code| == {len(code)} &&
    {matches}
  }}
  function Destinations(): set<nat> {{ {{{','.join(map(str,sorted(targets)))}}} }}
  opaque predicate Good(id: nat, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>) {{
    Admitted(prefix,a,b) && (
{good})
  }}
'''
    for n in states:
        i=n['id'];post=f'next == Running(2904,prefix+[Sum(a,b)],mem)' if i==len(states)-1 else f'Good({i+1},next,prefix,a,b,mem)'
        fetch=f"    F.Push{n['op']-95}(code,{n['pc']});\n" if n['op'] in [96,97] else ''
        text+=f'''  lemma Advance{i}(code: seq<Byte>, state: State, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>)
    requires Matches(code) && Good({i},state,prefix,a,b,mem)
    ensures state.Running? && |state.stack| <= 1007
    ensures var next := Step(code,Destinations(),state,value,data); {post}
  {{
    reveal Matches(); reveal Good(); reveal Step();
    assert state == Running({n['pc']},prefix+[{','.join(n['stack'])}],mem);
{fetch}    assert Fetch(code,{n['pc']}) == Op({n['op']},{n['next']},{n['immediate']});
  }}
'''
    calls='\n'.join(f'    Advance{i}(code,state,prefix,a,b,mem,value,data);\n    state := Step(code,Destinations(),state,value,data);' for i in range(len(states)))
    text+=f'''  lemma Start(prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>)
    requires Admitted(prefix,a,b)
    ensures Good(0,Running(23604,prefix+[2904,a,b],mem),prefix,a,b,mem)
  {{ reveal Good(); }}
  ghost method Run(code: seq<Byte>, prefix: seq<Word>, a: Word, b: Word, mem: seq<Byte>, value: Word, data: seq<Byte>) returns (state: State)
    requires Matches(code) && Admitted(prefix,a,b)
    ensures state == Running(2904,prefix+[(a as nat)+(b as nat)],mem)
  {{
    Start(prefix,a,b,mem);
    state := Running(23604,prefix+[2904,a,b],mem);
{calls}
  }}
}}
'''
    out.mkdir(parents=True,exist_ok=True);(out/'CheckedAdd.generated.dfy').write_text(text);(out/'CheckedAdd.mapping.json').write_text(json.dumps({'runtimeSha256':hashlib.sha256(code).hexdigest(),'states':states,'requiredBytes':required,'scope':'successful checked addition; overflow and loop composition remain open'},indent=2)+'\n');print('CheckedAdd',len(states),'actual helper states')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
    import subprocess,sys
    subprocess.run([sys.executable,'-B',HERE/'format-generated.py','--output',a.output,'--include-root',HERE],check=True)
