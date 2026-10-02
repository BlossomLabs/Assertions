from pathlib import Path
import argparse,json,hashlib
owner=Path(__file__).resolve().parent;repo=owner.parents[3]
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--report',type=Path,required=True);a=p.parse_args();m=json.loads((owner/'mapping.json').read_text());code=bytes.fromhex(json.loads((repo/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert hashlib.sha256(code).hexdigest()==m['runtimeSha256'];counts={x['name']:0 for x in m['paths']};states=0;base=bytes(64)+(128).to_bytes(32,'big')
for row in json.loads((a.directory/'results.json').read_text()):
 t=json.loads((a.directory/row['trace']).read_text());ls=t['trace']['structLogs']
 for path in m['paths']:
  entry=next((i for i,s in enumerate(ls) if s['pc']==path['states'][0]['pc']),None)
  if entry is None:continue
  stack=[int(x,16) for x in ls[entry]['stack']];env=dict(offset=stack[2],length=stack[3],word=stack[4]);counts[path['name']]+=1
  for j,n in enumerate(path['states']):
   s=ls[entry+j];assert s['pc']==n['pc'] and code[n['pc']]==n['opcode'] and [eval(x,{'__builtins__':{}},env) for x in n['stack']]==[int(x,16) for x in s['stack']] and bytes.fromhex(''.join(z.removeprefix('0x') for z in s['memory']))==base;states+=1
  end=ls[entry+len(path['states'])];assert end['pc']==path['terminalPc'] and [eval(x,{'__builtins__':{}},env) for x in path['terminalStack']]==[int(x,16) for x in end['stack']] and bytes.fromhex(''.join(z.removeprefix('0x') for z in end['memory']))==base
assert all(counts.values());report=dict(status='passed-development-no-native-credit',runtimeSha256=m['runtimeSha256'],macros=counts,fullStates=states,preparedTransitions=14,nativeVerified=False,publicCredit=False);a.report.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
