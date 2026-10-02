from pathlib import Path
import json,runpy,hashlib
root=Path(__file__).resolve().parents[3]
model=runpy.run_path(str(root/'formal/bytecode/assertions-resolution/constrained-raw/public/check-false-replay-consolidated-v1.py'))
oldstep,stack,memory=model['step'],model['stack'],model['memory']
def step(code,row,data):
 if code[row['pc']] != 26:return oldstep(code,row,data)
 st=stack(row);index=st.pop();word=st.pop();st.append(0 if index>=32 else (word>>(8*(31-index)))&255)
 return row['pc']+1,st,memory(row),None
code=bytes.fromhex(json.loads((root/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:])
folder=root/'formal/bytecode/assertions-navigation/development/leading-zero-parser-physical-v1'
checks=[]
for p in sorted(folder.glob('case-*.json')):
 d=json.loads(p.read_text());assert d['runtimeSha256']==hashlib.sha256(code).hexdigest()
 rows=[r for r in d['trace']['structLogs'] if r['depth']==1]
 begin=next(i for i,r in enumerate(rows) if r['pc']==8442)
 initial=stack(rows[begin]);ret=initial[-5];prefix=initial[:-5]
 end=next(i for i in range(begin+1,len(rows)) if rows[i]['pc']==ret and len(stack(rows[i]))==len(prefix)+3)
 for i in range(begin,end):
  pc,s,m,terminal=step(code,rows[i],bytes.fromhex(d['data'][2:]));n=rows[i+1]
  assert terminal is None and (pc,s,m)==(n['pc'],stack(n),memory(n)),(p.name,i,rows[i]['pc'])
 final=stack(rows[end]);assert final[:-3]==prefix and memory(rows[begin])==memory(rows[end])
 assert final[-3]==initial[-2]+len(d['descriptor'].encode())
 assert final[-2:]==[1,1]
 checks.append({'fixture':p.name,'descriptor':d['descriptor'],'instructions':end-begin,'fullStackMemoryReplay':True,'parserCalls':sum(r['pc']==8442 for r in rows[begin:end])})
assert len(checks)==4
result={'status':'passed','scope':'Four complete recursive canonical parser traces, PC8442 to original return, full physical state at every instruction; no universal or public entry credit','checks':checks,'instructions':sum(x['instructions'] for x in checks)}
out=folder/'full-parser-replay.json';assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n');print('PASS',result['instructions'],'full-state parser instructions')
