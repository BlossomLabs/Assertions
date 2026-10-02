#!/usr/bin/env python3
"""Compiler-admissible scalar faults must fail an independent native theorem and EVM oracle."""
import argparse,json,re,shutil,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
results=[]
for name,signature,old,new,symbol in [
 ('accepts-long-signal-prefix','function _rejectOutOfGas(uint256 gasBefore, bytes memory ret)','ret.length == 4','ret.length >= 4','GroundLongSignalWitness'),
 ('missing-exhaustion-guard','function _rejectOutOfGas(uint256 gasBefore, bytes memory ret)','gasleft() <= gasBefore / 63','gasleft() < 0','Guard')]:
    root=a.output/name;shutil.copytree(a.snapshot,root,ignore=shutil.ignore_patterns('out','cache','evidence'));source=root/'contracts/Operations.sol';text=source.read_text();start=text.index(signature);end=text.index('\n    }',start)+6;body=text[start:end]
    if body.count(old)!=1:raise ValueError('Mutation anchor mismatch')
    source.write_text(text[:start]+body.replace(old,new)+text[end:]);here=root/'formal/operations/raw-call'
    commands=[('source-gate',[sys.executable,'-B',here/'generate.py','--root',root,'--solc',a.solc,'--output',root/'generated']),('proof',[a.dafny,'verify',here/'Connection.dfy','--verify-included-files','--manual-lemma-induction','--isolate-assertions','--cores','2','--verification-time-limit','30','--solver-path',a.dafny.parent/'z3/bin/z3-4.12.1','--filter-symbol','OperationsRawCallConnection.'+symbol,'--progress','Symbol']),('concrete',['forge','test','--root',root,'--match-contract','^OperationsRawCallOracleTest$','-vv'])]
    result={'name':name,'signature':signature,'old':old,'new':new,'checks':[]}
    for label,command in commands:
        try:proc=subprocess.run([str(x) for x in command],capture_output=True,text=True,timeout=240)
        except subprocess.TimeoutExpired as e:raise RuntimeError('Mutation timeout is incomplete') from e
        output=proc.stdout+proc.stderr;code=proc.returncode;(root/(label+'.log')).write_text(output)
        if label=='source-gate':
            passed=code==0
            if passed:shutil.copy2(root/'generated/Control.generated.dfy',here/'Control.generated.dfy')
        elif label=='proof':passed=code==4 and ('might not hold' in output or 'postcondition could not be proved' in output) and not re.search(r'timed out|inconclusive|resource limit|parse errors|resolution/type errors',output,re.I)
        else:passed=code!=0 and bool(re.search(r'\[FAIL[^\n]*\] test',output))
        result['checks'].append({'name':label,'command':[str(x) for x in command],'exitCode':code,'passed':passed})
        if not passed:raise ValueError('Fault not detected '+name+'/'+label)
    shutil.rmtree(root/'out',ignore_errors=True);shutil.rmtree(root/'cache',ignore_errors=True);results.append(result)
(a.output/'results.json').write_text(json.dumps(results,indent=2)+'\n');print('PASS: two raw-call faults translate and fail native semantics and EVM')
