#!/usr/bin/env python3
"""Isolate semantic source faults; require successful translation and native/EVM rejection."""
import argparse,json,re,shutil,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);a=p.parse_args()
a.output.mkdir(parents=True,exist_ok=False)
results=[]
for name,old,new,symbol,file,anchor in [
    ('inverted-retention', 'if (!seen) _setWord(out, kept++, word);', 'if (seen) _setWord(out, kept++, word);', 'Source.Run','Source.dfy','assert Ctrl.Unseen(seen) == Keep(k,i);'),
    ('skipped-last-retained-word', 'for (uint256 j = 0; j < kept; j++)', 'for (uint256 j = 0; j + 1 < kept; j++)', 'Source.Scan','Source.dfy','assert j == kept;'),
    ('wrong-output-shrink', 'mstore(out, mul(kept, 32))', 'mstore(out, mul(kept, 16))', 'Source.Run','Source.dfy','assert Ctrl.ShrinkBytes(kept) == 32*kept;')]:
    root=a.output/name;shutil.copytree(a.snapshot,root,ignore=shutil.ignore_patterns('out','cache','evidence'))
    source=root/'contracts/Collections.sol';text=source.read_text()
    start=text.index('    function uniqueWords(');end=text.index('    function packArray(',start)
    part=text[start:end]
    if part.count(old)!=1:raise ValueError('Mutation anchor mismatch')
    source.write_text(text[:start]+part.replace(old,new)+text[end:]);here=root/'formal/collections/word-unique'
    lines=(here/file).read_text().splitlines()
    matches=[i+1 for i,line in enumerate(lines) if anchor in line]
    if len(matches)!=1:raise ValueError('Native semantic assertion anchor mismatch')
    position=file+':'+str(matches[0])
    commands=[('source-gate',[sys.executable,'-B',here/'generate.py','--root',root,'--solc',a.solc,'--output',root/'generated']),
      ('proof',[a.dafny,'verify',here/'Connection.dfy','--verify-included-files','--manual-lemma-induction','--isolate-assertions','--cores','2','--verification-time-limit','30','--solver-path',a.dafny.parent/'z3/bin/z3-4.12.1','--filter-symbol','CollectionsWordUnique'+symbol,'--progress','Symbol','--filter-position',position]),
      ('concrete',['forge','test','--root',root,'--match-contract','^WordUniqueOracleTest$','-vv'])]
    result={'name':name,'old':old,'new':new,'semanticAssertion':{'file':file,'line':matches[0],'text':anchor},'checks':[]}
    for label,command in commands:
        try:
            proc=subprocess.run([str(x) for x in command],capture_output=True,text=True,timeout=240)
            output=proc.stdout+proc.stderr;code=proc.returncode
        except subprocess.TimeoutExpired as e:raise RuntimeError('Mutation timeout is not evidence: '+name+'/'+label) from e
        (root/(label+'.log')).write_text(output)
        if label=='source-gate':
            passed=code==0
            if passed:shutil.copy2(root/'generated/Control.generated.dfy',here/'Control.generated.dfy')
        elif label=='proof':passed=code!=0 and ('might not hold' in output or 'postcondition could not be proved' in output or 'invariant could not be proved' in output) and not re.search(r'timed out|inconclusive|resource limit',output,re.I)
        else:passed=code!=0 and bool(re.search(r'\[FAIL[^\n]*\] test',output))
        result['checks'].append({'name':label,'command':[str(x) for x in command],'exitCode':code,'passed':passed})
        if not passed:raise ValueError('Fault not detected: '+name+'/'+label)
    shutil.rmtree(root/'out',ignore_errors=True);shutil.rmtree(root/'cache',ignore_errors=True)
    results.append(result)
(a.output/'results.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS: all three source faults pass translation and fail native semantics and EVM fixtures')
