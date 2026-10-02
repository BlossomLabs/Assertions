"""Independently reparse complete nested tuple/name constructor evidence."""
from pathlib import Path
import json,copy,importlib.util,hashlib
ROOT=Path(__file__).resolve().parents[3]
p=ROOT/'formal/bytecode/assertions-navigation/evidence/recursive-plain-native-v2/manifest.json'
spec=importlib.util.spec_from_file_location('runner',ROOT/'formal/bytecode/assertions-navigation/verify-modular-grammar-consolidated-v1.py');runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(runner)
d=json.loads(p.read_text());assert d['status']=='passed' and all(d[x] for x in ['coverageComplete','inputsUnchanged','toolsUnchanged'])
for f,h in d['sourceSha256'].items():assert runner.sha(ROOT/f)==h
for f,h in d['evidenceSha256'].items():assert runner.sha(p.parent/f)==h
seen=set();batches=0
for m in d['moduleProofs']:
 f=ROOT/m['file'];seen.add(m['file']);assert m['minimalIncludeClosure']==[str(q.relative_to(ROOT)) for q in runner.closure(f)]
 folder=p.parent/'modules'/m['proof']['name'].split('-')[1];proof=copy.deepcopy(m['proof']);assert proof['exitCode']==0 and proof['passed']
 if proof['nativeResults']:
  runner.common.check_proof(proof,folder/'proof.log',folder/'proof.csv',runner.inventory(f));assert proof['passed'] and proof['nativeResults']==m['proof']['nativeResults'] and proof['declarations']==m['proof']['declarations']
 else:assert proof['definitionOnly'] and all(x['kind'] not in ['lemma','method'] for x in proof['declarations'])
 assert m['audit']['exitCode']==0 and m['audit']['passed'] and 'auditor completed with 0 findings' in (folder/'audit.log').read_text();batches+=len(proof['nativeResults'])
assert seen==set(d['includeClosure'])
result={'status':'passed-independent-native-closure-review','publicCredit':False,'scope':'Constructive arbitrary nested name/tuple physical parser traces from independent encoded grammar, with explicit stack and finite calldata premises; fixed/dynamic suffixes and PC0 entry composition remain open','modules':len(seen),'nativeBatches':batches,'manifestSha256':runner.sha(p)}
out=ROOT/'formal/bytecode/assertions-navigation/coordinator-reviews-20261002/recursive-plain-v2-native-review.json';assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n');print(result['status'],len(seen),batches)
