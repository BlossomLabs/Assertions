#!/usr/bin/env python3
"""Retain the complete exact raw StringAt graph; no partial closure credit."""
import argparse,csv,datetime,hashlib,importlib.util,json,re,shutil,subprocess,sys
from pathlib import Path
if not __debug__:raise RuntimeError('Run without Python -O')
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];OWNER=HERE.parent
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
getters=load('stringat_getters',ROOT/'formal/bytecode/getters/verify.py');common=getters.common;identity=load('stringat_identity',OWNER/'identity.py');sha=common.sha
PROOFS=[]
def collect(f):
 f=f.resolve()
 if f in PROOFS:return
 for n in re.findall(r'^include "([^"]+)"',f.read_text(),re.M):collect(f.parent/n)
 PROOFS.append(f)
collect(OWNER/'string-at-full/Full.dfy');collect(OWNER/'string-at-mutation/Witness.generated.dfy')
def inventory(f):
 rows=getters.inventory(f);symbol=re.search(r'^module (\w+)',f.read_text(),re.M)[1]
 return rows+[dict(name=symbol+'.'+m[1],kind='const',file=str(f.relative_to(ROOT))) for m in re.finditer(r'^  const (\w+)\s*:',f.read_text(),re.M)]
def inputs():
 folders={HERE,OWNER/'string-at-preparation',*[f.parent for f in PROOFS]};files={f for d in folders for f in d.iterdir() if f.is_file()}
 files|={OWNER/'identity.py',OWNER/'inventory.py',OWNER/'inventory.json',OWNER/'check-string-at-evidence.py',ROOT/'formal/bytecode/word-apply/map-prefix/format-generated.py',ROOT/'formal/constraints/verify.py',ROOT/'formal/bytecode/getters/verify.py',ROOT/'formal/bytecode/dispatch/identity.py',ROOT/'formal/abi/toolchain.json',ROOT/'hardhat.config.ts',ROOT/'package.json',ROOT/'pnpm-lock.yaml'}
 artifact=ROOT/'artifacts/contracts/Operations.sol/Operations.json';a=json.loads(artifact.read_text());build=ROOT/'artifacts/build-info'/(a['buildInfoId']+'.json');files|={artifact,build,ROOT/'artifacts/build-info'/(a['buildInfoId']+'.output.json')}
 for key in json.loads(build.read_text())['input']['sources']:
  files.add(identity.source_path(key))
  if key.startswith('npm/'):files.add(ROOT/'node_modules'/re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)[1]/'package.json')
 return sorted(files)
CONFIGS=[dict(name='mcopy-to-calldata',folder='string-at-mutation',pc=18907,old=94,new=55,symbol='OperationsStringAtSemanticWitness.SemanticWitness',ordinal=5)]
GENERATORS=[('string-at-preparation','generate-source-gate.py'),('string-at-raw','generate.py'),('string-at-entry-controls','generate.py'),('string-at-index-controls','generate.py'),('string-at-body-controls','generate.py'),('string-at-mutation','generate.py'),('utf8-shared','generate-controls.py'),('utf8-shared','generate-engine.py'),('tostring-return','generate.py'),('casefold-machine','generate-binary.py'),('dynamic-return-shared','generate-constant-mask.py'),('account-environment-repair-v2','generate-conversion.py')]
def regenerate(source,out,record):
 checks=[];formatter=source.parent/'word-apply/map-prefix/format-generated.py'
 for folder,script in GENERATORS:
  owner=source/folder;dest=out/('generated-'+folder+'-'+script);command=[sys.executable,'-B',owner/script,'--output',dest]
  if script=='generate-engine.py':command+=['--mapping',owner/'controls.mapping.json']
  j=record('generation-'+folder+'-'+script,command,240);checks.append(j)
  if not j['passed']:continue
  fmt=record('generation-format-'+folder+'-'+script,[sys.executable,'-B',formatter,'--output',dest,'--include-root',owner],240);checks.append(fmt)
  generated=sorted(f for f in dest.iterdir() if f.is_file());j['generatedFiles']=[f.name for f in generated];j['passed']=j['passed'] and fmt['passed'] and bool(generated) and all((owner/f.name).is_file() and (owner/f.name).read_bytes()==f.read_bytes() for f in generated)
 for rel,label,file in [('word-apply/word-conversion','word-conversion','Conversion.generated.dfy'),('word-fold/byte-representation-repair-v8','word-first-byte-shift','Shift.generated.dfy')]:
  owner=source.parent/rel;dest=out/label;j=record('generation-'+label,[sys.executable,'-B',owner/'generate.py','--output',dest],240);j['passed']=j['passed'] and (owner/file).read_bytes()==(dest/file).read_bytes();checks.append(j)
 return all(j['passed'] for j in checks)
