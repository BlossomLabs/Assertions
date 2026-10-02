from pathlib import Path
import json,hashlib,re,runpy
root=Path(__file__).resolve().parents[3]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
pos=root/'formal/bytecode/assertions-navigation/evidence/parser-byte-witness-native-v1'
neg=root/'formal/bytecode/assertions-navigation/evidence/parser-byte-witness-negative-v1'
a=json.loads((pos/'manifest.json').read_text());b=json.loads((neg/'manifest.json').read_text())
assert a['status']=='passed' and b['status']=='failed'
for d,folder in [(a,pos),(b,neg)]:
 assert d['inputsUnchanged'] and d['toolsUnchanged']
 for f,h in d['sourceSha256'].items():assert sha(root/f)==h,f
 for f,h in d['evidenceSha256'].items():assert sha(folder/f)==h,f
 assert all(m['audit']['passed'] for m in d['moduleProofs'])
failed=[m for m in b['moduleProofs'] if not m['proof']['passed']];assert len(failed)==1
assert all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in failed[0]['proof']['nativeResults'])
log=(neg/'modules/002/proof.log').read_text();assert 'postcondition could not be proved' in log and not re.search('timed out|resolution error|parse error',log,re.I)
p=root/'formal/bytecode/assertions-navigation/development/parser-byte-fault-v1'
s=(p/'Witness.dfy').read_text();t=(p/'Witness.mutant.dfy').read_text()
assert s.replace('AssertionsNavigationParserByteWitness {','AssertionsNavigationParserByteWitnessMutant {').replace('code[12536] == 26','code[12536] == 28')==t
model=runpy.run_path(str(root/'formal/bytecode/assertions-navigation/check-recursive-parser-consolidated-v2.py')) if False else runpy.run_path(str(root/'formal/bytecode/assertions-resolution/constrained-raw/public/check-false-replay-consolidated-v1.py'))
stack,memory,step=model['stack'],model['memory'],model['step']
code=bytes.fromhex(json.loads((root/'artifacts/contracts/Assertions.sol/Assertions.json').read_text())['deployedBytecode'][2:]);assert code[12536]==26
mutant=bytearray(code);mutant[12536]=28
folder=root/'formal/bytecode/assertions-navigation/development/recursive-parser-physical-fault-v1'
checks=[]
for p in sorted(folder.glob('case-*.json')):
 d=json.loads(p.read_text());rows=[r for r in d['trace']['structLogs'] if r['depth']==1]
 i=next(i for i,r in enumerate(rows) if r['pc']==12536);row=rows[i];n=rows[i+1]
 pc,st,mem,end=step(mutant,row,bytes.fromhex(d['data'][2:]));assert end is None and (pc,st,mem)==(n['pc'],stack(n),memory(n))
 before=stack(row);index,word=before[-1],before[-2];expected=0 if index>=32 else (word>>(8*(31-index)))&255
 assert index==0 and st[-1]!=expected and before[-2]>255
 assert d['trace']['failed'] or d['actual']!=d['expected']
 checks.append({'fixture':p.name,'actualFullStepMatches':True,'sameByteSemanticResultWrong':True})
assert len(checks)==4
out=root/'formal/bytecode/assertions-navigation/coordinator-reviews-20261002/parser-byte-binding-v1.json';assert not out.exists()
result={'status':'passed-independent-matching-fault-review','pc':12536,'nativePositiveManifestSha256':sha(pos/'manifest.json'),'nativeNegativeManifestSha256':sha(neg/'manifest.json'),'physicalKills':4,'checks':checks,'publicCredit':False,'scope':'Actual name-scanner BYTE versus SHR, unchanged ByteAt semantic postcondition and exact physical instruction state; constructor public composition remains separate'}
out.write_text(json.dumps(result,indent=2)+'\n');print('PASS matching native/physical BYTE fault')
