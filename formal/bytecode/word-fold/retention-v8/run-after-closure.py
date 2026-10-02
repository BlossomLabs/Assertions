#!/usr/bin/env python3
"""Wait for actual native closure, then retain and independently check the fold package.

No restart, ledger or coverage write. Failure is preserved for review. The
result report is the concrete evidence needed for the coordinator's public step.
"""
import argparse,datetime,importlib.util,json,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
BATCH=ROOT/'formal/bytecode/word-fold/native-closure-development-v2/development/native-closure-v2/manifest.json'
REPAIR=ROOT/'formal/bytecode/word-fold/raw-closure-repair-v9/development/closure-native-v9/manifest.json'
EARLIER_REPAIR=ROOT/'formal/bytecode/word-fold/raw-closure-repair-v3/development/closure-native-v3/manifest.json'
CONFIRMATION=ROOT/'formal/bytecode/word-fold/native-window-confirmation-v1/development/native-v1/manifest.json'
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);a=parser.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
 spec=importlib.util.spec_from_file_location('fold_after_complete_closure',HERE/'verify.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 record=dict(status='waiting-for-actual-v9-and-whole-window-confirmation-terminal-no-restart',startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),originalBatch=str(BATCH.relative_to(ROOT)),repairManifest=str(REPAIR.relative_to(ROOT)),scope='Sequential authorized retained verification and independent checker after whole current native closure. No ledger/public credit is assigned by this driver.')
 def save(): (out/'results.json').write_text(json.dumps(record,indent=2)+'\n')
 def stop(reason):
  record.update(status='preserved-required-gate-failure',failure=reason,completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat());save();raise SystemExit(reason)
 save()
 while True:
  try:m=json.loads(REPAIR.read_text())
  except (FileNotFoundError,json.JSONDecodeError):time.sleep(10);continue
  if m.get('completedAt'):break
  time.sleep(10)
 while True:
  try:confirmed=json.loads(CONFIRMATION.read_text())
  except (FileNotFoundError,json.JSONDecodeError):time.sleep(10);continue
  if confirmed.get('completedAt'):break
  time.sleep(10)
 if confirmed['status']!='development-native-passed-not-retained':stop('Fresh whole raw-window confirmation failed; structural repair required')
 for path,count,allow_failed in [(BATCH,68,True),(EARLIER_REPAIR,11,True),(REPAIR,12,True),(CONFIRMATION,1,False)]:
  data=json.loads(path.read_text());jobs=[j for j in data['checks']if j['name'].startswith('proof-')];audits=[j for j in data['checks']if j['name'].startswith('audit-')]
  if not data.get('completedAt')or len(jobs)!=count or len(audits)!=count or any(j['exitCode']is None for j in jobs+audits):stop('A predecessor lacks actual complete native/audit termination')
  if not data['inputsUnchanged']or not data['toolsUnchanged']:stop('A predecessor recorded source/tool drift')
  if not allow_failed and not all(j['passed']for j in jobs+audits):stop('Fresh native module or audit failed')
  if any(v.sha(ROOT/k)!=digest or v.sha(path.parent/'source-snapshot'/k)!=digest for k,digest in data['sourceSha256'].items()):stop('Current or snapshot predecessor input drift')
  if any(v.sha(path.parent/k)!=digest for k,digest in data['evidenceSha256'].items()):stop('Predecessor evidence drift')
 sources_path=HERE/'native-sources.json';sources=json.loads(sources_path.read_text())
 for path in [BATCH,EARLIER_REPAIR,REPAIR,CONFIRMATION]:
  relative=str(path.relative_to(ROOT))
  if relative not in sources:sources.append(relative)
 sources_path.write_text(json.dumps(sources,indent=2)+'\n')
 dafny=Path('/tmp/assertions-dafny-4.11.0/dafny/dafny');solc=Path('/home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791');tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1','solc':solc}
 configuration=json.loads((HERE/'proof-spec.json').read_text());_,provenance=v.reuse.prepare([ROOT/p for p in sources],[ROOT/p for p in configuration['rootProofs']],{k:v.sha(p)for k,p in tools.items()})
 (out/'complete-native-provenance.json').write_text(json.dumps(provenance,indent=2)+'\n')
 if provenance['moduleCount']!=208 or provenance['acceptedModules']!=208 or provenance['missingModules']:
  record['missingModules']=provenance['missingModules'];save();stop('The derived current208-module graph is not completely native-closed')
 record.update(status='retained-gates-running-after-complete-current-native-closure',wholeCurrentNativeModules=208);save()
 retained=ROOT/'formal/bytecode/word-fold/retention-v8/evidence/physical-raw-current-inputs-v8'
 command=['python3','-B',str(HERE/'verify.py'),'--dafny',str(dafny),'--solc',str(solc),'--output',str(retained),'--workers','3']
 with (out/'retained.log').open('w')as log:
  process=subprocess.Popen(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT);code=process.wait()
 record['retainedCommand']=command;record['retainedExitCode']=code;save()
 if code!=0:stop('A required retained gate failed; preserve this owner and do not assign public credit')
 manifest=retained/'manifest.json';data=json.loads(manifest.read_text())
 if data['status']!='passed':stop('Retained result is not passed')
 checker=['python3','-B',str(ROOT/'scripts/check-fold-words-bytecode-v8-evidence.py'),'--manifest',str(manifest)]
 with (out/'independent-checker.log').open('w')as log:
  process=subprocess.Popen(checker,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT);code=process.wait()
 record['independentCheckerCommand']=checker;record['independentCheckerExitCode']=code
 if code!=0:stop('Independent current evidence checker failed; no public credit')
 record.update(status='retained-passed-and-independently-checked-ready-for-ledger',completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),manifest=str(manifest.relative_to(ROOT)),manifestSha256=v.sha(manifest),wholeNativeModules=208,nativeObligations=data['nativeObligations'],physicalReceipts=258,semanticBytecodeFaults=3,semanticSourceFaults=3,publicEntries=data['publicEntries'])
 record['evidenceSha256']={str(p.relative_to(out)):v.sha(p)for p in out.rglob('*')if p.is_file()and p.name!='results.json'};save();print(record['status'],record['manifest'],flush=True)
if __name__=='__main__':main()