def main():
 p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);assert len(PROOFS)==109
 dafny=a.dafny.resolve();z3=dafny.parent/'z3/bin/z3-4.12.1';solc=a.solc.resolve();tools={'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':z3,'solc':solc};versions={k:subprocess.check_output([str(tools[k]),'--version'],text=True).strip() for k in ['dafny','z3','solc']};assert versions['dafny']==json.loads((ROOT/'formal/abi/toolchain.json').read_text())['dafnyVersion'] and '4.12.1' in versions['z3'] and '0.8.36+commit.8a079791' in versions['solc']
 files=inputs();hashes={str(f.relative_to(ROOT)):sha(f) for f in files};snap=out/'source-snapshot'
 for f in files:
  d=snap/f.relative_to(ROOT);d.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(f,d)
 source=snap/OWNER.relative_to(ROOT);m=dict(schemaVersion=1,status='incomplete',startedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),publicEntries=['Operations.stringAt(bytes,int256)'],scope='Complete109-owner raw instruction correspondence: PC0 ordered raw decoder; whole original UTF8 validation and exact first-error offset; four exhaustive signed-index classes; original selected-cell read and ASCII guard; one-byte calldata-copy allocation and canonical bytes RETURN; matching same-PC serializer memory-copy fault. No gas, deployment or performance theorem.',sourceSha256=hashes,versions=versions,executableSha256={k:sha(f) for k,f in tools.items()},nativeWholeModuleWatchdogSeconds=7200,nativeObligationTimeLimitSeconds=30,proofFiles=[str(f.relative_to(ROOT)) for f in PROOFS],checks=[],assumptions=['Exact current compiler/runtime/selector binding and reviewed complete reached instruction-boundary extraction; no compiler-correctness shortcut replaces executed instructions.','Original finite calldata below 2^64 with actual zero-padded word reads, truthful call value, fresh zero-byte memory and sufficient reached stack/memory/instruction resources; no gas cost/availability, deployment or performance claim.','Reviewed normative EVM arithmetic modulo 2^256, actual signed comparison, word shifts, rounded byte memory, snapshot source copy and reached instruction trace; no whole foreign-interpreter or library-correctness premise.','Dafny/Boogie/Z3 and reviewed evidence tooling are trusted; source-level lemmas and finite fixtures do not replace complete native opcode correspondence.'])
 def save():(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
 def record(n,c,t=1800):
  j=common.run(c,out/(n+'.log'),t);j.update(name=n,passed=j['exitCode']==0);m['checks'].append(j);save();return j
 proofjobs=[]
 def finish(status):
  m['status']=status;m['nativeResults']=[x for j in proofjobs for x in j.get('nativeResults',[])];m['declarationResults']=[x for j in proofjobs for x in j.get('declarations',[])];m['inputsUnchanged']=hashes=={str(f.relative_to(ROOT)):sha(f) for f in inputs()};m['toolsUnchanged']=m['executableSha256']=={k:sha(f) for k,f in tools.items()};m['status']='failed-input-tool-drift' if status=='passed' and not (m['inputsUnchanged'] and m['toolsUnchanged']) else status;m['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat();m['evidenceSha256']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='manifest.json'};save()
 save();fmt=record('format-before',[dafny,'format','--check',*[snap/f.relative_to(ROOT) for f in PROOFS]],240);ident=record('runtime-identity',[sys.executable,'-B',source/'identity.py','--solc',solc,'--output',out/'identity'],240);gen=regenerate(source,out,record);save()
 if not fmt['passed'] or not ident['passed'] or not gen:finish('failed-format-identity-regeneration-gate');raise SystemExit(1)
 for f in PROOFS:
  symbol=re.search(r'^module (\w+)',f.read_text(),re.M)[1];sf=snap/f.relative_to(ROOT);csvpath=out/(symbol+'.csv');j=record('proof-'+symbol,common.proof_command(dafny,sf,csvpath)+['--filter-symbol',symbol,'--filter-position',str(sf),'--progress','Symbol'],7200);common.check_proof(j,out/('proof-'+symbol+'.log'),csvpath,inventory(f));proofjobs.append(j);save()
  if not j['passed']:m['failedRequiredGate']=j['name'];finish('failed-required-native-gate');raise SystemExit(1)
  audit=record('audit-'+symbol,[dafny,'audit',sf],600);audit['passed']=audit['passed'] and 'auditor completed with 0 findings' in (out/('audit-'+symbol+'.log')).read_text();save()
  if not audit['passed']:m['failedRequiredGate']=audit['name'];finish('failed-required-native-gate');raise SystemExit(1)
 script=source/'string-at-preparation';fixtures=script/'utf8-profile-fixtures.json';concrete=record('concrete',[shutil.which('node'),script/'evm-traces.mjs',out/'evm-traces','-',fixtures],240);rows=json.loads((out/'evm-traces/results.json').read_text());concrete['passed']=concrete['passed'] and len(rows)==405 and {r['ordinal'] for r in rows}==set(range(405)) and all(r['passed'] for r in rows);m['physicalPartition']={reason:sum(r['reason']==reason for r in rows) for reason in sorted({r['reason'] for r in rows})};save()
 record('concrete-string-at-raw',[sys.executable,'-B',source/'string-at-raw/check-mapping.py',out/'evm-traces'],240)
 for folder in ['string-at-entry-controls','string-at-index-controls','string-at-body-controls']:
  record('concrete-'+folder,[sys.executable,'-B',source/folder/'check-mapping.py',out/'evm-traces','--report',out/(folder+'-mapping.json')],240)
 record('concrete-utf8-mapping',[sys.executable,'-B',source/'utf8-shared/check-controls.py',source/'utf8-shared/controls.mapping.json',out/'evm-traces','--report',out/'utf8-mapping.json'],240)
 record('concrete-independent',[sys.executable,'-B',script/'check-physical.py',out/'evm-traces','--expected-count','405'],240);ct=json.loads((out/'evm-traces/toolchain.json').read_text());m['concreteToolchain']=ct;save()
 code=bytes.fromhex(json.loads((snap/'artifacts/contracts/Operations.sol/Operations.json').read_text())['deployedBytecode'][2:]);mutated=bytearray(code);assert mutated[18907]==94;mutated[18907]=55;(out/'candidates').mkdir();(out/'candidates/inventory.json').write_text(json.dumps(CONFIGS,indent=2)+'\n');candidate=out/'candidates/mcopy-to-calldata.bin';candidate.write_bytes(mutated)
 folder=out/'mutations/mcopy-to-calldata';folder.mkdir(parents=True);mutant=folder/'source-snapshot';shutil.copytree(snap,mutant);mw=mutant/OWNER.relative_to(ROOT)/'string-at-mutation';translation=record('mcopy-to-calldata-translation',[sys.executable,'-B',mw/'generate.py','--runtime',candidate,'--output',mw],240);fmt=record('mcopy-to-calldata-format',[dafny,'format','--check',mw/'Witness.generated.dfy'],240)
 symbol='OperationsStringAtSemanticWitness.SemanticWitness';file=mw/'Witness.generated.dfy';native=record('mcopy-to-calldata-native',common.proof_command(dafny,file,folder/'proof.csv')+['--filter-symbol',symbol,'--filter-position',str(file),'--progress','Symbol'],7200);log=(out/'mcopy-to-calldata-native.log').read_text();csvrows=list(csv.DictReader((folder/'proof.csv').open())) if (folder/'proof.csv').exists() else [];native['passed']=native['exitCode'] not in [0,None] and bool(csvrows) and any(r['TestResult.Outcome']=='Failed' for r in csvrows) and all(r['TestResult.Outcome'] in ['Passed','Failed'] for r in csvrows) and 'a postcondition could not be proved' in log and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',log,re.I)
 physical=record('mcopy-to-calldata-concrete',[ct['nodeExecutable'],script/'evm-traces.mjs',folder/'evm-traces',candidate,fixtures],240);faultrows=json.loads((folder/'evm-traces/results.json').read_text());physical['passed']=physical['passed'] and len(faultrows)==405 and not faultrows[5]['passed'] and sum(not r['passed'] for r in faultrows)==27;save();independent=record('mcopy-to-calldata-independent',[sys.executable,'-B',script/'check-physical.py',folder/'evm-traces','--runtime',candidate,'--expected-count','405','--expect-semantic-fault'],240);frontier=record('mcopy-to-calldata-frontier',[sys.executable,'-B',script/'check-frontier.py',out/'evm-traces',folder/'evm-traces','--runtime',candidate,'--report',folder/'frontier.json'],240)
 base=next(d for j in proofjobs for d in j['declarations'] if d['name']==symbol);fault=dict(**CONFIGS[0],baselineDeclaration=symbol,baselineObligations=base['batches'],witnessOrdinal=5,candidateSha256=sha(candidate),nativeResults=csvrows,physicalReceipts=405,physicalIntendedOutcomeContradictions=27,passed=all(j['passed'] for j in [translation,fmt,native,physical,independent,frontier]));(folder.parent/'results.json').write_text(json.dumps([fault],indent=2)+'\n');m['semanticFaults']=[fault];m['concreteToolsUnchanged']=sha(Path(ct['nodeExecutable']))==ct['nodeSha256'] and all(sha(Path(ct[k]))==ct[k+'Sha256'] for k in ['hardhatEntry','edrEntry','nativeBinding']) and sha(ROOT/'pnpm-lock.yaml')==ct['lockfileSha256'];save();ok=m['concreteToolsUnchanged'] and all(j['passed'] for j in m['checks']) and fault['passed'];finish('passed' if ok else 'failed');raise SystemExit(0 if m['status']=='passed' else 1)
if __name__=='__main__':main()
