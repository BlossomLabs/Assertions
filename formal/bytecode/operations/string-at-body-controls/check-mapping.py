from pathlib import Path
import argparse,json,hashlib
owner=Path(__file__).resolve().parent;repo=owner.parents[3];MOD=1<<256
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--report',type=Path,required=True);a=p.parse_args()
m=json.loads((owner/'mapping.json').read_text());code=bytes.fromhex(json.loads((repo/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert m['runtimeSha256']==hashlib.sha256(code).hexdigest();paths={x['name']:x for x in m['paths']};counts={n:0 for n in paths};states=0

def store(mem,at,value):
 mem=bytearray(mem);mem.extend(b'\0'*max(0,32*((at+63)//32)-len(mem)));mem[at:at+32]=value.to_bytes(32,'big');return bytes(mem)
base=store(b'',64,128);free=store(base,64,192);header=store(free,128,1);errhead=store(base,128,0x41972036<<224)
for row in json.loads((a.directory/'results.json').read_text()):
 t=json.loads((a.directory/row['trace']).read_text());ls=t['trace']['structLogs'];entry=next((i for i,s in enumerate(ls) if s['pc']==7302),None)
 if entry is None:continue
 st=[int(z,16) for z in ls[entry]['stack']];assert st[0]==0xa1bc2139 and st[1]==1362 and st[5:7]==[96,0];offset,length,word,position=st[2],st[3],st[4],st[7];data=bytes.fromhex(t['data'][2:]);assert offset+length<=len(data)<1<<64 and position<length;cell=data[offset+position];name='Ascii' if cell<128 else 'NonAscii';path=paths[name]
 load=lambda at:int.from_bytes(data[at:at+32].ljust(32,b'\0'),'big') if at<len(data) else 0
 env=dict(offset=offset,length=length,word=word,position=position,cell=cell,MOD=MOD,int=int,load=load)
 copied=header+bytes([cell])+bytes(31);finished=store(copied,161,0);errlast=store(errhead,132,position)
 memories={'K.Initial()':base,'B.FreeSet()':free,'B.Header()':header,'B.Copied(data,offset,length,position)':copied,'B.Finished(data,offset,length,position)':finished,'U.FirstError(K.Initial())':errhead,'U.ErrorMemory(K.Initial(),position)':errlast}
 for j,n in enumerate(path['states']):
  s=ls[entry+j];expected=[eval(x,{'__builtins__':{}},env) for x in n['pythonStack']];actual=[int(z,16) for z in s['stack']];memory=bytes.fromhex(''.join(z.removeprefix('0x') for z in s['memory']));assert s['pc']==n['pc'] and code[n['pc']]==n['opcode'] and expected==actual and memory==memories[n['memory']],(row['ordinal'],name,j,n['pc']);states+=1
 if name=='Ascii':
  after=ls[entry+len(path['states'])];assert after['pc']==1362 and [int(z,16) for z in after['stack']]==[0xa1bc2139,128] and bytes.fromhex(''.join(z.removeprefix('0x') for z in after['memory']))==finished
 else:
  assert entry+len(path['states'])==len(ls) and ls[-1]['op']=='REVERT' and t['trace']['failed'] and bytes.fromhex(t['trace']['returnValue'].removeprefix('0x'))==bytes.fromhex('41972036')+position.to_bytes(32,'big')
 counts[name]+=1
assert all(counts.values());report=dict(status='passed-development-no-native-credit',runtimeSha256=m['runtimeSha256'],macroInvocations=sum(counts.values()),classes=counts,fullStates=states,preparedTransitions=sum(len(x['states']) for x in paths.values()),nativeVerified=False,publicCredit=False);a.report.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
