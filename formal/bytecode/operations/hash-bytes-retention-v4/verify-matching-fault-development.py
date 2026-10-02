#!/usr/bin/env python3
"""Retain a matching semantic postcondition preflight; never public credit."""
import argparse,csv,datetime,importlib.util,json,re,shutil,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(name,path):
 s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
v=load('hash_retainer',HERE/'verify.py');common=v.common;sha=v.sha
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 tools={'dafny':a.dafny.resolve(),'Dafny.dll':a.dafny.resolve().parent/'Dafny.dll','z3':a.dafny.resolve().parent/'z3/bin/z3-4.12.1'}
 files=v.inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
 for f in files:
  d=snap/f.relative_to(ROOT);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,d)
 m={'status':'development-incomplete-no-public-credit','scope':'Only baseline satisfiable pre-serialization semantic witness and corresponding actual one-byte SHA3-to-ADD mutation. Full included native graph, complete public retention and independent checking remain required. Faithful hash observation premise explicit. No gas/deployment/performance/crypto claim.','startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'sourceSha256':hashes,'executableSha256':{k:sha(f) for k,f in tools.items()},'checks':[],'wholeNativeGraphModules':66,'selectedSemanticSymbol':'OperationsHashSuccessEntry.SemanticWitness','matchingPhysicalWitnessOrdinal':4}
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(name,cmd,timeout=240):
  j=common.run(cmd,out/(name+'.log'),timeout);j.update(name=name,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 save();source=snap/v.OWNER.relative_to(ROOT);baseline=source/'hash-bytes-success-repair-v4/Entry.generated.dfy'
 j=record('baseline-native',common.proof_command(tools['dafny'],baseline,out/'baseline.csv')+['--filter-symbol',m['selectedSemanticSymbol'],'--filter-position',str(baseline),'--progress','Symbol'])
 rows=list(csv.DictReader((out/'baseline.csv').open())) if (out/'baseline.csv').exists() else [];j['nativeResults']=rows;j['passed']=j['passed'] and bool(rows) and all(r['TestResult.Outcome']=='Passed' for r in rows);save()
 if not j['passed']:m['status']='development-baseline-failed-preserved';save();raise SystemExit(1)
 candidates=out/'candidates';gen=record('candidate-generation',[sys.executable,'-B',source/'hash-bytes-retention-v4/make-candidates.py','--output',candidates],180)
 mutant=out/'mutant-source-snapshot';shutil.copytree(snap,mutant);owner=mutant/v.SUCCESS.relative_to(ROOT);candidate=candidates/'sha3-to-add.bin'
 inventory=json.loads((candidates/'inventory.json').read_text());assert len(inventory)==1;candidate=candidates/(inventory[0]['name']+'.bin')
 translation=record('mutation-generation',[sys.executable,'-B',owner/'generate.py','--runtime',candidate,'--output',owner],180)
 fmt=record('mutation-format',[sys.executable,'-B',owner/'format-generated.py','--output',owner,'--include-root',owner],180)
 if not all(x['passed'] for x in [gen,translation,fmt]):m['status']='development-generation-failed-preserved';save();raise SystemExit(1)
 file=owner/'Entry.generated.dfy';lines=file.read_text().splitlines();begin=next(i for i,l in enumerate(lines) if 'lemma SemanticWitness(' in l);anchor=next(i for i in range(begin,len(lines)) if 'ensures state.stack[|state.stack|-2]==result' in lines[i])
 native=record('mutation-native',common.proof_command(tools['dafny'],file,out/'mutation.csv')+['--filter-symbol',m['selectedSemanticSymbol'],'--filter-position',str(file)+':'+str(anchor+1),'--progress','Symbol'])
 rows=list(csv.DictReader((out/'mutation.csv').open())) if (out/'mutation.csv').exists() else [];log=(out/'mutation-native.log').read_text();native['nativeResults']=rows
 native['passed']=native['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in rows) and 'a postcondition could not be proved' in log and not re.search(r'timed out|timeout|resolution/type errors|precondition could not be proved',log,re.I);save()
 m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in v.inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(f) for k,f in tools.items()};m['status']='development-matching-native-fault-passed-no-public-credit' if native['passed'] and m['inputsUnchanged'] and m['toolsUnchanged'] else 'development-failed-preserved'
 m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save();print(m['status']);raise SystemExit(0 if m['status']=='development-matching-native-fault-passed-no-public-credit' else 1)
if __name__=='__main__':main()
