#!/usr/bin/env python3
"""Reproducible private physical clones with full-frame bounds and independent result slot."""
from pathlib import Path
import re,hashlib,json,subprocess,os
H=Path(__file__).resolve().parent;R=H.parents[3];P=R/'formal/bytecode/assertions-primitives';C=H.parent;records=[]
for name,new in [(n,'AssertionsPick'+n) for n in ['RawWordPositive','RawWordNegative','RawWordPositiveOob','RawWordNegativeOob']]:
 p=P/(name+'.generated.dfy');s=p.read_text().replace('include "../','include "../../').replace('include "Scalar.dfy"','include "../../assertions-primitives/Scalar.dfy"\ninclude "../gather-composition/CallerElementSpec.dfy"').replace('module AssertionsPrimitive'+name,'module '+new)
 s=re.sub(r'  function RuntimeDestinations\(\): set<nat> \{[^\n]+\}', '  import DS = AssertionsGatherCallerSpec\n  function RuntimeDestinations(): set<nat> { DS.RuntimeDestinations() }',s)
 s=s.replace('    ensures state.Running? && Step(code,Destinations(ret),state,value,data) != Bad','    ensures state.Running? && state.pc < |code| && |state.stack| <= 1000\n    ensures Step(code,Destinations(ret),state,value,data) != Bad')
 at=s.index('  lemma Advance(id:');s=s[:at]+s[at:].replace('    reveal Good();','    reveal Good(); reveal Matches();',1)
 bounds='forall j {:trigger trace[j]} :: 0 <= j < |trace|-1 ==> trace[j].Running? && trace[j].pc < |code| && |trace[j].stack| <= 1000'
 s=s.replace('    ensures trace[0] == Running(7405,prefix+[ret,ptr,index],mem) && trace[|trace|-1] == state','    ensures trace[0] == Running(7405,prefix+[ret,ptr,index],mem) && trace[|trace|-1] == state\n    ensures '+bounds)
 s=re.sub(r'(      invariant id <= \d+ && \|trace\| == id\+1)',r'\1\n      invariant '+bounds,s)
 (H/(name+'.generated.dfy')).write_text(s);(H/(name+'.mapping.json')).write_bytes((P/(name+'.mapping.json')).read_bytes());records.append({'input':str(p.relative_to(R)),'inputSha256':hashlib.sha256(p.read_bytes()).hexdigest(),'output':name+'.generated.dfy','changes':['module/include routing','scanned caller inventory','all reached frame instruction bounds']})
p=C/'PickExit.generated.dfy';s=p.read_text().replace('include "../','include "../../').replace('module AssertionsControlPickExit','module AssertionsPickExit')
s=s.replace('include "../../assertions-primitives/Scalar.dfy"','include "../../assertions-primitives/Scalar.dfy"\ninclude "../gather-composition/CallerElementSpec.dfy"')
s=re.sub(r'  function RuntimeDestinations\(\): set<nat> \{[^\n]+\}', '  import DS = AssertionsGatherCallerSpec\n  function RuntimeDestinations(): set<nat> { DS.RuntimeDestinations() }',s)
(H/'Exit.generated.dfy').write_text(s);(H/'Exit.mapping.json').write_bytes((C/'PickExit.mapping.json').read_bytes());records.append({'input':str(p.relative_to(R)),'inputSha256':hashlib.sha256(p.read_bytes()).hexdigest(),'output':'Exit.generated.dfy','changes':['module/include routing','scanned caller inventory']})
subprocess.run([os.environ.get('DAFNY','/home/sem/assertions-tools/dafny/dafny'),'format',*[H/r['output'] for r in records]],check=True)
(H/'leaf-provenance.json').write_text(json.dumps(records,indent=2)+'\n')
