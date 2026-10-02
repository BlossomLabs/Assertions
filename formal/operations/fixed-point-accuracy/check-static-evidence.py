#!/usr/bin/env python3
"""Check only static preparation receipts; never upgrade them to analytic proofs."""
import argparse,hashlib,importlib.util,json,subprocess,sys,tempfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser();p.add_argument('--manifest',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);a=p.parse_args();manifest=a.manifest.resolve();out=manifest.parent;m=json.loads(manifest.read_text())
    if m['status']!='static-checks-passed' or m['claimStatus']!='native-unverified-preparation-only' or m['publicCoverageAdded']!=0:raise ValueError('Not a completed static-only packet')
    if any(m[k] for k in ['nativeVerificationRun','solverLaunched','evmRun']):raise ValueError('Unexpected native/EVM work')
    if not m['inputsUnchanged'] or not m['currentRetainedSourceInputsMatched']:raise ValueError('Input drift')
    for name,value in m['sourceSha256'].items():
        if sha(ROOT/name)!=value or sha(out/'source-snapshot'/name)!=value:raise ValueError('Current/snapshot input drift '+name)
    for name,value in m['evidenceSha256'].items():
        if sha(out/name)!=value:raise ValueError('Static artifact drift '+name)
    spec=importlib.util.spec_from_file_location('static_run',HERE/'static-check.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
    if {str(f.relative_to(ROOT)):sha(f) for f in v.inputs()}!=m['sourceSha256']:raise ValueError('Input inventory drift')
    tools={'dafny':a.dafny.resolve(),'Dafny.dll':a.dafny.resolve().parent/'Dafny.dll'}
    if {k:sha(f) for k,f in tools.items()}!=m['toolSha256']:raise ValueError('Tool drift')
    checks={x['name']:x for x in m['checks']}
    if len(checks)!=4 or len(m['checks'])!=4 or set(checks)!={'resolve','format','audit','fraction-diagnostics'} or not all(x['passed'] and x['exitCode']==0 for x in checks.values()):raise ValueError('Static check inventory/results')
    for name in ['resolve','format','audit']:
        command=checks[name]['command'];verb='format' if name=='format' else name
        if command[:2]!=[str(a.dafny.resolve()),verb]:raise ValueError('Unexpected static command')
    if '--check' not in checks['format']['command'] or '--cores' not in checks['resolve']['command']:raise ValueError('Static command settings')
    if 'auditor completed with 0 findings' not in (out/'audit.log').read_text():raise ValueError('Audit receipt')
    if 'did not attempt verification' not in (out/'resolve.log').read_text():raise ValueError('Resolve receipt is not static')
    with tempfile.TemporaryDirectory(prefix='operations-analytic-static-check-') as temporary:
        diagnostics=Path(temporary)/'diagnostics.json'
        subprocess.run([sys.executable,'-B',str(HERE/'enclosures.py'),'--root',str(ROOT),'--output',str(diagnostics)],check=True)
        if diagnostics.read_bytes()!=(out/'diagnostics.json').read_bytes():raise ValueError('Fraction diagnostic regeneration drift')
    print('PASS: static preparation/input/tool/receipt checks only; all new native/analytic proof obligations remain open; zero coverage added')
if __name__=='__main__':main()
