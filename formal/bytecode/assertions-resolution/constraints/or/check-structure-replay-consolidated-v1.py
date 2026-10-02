#!/usr/bin/env python3
"""Independent concrete opcode replay of every reached OR structural segment.

Discovery receipts do not establish universal/public admission; these checks bind
exact reached machine steps to the native segment maps, including full frames.
"""
import argparse, hashlib, json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
MOD=1<<256

def memory(row): return bytearray.fromhex(''.join(x.removeprefix('0x') for x in row['memory']))
def stack(row): return [int(x,16) for x in row['stack']]
def load(mem,p): return int.from_bytes((mem[p:p+32]+bytes(32))[:32],'big')
def step(code, row):
    pc=row['pc']; op=code[pc]; st=stack(row); mem=memory(row); nxt=pc+1
    def pop(): return st.pop()
    def expand(end):
        size=((end+31)//32)*32
        if size>len(mem): mem.extend(bytes(size-len(mem)))
    terminal=None
    if op==91: pass
    elif op==95: st.append(0)
    elif 96<=op<=127:
        n=op-95; st.append(int.from_bytes(code[nxt:nxt+n],'big')); nxt+=n
    elif 128<=op<=143: st.append(st[-(op-127)])
    elif 144<=op<=159:
        i=op-143; st[-1],st[-1-i]=st[-1-i],st[-1]
    elif op==80: pop()
    elif op in [1,2,3,16,17,20,27]:
        a,b=pop(),pop()
        result={1:lambda:a+b,2:lambda:a*b,3:lambda:a-b,
                16:lambda:int(a<b),17:lambda:int(a>b),20:lambda:int(a==b),27:lambda:b<<a}[op]()
        st.append(result%MOD)
    elif op==21: st.append(int(pop()==0))
    elif op==81:
        p=pop(); expand(p+32);st.append(load(mem,p))
    elif op==82:
        p,v=pop(),pop();expand(p+32);mem[p:p+32]=v.to_bytes(32,'big')
    elif op==86: nxt=pop()
    elif op==87:
        p,c=pop(),pop()
        if c: nxt=p
    elif op==253:
        p,n=pop(),pop();expand(p+n);terminal=bytes(mem[p:p+n]).hex()
    else: raise AssertionError(('Unsupported reached opcode',pc,op))
    return nxt,st,mem,terminal

def main():
    p=argparse.ArgumentParser();p.add_argument('--receipts',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    code=bytes.fromhex(json.load(open(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json'))['deployedBytecode'][2:]); digest=hashlib.sha256(code).hexdigest()
    maps={name:json.load(open(HERE/('Structure'+name+'.mapping.json'))) for name in ['Start','Iteration','Nested','Exit']}
    for name,m in maps.items():
        assert m['runtimeSha256']==digest
        for guard in m['requiredBytes']:
            assert code[int(guard)]==m['requiredBytes'][guard]
    checks=[];covered=set();executions=0
    for f in sorted(a.receipts.glob('*.json')):
        fixture=json.load(open(f))
        if 'trace' not in fixture:continue
        assert fixture['runtimeSha256']==digest
        logs=[r for r in fixture['trace']['structLogs'] if r['depth']==1]
        starts=[i for i,r in enumerate(logs) if r['pc']==7777]
        for begin in starts:
            if load(memory(logs[begin]),stack(logs[begin])[-1])==0: continue
            at=begin
            while True:
                row=logs[at]
                if row['pc']==7777:name='Start'
                elif row['pc']==7831:
                    s=stack(row);mem=memory(row);arrayptr,pos=s[-2:];count=load(mem,arrayptr)
                    name='Exit' if pos>=count else 'Nested' if load(mem,load(mem,arrayptr+32+pos*32))==6 else 'Iteration'
                else:raise AssertionError(('Unexpected structural boundary',row['pc']))
                mapping=maps[name]['states'];assert [r['pc'] for r in logs[at:at+len(mapping)]]==[r['pc'] for r in mapping],(f.name,name,at,[r['pc'] for r in logs[at:at+len(mapping)]],[r['pc'] for r in mapping])
                for j,m in enumerate(mapping):
                    r=logs[at+j];assert code[r['pc']]==m['op']
                    nxt,st,mem,terminal=step(code,r)
                    if terminal is None:
                        following=logs[at+j+1]
                        assert (nxt,st,mem)==(following['pc'],stack(following),memory(following)),(f.name,name,j,r['pc'])
                    else:
                        assert fixture['trace']['failed'] and terminal==fixture['trace']['returnValue'].removeprefix('0x')
                    executions+=1
                checks.append({'fixture':f.name,'segment':name,'instructionCount':len(mapping),'startIndex':at,'fullStackMemoryReplay':True});covered.add(name);at+=len(mapping)
                if name in ['Exit','Nested']:break
    assert covered==set(maps)
    result={'status':'passed','scope':'Independent full stack/memory concrete replay of reached structural helper segments; no public completion claim.','runtimeSha256':digest,'instructionCount':executions,'checks':checks,'mapSha256':{name:hashlib.sha256((HERE/('Structure'+name+'.mapping.json')).read_bytes()).hexdigest() for name in maps}}
    a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS',executions,'instructions',len(checks),'segment executions')
if __name__=='__main__':main()
