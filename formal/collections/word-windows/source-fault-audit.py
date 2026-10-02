#!/usr/bin/env python3
"""Change window checks, addresses and loops only in isolated source snapshots; require semantic and EVM failures."""
import argparse,json,re,shutil,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);a=p.parse_args()
a.output.mkdir(parents=True,exist_ok=False)
results=[]
for name,old,new,symbol in [
    ('strict-end', 'elemOffsets[j] > template.length - 32', 'elemOffsets[j] >= template.length - 32', 'CheckElements'),
    ('acc-address', 'mstore(add(add(callData, 32), accOffset), acc)', 'mstore(add(add(callData, 33), accOffset), acc)', 'Address'),
    ('skip-last-write', 'function _stampElements(bytes memory callData, uint256[] calldata elemOffsets, bytes32 elem) private pure {\n        for (uint256 j = 0; j < elemOffsets.length; j++) {', 'function _stampElements(bytes memory callData, uint256[] calldata elemOffsets, bytes32 elem) private pure {\n        for (uint256 j = 0; j + 1 < elemOffsets.length; j++) {', 'StampElements')]:
    root=a.output/name;shutil.copytree(a.snapshot,root,ignore=shutil.ignore_patterns('out','cache','evidence'))
    source=root/'contracts/Collections.sol';text=source.read_text()
    if text.count(old)!=1:raise ValueError('Mutation anchor mismatch')
    source.write_text(text.replace(old,new));here=root/'formal/collections/word-windows'
    commands=[('source-gate',[sys.executable,'-B',here/'generate.py','--root',root,'--solc',a.solc,'--output',root/'generated']),
      ('proof',[a.dafny,'verify',here/'Connection.dfy','--verify-included-files','--manual-lemma-induction','--isolate-assertions','--cores','2','--verification-time-limit','30','--solver-path',a.dafny.parent/'z3/bin/z3-4.12.1','--filter-symbol','CollectionsWordWindowsSource.'+symbol,'--progress','Symbol']),
      ('concrete',['forge','test','--root',root,'--match-contract','WordWindowsOracleTest','-vv'])]
    result={'name':name,'old':old,'new':new,'checks':[]}
    for label,command in commands:
        try:
            proc=subprocess.run([str(x) for x in command],capture_output=True,text=True,timeout=240)
            output=proc.stdout+proc.stderr;code=proc.returncode
        except subprocess.TimeoutExpired as e:raise RuntimeError('Mutation timeout is not evidence: '+name+'/'+label) from e
        (root/(label+'.log')).write_text(output)
        if label=='source-gate':
            passed=code==0
            if passed:shutil.copy2(root/'generated/Source.generated.dfy',here/'Source.generated.dfy')
        elif label=='proof':passed=code!=0 and ('might not hold' in output or 'postcondition could not be proved' in output)
        else:passed=code!=0 and bool(re.search(r'\[FAIL[^\n]*\] test',output))
        result['checks'].append({'name':label,'command':[str(x) for x in command],'exitCode':code,'passed':passed})
        if not passed:raise ValueError('Fault not detected: '+name+'/'+label)
    shutil.rmtree(root/'out',ignore_errors=True);shutil.rmtree(root/'cache',ignore_errors=True)
    results.append(result)
(a.output/'results.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS: all three window faults pass translation and fail the source theorem and EVM fixtures')
