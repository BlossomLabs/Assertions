#!/usr/bin/env python3
"""Audit every Collections body/public ABI entry and retained native dependency closure."""
import argparse,csv,hashlib,json,re,subprocess
from pathlib import Path
from collections import Counter
from functools import cache
import generate
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
@cache
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inspect(path,tools,checked):
    key=str(path.relative_to(ROOT))
    if key in checked:return checked[key]['declarations']
    p=json.loads(path.read_text());assert p['status']=='passed',key
    assert p.get('inputsUnchanged',True) and not p.get('sourceDrift',False),('Unstable snapshot',key)
    assert all(c['passed'] for c in p.get('checks',[])),('Failed checks',key)
    previous=p['executableSha256']
    if 'dafnyLauncher' in previous:previous={new:previous[old] for new,old in [('dafny','dafnyLauncher'),('Dafny.dll','dafnyAssembly'),('z3','solver'),('solc','solc')]}
    assert previous==tools,('Tool drift',key)
    for name,digest in p['sourceSha256'].items():assert sha(ROOT/name)==digest,('Source drift',key,name)
    for name,digest in p['evidenceSha256'].items():assert sha(path.parent/name)==digest,('Artifact drift',key,name)
    proof=next((c for c in p.get('checks',[]) if c.get('name')=='proof'),None)
    native=p.get('nativeResults') if proof is None else proof['nativeResults']
    declarations=p.get('declarationResults') if proof is None else proof['declarations']
    assert native and all(r['TestResult.Outcome']=='Passed' for r in native),('Native failure',key)
    names={r['TestResult.DisplayName'].split(' (')[0] for r in native}
    for d in declarations:
        if d['kind'] in {'lemma','method'}:assert d['status']=='passed' and d['name'] in names,('Unproved declaration',key,d)
    # Check native rows against the retained CSV, independently of summary status.
    csvname='proof.csv' if proof is not None else 'verification.csv'
    assert csvname in p['evidenceSha256'],('Missing native CSV',key)
    rows=list(csv.DictReader((path.parent/csvname).open()))
    assert rows==native,('Native CSV/manifest mismatch',key)
    assert any('auditor completed with 0 findings' in (path.parent/name).read_text() for name in p['evidenceSha256'] if name.endswith('audit.log')),('Missing zero escape audit',key)
    checked[key]={'sha256':sha(path),'nativeObligations':len(native),'sourceInputs':len(p['sourceSha256']),'artifactCount':len(p['evidenceSha256']),'assumptions':p.get('assumptions',[]),'scope':p['scope'],'declarations':{d['name']:d for d in declarations}}
    for c in p.get('checks',[]):
        if c.get('name')=='dependency-closure':
            for dep in c['dependencies']:
                dp=ROOT/dep['manifest'];assert sha(dp)==dep['sha256'],('Dependency manifest drift',key,dep['manifest'])
                if dep.get('retainedManifest'):assert sha(path.parent/dep['retainedManifest'])==dep['sha256']
                inspect(dp,tools,checked)
    return checked[key]['declarations']
def audit(solc,dafny,output):
    tools={k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',dafny.parent/'z3/bin/z3-4.12.1'),('solc',solc)]}
    requirements=json.loads((HERE/'requirements.json').read_text());checked={};covered=[];bindings=[]
    for item in requirements:
        path=ROOT/item['evidence'];declarations=inspect(path,tools,checked)
        ledgerpath=ROOT/item['ledger'];ledger=json.loads(ledgerpath.read_text())
        assert ledger['baseline']==item['evidence'] and ledger['baselineSha256']==sha(path),('Ledger drift',item['ledger'])
        for theorem in item['theorems']:assert theorem in declarations and declarations[theorem]['status']=='passed',('Unproved requirement',theorem)
        covered+=item['sourceFunctions'];bindings.append({**item,'evidenceSha256':sha(path),'ledgerSha256':sha(ledgerpath)})
    req,raw,actual=generate.compile_source(solc,ROOT)
    assert actual==json.loads((HERE/'structure.json').read_text()),'Full AST/ABI drift'
    assert set(actual['functions'])==set(covered) and all(v==1 for v in Counter(covered).values()),'Incomplete/duplicate body mapping'
    public={n for n,f in actual['functions'].items() if f['visibility'] in {'public','external'}}
    assert len(public)==29 and public=={v['name'] for v in actual['abi'].values()}
    # All public methods are mapped to complete public compositions, not only helper models.
    for item in requirements:
        if public.intersection(item['sourceFunctions']):
            ledger=json.loads((ROOT/item['ledger']).read_text())
            assert public.intersection(item['sourceFunctions'])<=set(ledger['completedPublicEntries']),('Public leaf coverage missing',item['ledger'])
    inventory=json.loads((ROOT/'formal/collections/inventory.json').read_text())
    assert inventory['publicAbi']==[f for f in json.loads(raw)['contracts']['contracts/Collections.sol']['Collections']['abi'] if f['type']=='function']
    assert len(inventory['functionDefinitions'])==51 and {v['name'] for v in inventory['functionDefinitions']}==set(actual['functions'])
    for v in inventory['functionDefinitions']:
        f=actual['functions'][v['name']];assert v['visibility']==f['visibility'] and v['mutability']==f['stateMutability'] and v['inputs']==len(f['parameters']['parameters'])
    result={'status':'passed-under-explicit-premises','functionDefinitions':51,'publicEntryCount':29,'publicAbi':actual['abi'],'bodyRequirements':bindings,'dependencyClosure':[{k:v for k,v in info.items() if k!='declarations'}|{'manifest':path} for path,info in sorted(checked.items())],
      'nativeObligationsInUniqueDependencies':sum(v['nativeObligations'] for v in checked.values()),
      'scope':'Complete conditional source coverage audit plus separate compiler-bound selector correspondence. The union of leaf premises applies; this audit does not prove solc code generation, ABI decoding, physical allocation/serialization, gas, deployment, complexity or performance. Sorting preorder and unique key coherence/grouping are required only for the stronger respective theorems.'}
    output.write_text(json.dumps(result,indent=2)+'\n')
    print('PASS: 51 unique body mappings, 29 complete public compositions,',len(checked),'current immutable native dependency manifests')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();audit(a.solc.resolve(),a.dafny.resolve(),a.output)
