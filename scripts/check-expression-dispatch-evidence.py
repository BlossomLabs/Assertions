#!/usr/bin/env python3
"""Audit current production guarded-dispatch proof and both semantic faults."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
    if not ok:raise SystemExit(message)
p=ROOT/'formal/expressions/dispatch/evidence/guarded-dispatch/manifest.json'
m=json.loads(p.read_text())
require(m['status']=='passed' and m['inputsUnchanged'],'Incomplete dispatch evidence')
for name,digest in m['sourceSha256'].items():require(sha(ROOT/name)==digest,'Source drift: '+name)
for name,digest in m['evidenceSha256'].items():require(sha(p.parent/name)==digest,'Artifact drift: '+name)
require([r['name'] for r in m['runs']]==['production','missing-call-check','missing-probe-check'],'Run inventory drift')
for r in m['runs']:
    require(r['passed'] and r['sourceGate']['exitCode']==0 and r['proof']['passed'] and r['audit']['passed'],'Failed run: '+r['name'])
    require(len(r['expectedTests'])==22 and sorted(r['passedTests']+r['failedTests'])==r['expectedTests'],'Incomplete EVM inventory')
    native=r['proof']['nativeResults']
    if r['name']=='production':
        require(r['exitCode']==0 and not r['failedTests'] and r['proof']['exitCode']==0,'Production failures')
        require(len(native)==47 and all(n['TestResult.Outcome']=='Passed' for n in native),'Native baseline failure')
        require(all(d['status']=='passed' for d in r['proof']['declarations'] if d['kind'] in {'method','lemma'}),'Unproved declaration')
    else:
        required=['testCallCannotInjectCache'] if r['name']=='missing-call-check' else ['testProbeCannotDispatchGuardedEntry','testProbeCannotDispatchMalformedGuardedEntry']
        require(r['exitCode']==1 and r['failedTests']==required and r['proof']['exitCode']==4,'Missing semantic fault kill')
        require(any(n['TestResult.DisplayName'].startswith('GuardedDispatchSource.Dispatch ') and n['TestResult.Outcome']!='Passed' for n in native),'Wrong theorem failed')
print('PASS: current production dispatch source, 47 native obligations, 22 EVM tests and two semantic/EVM fault kills')
