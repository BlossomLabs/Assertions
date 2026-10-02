#!/usr/bin/env python3
"""Retain complete conditional Collections source inventory/dependency/ABI evidence."""
import argparse,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('common',ROOT/'formal/constraints/verify.py')
common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
sha,run=common.sha,common.run
def inputs():
    requirements=json.loads((HERE/'requirements.json').read_text())
    extras=['contracts/Collections.sol','contracts/lib/AbiCodec.sol','formal/constraints/verify.py','formal/abi/toolchain.json','formal/collections/inventory.json']
    extras+=[r[k] for r in requirements for k in ['ledger','checker']]
    return sorted({f for f in HERE.iterdir() if f.is_file()}|{ROOT/f for f in extras})
def inventory():
    text=(HERE/'Boundary.generated.dfy').read_text()
    return [{'name':'CollectionsCompletionBoundary.'+m[2],'kind':m[1],'file':'formal/collections/completion/Boundary.generated.dfy'} for m in re.finditer(r'^  (lemma|method|function|predicate|type) (\w+)(?:\(| =)',text,re.M)]
def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    dafny,solc=a.dafny.resolve(),a.solc.resolve();solver=dafny.parent/'z3/bin/z3-4.12.1'
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
    for f in files:
        dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    source=snap/HERE.relative_to(ROOT)
    m={'status':'incomplete','scope':'Complete 51-body/29-entry conditional Collections source coverage and retained dependency closure, plus compiler-bound ABI selector correspondence. No unified compiled-bytecode equivalence claim.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(v) for k,v in [('dafny',dafny),('Dafny.dll',dafny.parent/'Dafny.dll'),('z3',solver),('solc',solc)]},'checks':[]}
    m['versions']={k:subprocess.check_output([str(v),'--version'],text=True).strip() for k,v in [('dafny',dafny),('z3',solver),('solc',solc)]}
    pin=json.loads((ROOT/'formal/abi/toolchain.json').read_text());assert m['versions']['dafny']==pin['dafnyVersion'] and '4.12.1' in m['versions']['z3'] and '0.8.36+commit.8a079791' in m['versions']['solc']
    m['assumptions']=[
      'The theorem family covers arbitrary finite faithfully decoded Collections inputs and reached finite history-sensitive external observations under the union of each public leaf theorem premises. Full compiler/source/context correspondence and faithfully decoded enums/structs/arrays remain trusted boundaries.',
      'Finite nonwrapping disjoint byte memory, representable lengths, cursor/packet/arithmetic footprints and sufficient reached execution/codec/copy/allocation/stack resources remain explicit. Logical bytes/pointer arrays do not prove physical compiler allocation or outer return serialization. Allocator guards and out-of-gas are outside successful-allocation theorems; retain each leaf restriction.',
      'Source/compiler checks and gated AST/template translations, load/store/copy/arithmetic and serialization projections remain premises. Selector routing is a generated abstract ABI case table, not a proof of the compiler dispatcher or decoder. Unknown selectors have no modeled public entry under the faithful compiler dispatch premise.',
      'Callback code/gas/staticcall outcomes are supplied truthful history- and context-indexed observations. They may be asymmetric or change across calls. Stronger value-sort sortedness/stability needs coherent total-preorder outcomes; stronger unique key-class results need coherent equality, and ordered/unordered agreement additionally needs grouping.',
      'All 51 bodies and 29 public ABI signatures bind to completed public/helper source proof packages. Complete public callers instantiate abstract helper dependencies. Seventy unique dependency manifests preserve the native declaration/source/tool/artifact closure and original assumptions; their real EVM/source-fault campaigns are inherited evidence, not a new completion campaign.',
      'Dafny/Boogie/Z3, pinned solc AST/ABI extraction and reviewed evidence tooling are trusted. Zero escape audit required. This is conditional source coverage only: exact compiled bytecode, unbounded resource safety, gas, complexity, deployment and performance are not proved.'
    ]
    def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1200):
        job=run(command,out/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0);m['checks'].append(job);save();return job
    save()
    gate=record('source-gate',[sys.executable,'-B',source/'generate.py','--root',snap,'--solc',solc,'--output',out/'generated'])
    gate['passed']=gate['passed'] and (out/'generated/Boundary.generated.dfy').read_bytes()==(source/'Boundary.generated.dfy').read_bytes();save()
    if not gate['passed']:raise SystemExit('Source gate/generated drift')
    coverage=record('coverage',[sys.executable,'-B',HERE/'audit.py','--dafny',dafny,'--solc',solc,'--output',out/'coverage.json'])
    if not coverage['passed']:raise SystemExit('Coverage audit failed')
    data=json.loads((out/'coverage.json').read_text());deps=[]
    for i,dep in enumerate(data['dependencyClosure']):
        path=ROOT/dep['manifest'];name=f'dependency-{i:02d}.json';shutil.copy2(path,out/name)
        assert sha(path)==dep['sha256'];deps.append({'manifest':dep['manifest'],'sha256':dep['sha256'],'retainedManifest':name,'nativeRows':dep['nativeObligations']})
    m['checks'].append({'name':'dependency-closure','passed':True,'dependencies':deps,'policy':'Current complete native/declaration/source/tool/artifact closure checked recursively by coverage audit; copied manifests preserve exact leaf premises. Includes 21 directly mapped source packages and all transitive dependencies.'});save()
    for i,r in enumerate(json.loads((HERE/'requirements.json').read_text())):
        record('leaf-checker-'+str(i),[sys.executable,'-B',ROOT/r['checker']],180)
    proof=record('proof',common.proof_command(dafny,source/'Boundary.generated.dfy',out/'proof.csv')+['--filter-symbol','CollectionsCompletion','--progress','Symbol'])
    common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory());save()
    audit=record('audit',[dafny,'audit',source/'Boundary.generated.dfy']);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text();save()
    record('format',[dafny,'format','--check',source/'Boundary.generated.dfy'])
    # Recheck the whole live dependency closure at completion, using a fresh process/hash cache.
    final=record('coverage-after',[sys.executable,'-B',HERE/'audit.py','--dafny',dafny,'--solc',solc,'--output',out/'coverage-after.json'])
    final['passed']=final['passed'] and (out/'coverage-after.json').read_bytes()==(out/'coverage.json').read_bytes()
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()}
    m['status']='passed' if m['inputsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed'
    m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'}
    save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
