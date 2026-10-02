#!/usr/bin/env python3
"""Retain a focused original postcondition failure for the binary-skip fault."""
import argparse,csv,datetime,importlib.util,json,re,shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('preparation_verify',HERE.parent/'verify.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
p=argparse.ArgumentParser();p.add_argument('--dafny',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
original=HERE.parent/'evidence/source-faults/manifest.json';prior=json.loads(original.read_text())
for src,digest in prior['sourceSha256'].items():
    if v.sha(v.ROOT/src)!=digest:raise ValueError('Source drift '+src)
for src,digest in prior['evidenceSha256'].items():
    if v.sha(original.parent/src)!=digest:raise ValueError('Artifact drift '+src)
if len(prior['faults'])!=3 or not prior['inputsUnchanged']:raise ValueError('Incomplete campaign')
for f in prior['faults']:
    if f['sourceGate']['exitCode']!=0 or not f['concrete']['killed']:raise ValueError('No source/EVM kill')
    if f['name']!='binary-skip' and not f['proof']['killed']:raise ValueError('Other incomplete fault')
out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
source=original.parent/'binary-skip/source-snapshot/formal/collections/preparation/Source.generated.dfy'
lines=source.read_text().splitlines();line=next(i+1 for i,s in enumerate(lines) if 'ensures out == Prepare(cb,binary,h,env)' in s)
command=v.common.proof_command(a.dafny,source,out/'proof.csv')+['--filter-symbol','CollectionsPreparationSource.PrepareCallback','--filter-position','Source.generated.dfy:'+str(line)]
result=v.run(command,out/'proof.log',180);log=(out/'proof.log').read_text();rows=list(csv.DictReader((out/'proof.csv').open()))
passed=result['exitCode']==4 and 'postcondition could not be proved' in log and not re.search(r'time.?out|inconclusive|resolution/type errors|parse errors',log,re.I) and any(r['TestResult.Outcome']!='Passed' and r['TestResult.DisplayName'].startswith('CollectionsPreparationSource.PrepareCallback') for r in rows)
shutil.copy2(original,out/'original-campaign.json')
m={'status':'passed' if passed else 'failed','scope':'Three gated Solidity faults fail semantic obligations and designated EVM tests. Binary-skip is certified by its original postcondition batch only; the earlier full mutant run timeout is retained, not counted as a kill.','originalCampaign':str(original.relative_to(v.ROOT)),'originalCampaignSha256':v.sha(original),'sourceSha256':dict(prior['sourceSha256'],**{str(Path(__file__).resolve().relative_to(v.ROOT)):v.sha(Path(__file__))}),'executableSha256':prior['executableSha256'],'focusedFault':'binary-skip','postconditionLine':line,'proof':result,'nativeResults':rows,'completedAt':datetime.datetime.now(datetime.timezone.utc).isoformat()}
if v.sha(a.dafny)!=m['executableSha256']['dafny']:raise ValueError('Tool drift')
m['inputsUnchanged']=all(v.sha(v.ROOT/s)==d for s,d in m['sourceSha256'].items());m['evidenceSha256']={str(f.relative_to(out)):v.sha(f) for f in out.rglob('*') if f.is_file()}
(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(m['status']);raise SystemExit(0 if passed and m['inputsUnchanged'] else 1)
