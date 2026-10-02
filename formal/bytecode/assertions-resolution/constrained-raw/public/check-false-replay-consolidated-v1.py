#!/usr/bin/env python3
"""Independently replay every reached frame in public RAW first-false receipts."""
import argparse,hashlib,json,runpy
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
helper=runpy.run_path(str(HERE.parent.parent/'constraints/failed/check-false-replay-consolidated-v1.py'))
oldstep,stack,memory=helper['step'],helper['stack'],helper['memory'];MOD=1<<256

def step(code,row,data):
    pc=row['pc'];op=code[pc]
    if op not in [4,18,19,23,28,52,53,54,55]:return oldstep(code,row)
    s=stack(row);m=memory(row)
    def signed(v):return v if v<(1<<255) else v-MOD
    if op in [4,18,19,23,28]:
        a,b=s.pop(),s.pop()
        value={4:lambda:0 if b==0 else a//b,18:lambda:int(signed(a)<signed(b)),19:lambda:int(signed(a)>signed(b)),23:lambda:a|b,28:lambda:0 if a>=256 else b>>a}[op]();s.append(value)
    elif op==52:s.append(0)
    elif op==53:
        offset=s.pop();s.append(int.from_bytes((data[offset:offset+32]+bytes(32))[:32],'big'))
    elif op==54:s.append(len(data))
    else:
        dst,src,n=s.pop(),s.pop(),s.pop()
        if n:
            size=((dst+n+31)//32)*32
            if size>len(m):m.extend(bytes(size-len(m)))
            copied=data[src:src+n];m[dst:dst+n]=copied+bytes(n-len(copied))
    return pc+1,s,m,None

def main():
    p=argparse.ArgumentParser();p.add_argument('--receipts',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    code=bytes.fromhex(json.load(open(ROOT/'artifacts/contracts/Assertions.sol/Assertions.json'))['deployedBytecode'][2:]);runtime=hashlib.sha256(code).hexdigest();checks=[];instructions=0
    for path in sorted(a.receipts.glob('*.json')):
        fixture=json.load(open(path))
        if 'trace' not in fixture:continue
        assert fixture['runtimeSha256']==runtime
        logs=[r for r in fixture['trace']['structLogs'] if r['depth']==1];data=bytes.fromhex(fixture['data'][2:]);assert logs[0]['pc']==0 and stack(logs[0])==[] and memory(logs[0])==bytearray()
        for i,row in enumerate(logs):
            pc,s,m,terminal=step(code,row,data)
            if terminal is None:
                following=logs[i+1];assert (pc,s,m)==(following['pc'],stack(following),memory(following)),(path.name,i,row['pc'])
            else:assert i==len(logs)-1 and fixture['trace']['failed'] and '0x'+terminal==fixture['expected'] and terminal==fixture['trace']['returnValue'].removeprefix('0x')
        checks.append({'fixture':path.name,'instructionCount':len(logs),'fullStackMemoryReplay':True,'fromPC0':True});instructions+=len(logs)
    assert len(checks)==12;result={'status':'passed','scope':'Independent concrete full physical public RAW first-false executions; universal class credit additionally requires native public admission/closure.','runtimeSha256':runtime,'instructionCount':instructions,'checks':checks};a.output.write_text(json.dumps(result,indent=2)+'\n');print('PASS',instructions,'instructions',len(checks),'fixtures')
if __name__=='__main__':main()
