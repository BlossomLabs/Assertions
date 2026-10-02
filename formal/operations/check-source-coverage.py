#!/usr/bin/env python3
"""Check complete conditional Operations source coverage and every retained package.

This does not prove runtime bytecode or strengthen any package's listed premises.
"""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    parser=argparse.ArgumentParser();parser.add_argument('--dafny',type=Path,required=True);parser.add_argument('--solc',type=Path,required=True);a=parser.parse_args()
    plan=json.loads((HERE/'verification-plan.json').read_text());entries=plan['publicEntries']
    if len(entries)!=92 or len({x['signature'] for x in entries})!=92:raise ValueError('Public inventory mismatch')
    if any(x['status']!='conditional-source-passed' for x in entries):raise ValueError('Conditional source entries remain open')
    source=sha(ROOT/'contracts/Operations.sol')
    if plan['currentSourceCoverage']!={'completed':92,'total':92,'remaining':0,'sourceSha256':source}:raise ValueError('Current coverage mismatch')
    claimed={};selectors={};packages=[]
    for ledger_name in sorted({x['ledger'] for x in entries}):
        ledger=json.loads((ROOT/ledger_name).read_text());manifest=ROOT/ledger['manifest'];m=json.loads(manifest.read_text())
        if ledger['status']!='retained-passed-independent-checker-passed' or m['status']!='passed' or not m['inputsUnchanged']:raise ValueError('Incomplete retained coverage '+ledger_name)
        if ledger['manifestSha256']!=sha(manifest) or m['sourceSha256']['contracts/Operations.sol']!=source:raise ValueError('Historical or drifted coverage '+ledger_name)
        if ledger['entries']!=m['entries']:raise ValueError('Ledger entry mismatch '+ledger_name)
        for entry in ledger['entries']:
            signature=entry['signature']
            if signature in claimed:raise ValueError('Duplicate covered entry '+signature)
            claimed[signature]=ledger_name;selectors[signature]=entry['selector']
        packages.append((ROOT/ledger['checker'],manifest))
    if claimed!={x['signature']:x['ledger'] for x in entries}:raise ValueError('Coverage union does not match public inventory')
    # The final complete-body compiler gate's snapshot includes all public method IDs.
    final=ROOT/'formal/operations/fixed-point/evidence/conditional-source-v1';import gzip
    solc=json.loads(gzip.decompress((final/'generated/muldiv-regenerated/solc-output.json.gz').read_bytes()))
    methods=solc['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers']
    if methods!=selectors:raise ValueError('Compiled public signature/selector inventory mismatch')
    for checker,manifest in packages:
        subprocess.run([sys.executable,'-B',str(checker),'--manifest',str(manifest),'--dafny',str(a.dafny),'--solc',str(a.solc)],check=True)
    print(f'PASS: {len(claimed)}/92 current conditional Operations source entries in {len(packages)} independently checked retained packages. Exact-bytecode and unproved analytic approximation bounds remain separate.')
if __name__=='__main__':main()
