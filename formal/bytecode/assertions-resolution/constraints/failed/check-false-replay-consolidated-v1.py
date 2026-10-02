#!/usr/bin/env python3
"""Concrete full machine replay tied to the canonical serializer native PC maps."""
import argparse,hashlib,json,re,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
helper=runpy.run_path(str(HERE.parent/'or/check-structure-replay-consolidated-v1.py'))
stack,memory,oldstep=helper['stack'],helper['memory'],helper['step']
MOD=1<<256

def step(code,row):
    pc=row['pc'];op=code[pc]
    if op not in [22,25,94]:return oldstep(code,row)
    s=stack(row);m=memory(row)
    if op==22:a,b=s.pop(),s.pop();s.append(a&b)
    elif op==25:s.append((~s.pop())%MOD)
    else:
        dst,src,n=s.pop(),s.pop(),s.pop()
        if n:
            size=((max(dst+n,src+n)+31)//32)*32
            if size>len(m):m.extend(bytes(size-len(m)))
            copied=bytes(m[src:src+n]);m[dst:dst+n]=copied
    return pc+1,s,m,None

def main():
    p=argparse.ArgumentParser();p.add_argument('--receipts',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    code=bytes.fromhex(json.load(open(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json'))['deployedBytecode'][2:]);runtime=hashlib.sha256(code).hexdigest()
    maps={n:json.load(open(HERE/(n+'.mapping.json'))) for n in ['Caller','Start','Heads','End']}
    for m in maps.values():
        assert m['runtimeSha256']==runtime
        assert all(code[int(i)]==v for i,v in m['requiredBytes'].items())
    blobsource=(HERE/'Blob.generated.dfy').read_text();good=blobsource.split('opaque predicate Good')[1].split('  lemma')[0]
    blob=[int(x) for x in re.findall(r'state == S.Running\((\d+),',good)];assert len(blob)==40
    serial=[r['pc'] for r in maps['Start']['states']]+blob+[r['pc'] for r in maps['Heads']['states']]+blob+[r['pc'] for r in maps['End']['states']];assert len(serial)==165
    checks=[];instructions=0
    for path in sorted(a.receipts.glob('*.json')):
        fixture=json.load(open(path))
        if 'trace' not in fixture:continue
        assert fixture['runtimeSha256']==runtime
        logs=[r for r in fixture['trace']['structLogs'] if r['depth']==1]
        begin=next(i for i,r in enumerate(logs) if r['pc']==19793)
        if fixture['fixture']['kind']!=6:
            begin=next(i for i,r in enumerate(logs) if r['pc']==8035)
            pcs=[r['pc'] for r in maps['Caller']['states']]+serial
        else:pcs=serial
        reached=logs[begin:];assert [r['pc'] for r in reached]==pcs
        for i,row in enumerate(reached):
            pc,s,m,terminal=step(code,row)
            if terminal is None:
                following=reached[i+1];assert (pc,s,m)==(following['pc'],stack(following),memory(following)),(path.name,i,row['pc'])
            else:assert i==len(reached)-1 and fixture['trace']['failed'] and terminal==fixture['trace']['returnValue'].removeprefix('0x')
        instructions+=len(reached);checks.append({'fixture':path.name,'instructionCount':len(reached),'fullStackMemoryReplay':True})
    assert len(checks)==15
    result={'status':'passed','runtimeSha256':runtime,'instructionCount':instructions,'scope':'Concrete full machine replay of exact caller/serializer PC maps; public admission and OR false caller are not proved by these fixtures.','checks':checks}
    a.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS',instructions,'instructions',len(checks),'fixtures')
if __name__=='__main__':main()
