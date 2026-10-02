#!/usr/bin/env python3
"""Independent current-input, native-inventory and retained-artifact decimal-render evidence checker."""
import argparse,csv,hashlib,importlib.util,json,re,shutil,subprocess,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
p=argparse.ArgumentParser();p.add_argument('--manifest',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);a=p.parse_args();manifest=a.manifest.resolve();out=manifest.parent;m=json.loads(manifest.read_text())
if m['status']!='passed' or not m['inputsUnchanged'] or len(m['entries'])!=2:raise ValueError('Incomplete evidence')
for name,value in m['sourceSha256'].items():
    if sha(ROOT/name)!=value or sha(out/'source-snapshot'/name)!=value:raise ValueError('Source/snapshot drift '+name)
for name,value in m['evidenceSha256'].items():
    if sha(out/name)!=value:raise ValueError('Evidence drift '+name)
spec=importlib.util.spec_from_file_location('verifier',HERE/'verify.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
if m['sourceSha256']!={str(x.relative_to(ROOT)):sha(x) for x in v.inputs()}:raise ValueError('Incomplete current input inventory')
tools={'dafny':a.dafny.resolve(),'Dafny.dll':a.dafny.resolve().parent/'Dafny.dll','z3':a.dafny.resolve().parent/'z3/bin/z3-4.12.1','solc':a.solc.resolve()}
if {k:sha(x) for k,x in tools.items()}!=m['executableSha256']:raise ValueError('Tool drift')
if sha(Path(shutil.which('forge')))!=m['concreteTool']['sha256']:raise ValueError('EVM tool drift')
checks={x['name']:x for x in m['checks']}
if set(checks)!={'source-gate','proof','audit','dafny-format','solidity-format','concrete','source-faults'} or not all(x['passed'] and x['exitCode']==0 for x in checks.values()):raise ValueError('Check coverage')
job=dict(checks['proof']);v.common.check_proof(job,out/'proof.log',out/'proof.csv',v.inventory(HERE))
if not job['passed'] or job['nativeResults']!=checks['proof']['nativeResults'] or job['declarations']!=checks['proof']['declarations']:raise ValueError('Native inventory/results drift')
if 'auditor completed with 0 findings' not in (out/'audit.log').read_text():raise ValueError('Audit findings')
expected=re.findall(r'function (test\w+)\(', (HERE/'RenderOracle.t.sol').read_text());actual=re.findall(r'^\[PASS\] (test\w+)\(', (out/'concrete.log').read_text(),re.M)
if len(expected)!=2 or sorted(expected)!=sorted(actual) or expected!=checks['concrete']['expectedTests']:raise ValueError('EVM inventory drift')
faults=json.loads((out/'source-faults/results.json').read_text())
if {x['name'] for x in faults}!={'wrong-ascii-offset','wrong-digit-count-divisor'}:raise ValueError('Semantic fault inventory')
for fault in faults:
    cs={x['name']:x for x in fault['checks']}
    if set(cs)!={'source-gate','proof','concrete'} or not all(x['passed'] for x in cs.values()) or cs['source-gate']['exitCode']!=0 or cs['proof']['exitCode']!=4 or cs['concrete']['exitCode']==0:raise ValueError('Semantic fault result')
    log=(out/'source-faults'/fault['name']/'proof.log').read_text()
    if re.search(r'timed out|inconclusive|resource limit|parse errors|resolution/type errors',log,re.I) or not ('might not hold' in log or 'postcondition could not be proved' in log or 'invariant could not be proved' in log):raise ValueError('Fault error/timeout is not detection')
with tempfile.TemporaryDirectory(prefix='operations-decimal-render-check-') as temporary:
    generated=Path(temporary)
    subprocess.run(['python3','-B',str(HERE/'generate.py'),'--root',str(ROOT),'--solc',str(a.solc),'--output',str(generated)],check=True)
    if (generated/'Control.generated.dfy').read_bytes()!=(HERE/'Control.generated.dfy').read_bytes():raise ValueError('Current regeneration drift')
print('PASS: Operations decimal-render conditional source evidence, 2 public entries, '+str(len(job['nativeResults']))+' native obligations, zero audit, 2 EVM tests, 2 semantic source faults')
