#!/usr/bin/env python3
"""Isolate semantic source faults; require successful translation and native/EVM rejection."""
import argparse,json,re,shutil,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);a=p.parse_args()
a.output.mkdir(parents=True,exist_ok=False)
results=[]
for name,old,new,symbol,file,anchor,function in [
    ('zip-validates-only-first-right','validate(bytes(rightType), right[i]);','validate(bytes(rightType), right[0]);','Entry.Zip','Entry.dfy','assert leftIndex == i && rightIndex == i;','zipValues'),
    ('zip-wrong-array-mode','plan.headSize, pair, false','plan.headSize, pair, true','Entry.Zip','Entry.dfy','assert Ctrl.ArrayMode() == false;','zipValues'),
    ('zip-missing-single-dynamic-envelope','plan.dynamic[0] || plan.dynamic[1] ?','plan.dynamic[0] && plan.dynamic[1] ?','Entry.Zip','Entry.dfy','assert Ctrl.Envelope(Dyn(p.left),Dyn(p.right)) == (M.Base(p) == 32);','zipValues'),
    ('unzip-skips-right-validation','validate(bytes(rightType), parts[1]);','validate(bytes(rightType), parts[0]);','Entry.Unzip','Entry.dfy','assert a == 0 && b == 1;','unzipValues'),
    ('unzip-opposite-lane','out[i] = parts[lane];','out[i] = parts[1 - lane];','Entry.Unzip','Entry.dfy','assert lane == k.lane;','unzipValues'),
    ('pair-inverted-exact-tail','if (base + tail != pair.length)','if (base + tail == pair.length)','Source.Pair','Source.dfy','assert Ctrl.TailWrong(base as nat,tail,|bytes|) == (base+tail != |bytes|);','_unzipPair')]:
    root=a.output/name;shutil.copytree(a.snapshot,root,ignore=shutil.ignore_patterns('out','cache','evidence'))
    source=root/'contracts/Collections.sol';text=source.read_text()
    start=text.index('    function '+function+'(')
    next_function=text.find('    function ',start+5)
    end=next_function if next_function >= 0 else len(text)
    part=text[start:end]
    if part.count(old)!=1:raise ValueError('Mutation anchor mismatch')
    source.write_text(text[:start]+part.replace(old,new)+text[end:]);here=root/'formal/collections/value-pairs'
    lines=(here/file).read_text().splitlines()
    method_name=symbol.split('.')[-1]
    starts=[i for i,line in enumerate(lines) if 'ghost method '+method_name+'(' in line]
    if len(starts)!=1:raise ValueError('Native declaration anchor mismatch')
    method_start=starts[0]
    method_end=next((i for i in range(method_start+1,len(lines)) if re.match(r'^  (?:ghost )?method ',lines[i]) or re.match(r'^  (?:ghost )?function ',lines[i])),len(lines))
    matches=[i+1 for i,line in enumerate(lines) if method_start <= i < method_end and anchor in line]
    if len(matches)!=1:raise ValueError('Native semantic assertion anchor mismatch')
    position=file+':'+str(matches[0])
    commands=[('source-gate',[sys.executable,'-B',here/'generate.py','--root',root,'--solc',a.solc,'--output',root/'generated']),
      ('proof',[a.dafny,'verify',here/'Connection.dfy','--verify-included-files','--manual-lemma-induction','--isolate-assertions','--cores','2','--verification-time-limit','30','--solver-path',a.dafny.parent/'z3/bin/z3-4.12.1','--filter-symbol','CollectionsValuePairs'+symbol,'--progress','Symbol','--filter-position',position]),
      ('concrete',['forge','test','--root',root,'--match-contract','^ValuePairsOracleTest$','-vv'])]
    result={'name':name,'old':old,'new':new,'semanticAssertion':{'file':file,'line':matches[0],'text':anchor},'checks':[]}
    for label,command in commands:
        try:
            proc=subprocess.run([str(x) for x in command],capture_output=True,text=True,timeout=240)
            output=proc.stdout+proc.stderr;code=proc.returncode
        except subprocess.TimeoutExpired as e:raise RuntimeError('Mutation timeout is not evidence: '+name+'/'+label) from e
        (root/(label+'.log')).write_text(output)
        if label=='source-gate':
            passed=code==0
            if passed:
                for filename in ['Control.generated.dfy']:shutil.copy2(root/'generated'/filename,here/filename)
        elif label=='proof':passed=code!=0 and ('might not hold' in output or 'postcondition could not be proved' in output or 'invariant could not be proved' in output) and not re.search(r'timed out|inconclusive|resource limit',output,re.I)
        else:passed=code!=0 and bool(re.search(r'\[FAIL[^\n]*\] test',output))
        result['checks'].append({'name':label,'command':[str(x) for x in command],'exitCode':code,'passed':passed})
        if not passed:raise ValueError('Fault not detected: '+name+'/'+label)
    shutil.rmtree(root/'out',ignore_errors=True);shutil.rmtree(root/'cache',ignore_errors=True)
    results.append(result)
(a.output/'results.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS: all six source faults pass translation and fail native semantics and EVM fixtures')
