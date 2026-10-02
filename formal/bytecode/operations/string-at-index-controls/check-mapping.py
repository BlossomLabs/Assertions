from pathlib import Path
import argparse,json,hashlib
owner=Path(__file__).resolve().parent;repo=owner.parents[3];MOD=1<<256;H=MOD//2
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--report',type=Path,required=True);a=p.parse_args()
m=json.loads((owner/'mapping.json').read_text());code=bytes.fromhex(json.loads((repo/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);assert m['runtimeSha256']==hashlib.sha256(code).hexdigest();paths={x['name']:x for x in m['paths']};counts={n:0 for n in paths};states=0
signed=lambda x:x if x<H else x-MOD

def store(mem,at,value):
 mem=bytearray(mem);mem.extend(b'\0'*max(0,((at+63)//32)*32-len(mem)));mem[at:at+32]=value.to_bytes(32,'big');return bytes(mem)
base=store(b'',64,128)
for row in json.loads((a.directory/'results.json').read_text()):
 t=json.loads((a.directory/row['trace']).read_text());ls=t['trace']['structLogs'];entry=next((i for i,s in enumerate(ls) if s['pc']==11497),None)
 if entry is None:continue
 observed=[int(z,16) for z in ls[entry]['stack']];prefix=observed[:-3];ret,word,length=observed[-3:];assert len(prefix)<=980 and length<1<<64
 index=signed(word);name='InvalidHigh' if index>=length else 'InvalidLow' if index< -length else 'Negative' if index<0 else 'Positive';path=paths[name];env={'word':word,'length':length,'ret':ret,'MOD':MOD,'H':H,'signed':signed,'int':int};sel=store(base,128,0xdf75cbae<<224);iw=store(sel,132,word);fin=store(iw,164,length);mem={'K.Initial()':base,'Err.SelectorStored()':sel,'Err.IndexStored(word)':iw,'Err.Finished(word,length)':fin}
 for j,n in enumerate(path['states']):
  s=ls[entry+j];expected=prefix+[eval(x,{'__builtins__':{}},env) for x in n['pythonStack']];actual=[int(z,16) for z in s['stack']];memory=bytes.fromhex(''.join(z.removeprefix('0x') for z in s['memory']));assert s['pc']==n['pc'] and code[n['pc']]==n['opcode'] and expected==actual and memory==mem[n['memory']],(row['ordinal'],name,j,n['pc']);states+=1
 last=ls[entry+len(path['states'])-1]
 if name.startswith('Invalid'):
  assert last['op']=='REVERT' and entry+len(path['states'])==len(ls);packet=bytes.fromhex(t['trace']['returnValue'].removeprefix('0x'));assert t['trace']['failed'] and packet==bytes.fromhex('df75cbae')+word.to_bytes(32,'big')+length.to_bytes(32,'big')
 else:
  after=ls[entry+len(path['states'])];assert after['pc']==ret and [int(z,16) for z in after['stack']]==prefix+[index if index>=0 else length+index] and bytes.fromhex(''.join(z.removeprefix('0x') for z in after['memory']))==base
 counts[name]+=1
assert all(counts.values());report=dict(status='passed-development-no-native-credit',runtimeSha256=m['runtimeSha256'],macroInvocations=sum(counts.values()),classes=counts,fullStates=states,preparedTransitions=sum(len(x['states']) for x in paths.values()),admission='arbitrary preserved prefix, fresh memory, length below 2^64 and exact signed partition',nativeVerified=False,publicCredit=False);a.report.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
