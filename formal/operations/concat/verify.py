#!/usr/bin/env python3
"""Retain conditional AST-derived source evidence for 1 Operations concatenation entry."""
import argparse,datetime,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('common',ROOT/'formal/constraints/verify.py');common=importlib.util.module_from_spec(spec);spec.loader.exec_module(common)
spec=importlib.util.spec_from_file_location('generator',HERE/'generate.py');generator=importlib.util.module_from_spec(spec);spec.loader.exec_module(generator)
sha=common.sha
def closure(path):
    path=path.resolve();result={path}
    for name in re.findall(r'^include "([^\"]+)"',path.read_text(),re.M):result.update(closure(path.parent/name))
    return result
def inputs():return sorted({p for p in HERE.iterdir() if p.is_file()}|closure(HERE/'Connection.dfy')|{ROOT/p for p in generator.SOURCES}|{ROOT/'formal/constraints/verify.py',ROOT/'formal/abi/toolchain.json'})
def inventory(source):
    result=[]
    for path in sorted(closure(source/'Connection.dfy')):
        module=re.search(r'^module (\w+)',path.read_text(),re.M)[1]
        for d in re.finditer(r'^  (?:ghost )?(lemma|method|function|predicate|type)(?: \{:[^}]+\})* (\w+)(?:\(| =)',path.read_text(),re.M):result.append({'name':module+'.'+d[2],'kind':d[1],'file':path.name})
    return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    dafny=a.dafny.resolve();solc=a.solc.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1';tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc};versions={k:subprocess.check_output([str(t),'--version'],text=True).strip() for k,t in tools.items() if k!='Dafny.dll'}
    if versions['dafny']!=json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'] or '4.12.1' not in versions['z3'] or '0.8.36+commit.8a079791' not in versions['solc']:raise ValueError('Unpinned tools')
    paths=inputs();hashes={str(p.relative_to(ROOT)):sha(p) for p in paths};snap=out/'source-snapshot'
    for f in paths:
        dest=snap/f.relative_to(ROOT);dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,dest)
    source=snap/HERE.relative_to(ROOT);m={'schemaVersion':1,'status':'incomplete','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'1 complete Operations concatenation public body at the decoded ABI boundary, conditional restricted AST/source semantics; exact-bytecode verification separate.','entries':json.loads((source/'entries.json').read_text()),'sourceSha256':hashes,'executableSha256':{k:sha(t) for k,t in tools.items()},'versions':versions,'nativeDomain':'All finite arrays and constituent/delimiter byte lengths representable in uint256, checked sizing including multiplication/addition overflow, ordered exact joins, actual helper-address wrapping under admitted memory frames, and disjoint header/outside preservation; no part-count or loop/fuel bound.','assumptions':['Compiler AST and compiler selectors are trustworthy; complete AST structure gates and restricted AST expression translation are reviewed source correspondence premises, not a certified translation.','Valid decoded bytes arrays/delimiter and source/default initialization, checked uint256 multiply/add/increment, successful sized output allocation when arithmetic fits, an aligned nonwrapping allocation/free-pointer frame, faithful calldata/memory byte projection and CALDATACOPY primitive, and exact outer ABI/Panic serialization. Actual _copy length/destination operands are AST-derived and its memory transformation/frame are proved; no internal copy postcondition is assumed. Allocation/resource failures lie outside the successful-allocation premise. Restricted AST lowering is reviewed conditional correspondence, not a certified Solidity translation.','All included mathematical helper proofs are freshly checked with immutable dependency inputs. Adequate resources and trusted Dafny/Boogie/Z3. No external observations, compiler-correctness, exact-bytecode, gas, deployment or performance claim.'],'concreteTool':{'version':subprocess.check_output(['forge','--version'],text=True).strip(),'sha256':sha(Path(shutil.which('forge')))},'checks':[]}
    def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
    def record(name,command,timeout=1800):
        job=common.run(command,out/(name+'.log'),timeout);job.update(name=name,passed=job['exitCode']==0);m['checks'].append(job);save();return job
    save();gate=record('source-gate',[sys.executable,'-B',source/'generate.py','--root',snap,'--solc',solc,'--output',out/'generated'])
    gate['passed']=gate['passed'] and (out/'generated/Control.generated.dfy').read_bytes()==(source/'Control.generated.dfy').read_bytes()
    if not gate['passed']:save();raise SystemExit('Source gate/generated drift')
    proof=record('proof',common.proof_command(dafny,source/'Connection.dfy',out/'proof.csv')+['--progress','Symbol']);common.check_proof(proof,out/'proof.log',out/'proof.csv',inventory(source));save()
    audit=record('audit',[dafny,'audit',source/'Connection.dfy']);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/'audit.log').read_text();save()
    record('dafny-format',[dafny,'format','--check',source/'Model.dfy',source/'Control.generated.dfy',source/'Connection.dfy'])
    (snap/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/operations/concat"\nsolc='+json.dumps(str(solc))+'\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\nremappings=["@openzeppelin/contracts/=node_modules/@openzeppelin/contracts/"]\n[lint]\nlint_on_build=false\n')
    record('solidity-format',['forge','fmt','--check',source/'ConcatOracle.t.sol'])
    concrete=record('concrete',['forge','test','--root',snap,'--match-contract','^OperationsConcatOracleTest$','-vv'],240);expected=re.findall(r'function (test\w+)\(', (source/'ConcatOracle.t.sol').read_text());actual=re.findall(r'^\[PASS\] (test\w+)\(', (out/'concrete.log').read_text(),re.M);concrete.update(expectedTests=expected,actualTests=actual,passed=concrete['passed'] and sorted(actual)==sorted(expected) and len(expected)==2);save()
    record('source-faults',[sys.executable,'-B',source/'source-fault-audit.py','--snapshot',snap,'--output',out/'source-faults','--dafny',dafny,'--solc',solc],1800)
    m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['status']='passed' if m['inputsUnchanged'] and all(c['passed'] for c in m['checks']) else 'failed';m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();shutil.rmtree(snap/'out',ignore_errors=True);shutil.rmtree(snap/'cache',ignore_errors=True);m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
