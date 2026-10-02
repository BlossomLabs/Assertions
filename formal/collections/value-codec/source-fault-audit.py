#!/usr/bin/env python3
"""Isolate semantic source faults; require successful translation and native/EVM rejection."""
import argparse,json,re,shutil,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);a=p.parse_args()
a.output.mkdir(parents=True,exist_ok=False)
results=[]
for name,old,new,symbol,file,anchor in [
    ('pack-validates-only-first','validate(t, values[i]);','validate(t, values[0]);','PackSource.Pack','Pack.generated.dfy','assert Ctrl.PackValidate(i) == i;'),
    ('missing-array-envelope','return assemble(dynamics, values.length * words * 32, values, true);','return assemble(dynamics, values.length * words * 32, values, false);','PackSource.Pack','Pack.generated.dfy','assert Ctrl.ArrayMode() == true;'),
    ('wrong-initial-envelope-word','word(encoded, 0) != 32','word(encoded, 0) != 31','UnpackSource.UnpackParsed','Unpack.generated.dfy','assert Ctrl.FirstMismatch(first.used) == (first.used != 32);'),
    ('inverted-exact-tail-check','64 + x.tail != encoded.length','64 + x.tail == encoded.length','UnpackSource.UnpackParsed','Unpack.generated.dfy','assert Ctrl.TailMismatch(r.used,|encoded|) == (64+r.used != |encoded|);')]:
    root=a.output/name;shutil.copytree(a.snapshot,root,ignore=shutil.ignore_patterns('out','cache','evidence'))
    source=root/'contracts/lib/AbiCodec.sol';text=source.read_text()
    function = 'pack' if name in {'pack-validates-only-first','missing-array-envelope'} else 'unpack'
    start=text.index('    function '+function+'(')
    next_function=text.find('    function ',start+5)
    end=next_function if next_function >= 0 else len(text)
    part=text[start:end]
    if part.count(old)!=1:raise ValueError('Mutation anchor mismatch')
    source.write_text(text[:start]+part.replace(old,new)+text[end:]);here=root/'formal/collections/value-codec'
    lines=(here/file).read_text().splitlines()
    matches=[i+1 for i,line in enumerate(lines) if anchor in line]
    if len(matches)!=1:raise ValueError('Native semantic assertion anchor mismatch')
    position=file+':'+str(matches[0])
    commands=[('source-gate',[sys.executable,'-B',here/'generate.py','--root',root,'--solc',a.solc,'--output',root/'generated']),
      ('proof',[a.dafny,'verify',here/'Connection.dfy','--verify-included-files','--manual-lemma-induction','--isolate-assertions','--cores','2','--verification-time-limit','30','--solver-path',a.dafny.parent/'z3/bin/z3-4.12.1','--filter-symbol','CollectionsValueCodec'+symbol,'--progress','Symbol','--filter-position',position]),
      ('concrete',['forge','test','--root',root,'--match-contract','^ValueCodecOracleTest$','-vv'])]
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
                for filename in ['Control.generated.dfy','Pack.generated.dfy','Unpack.generated.dfy']:shutil.copy2(root/'generated'/filename,here/filename)
        elif label=='proof':passed=code!=0 and ('might not hold' in output or 'postcondition could not be proved' in output or 'invariant could not be proved' in output) and not re.search(r'timed out|inconclusive|resource limit',output,re.I)
        else:passed=code!=0 and bool(re.search(r'\[FAIL[^\n]*\] test',output))
        result['checks'].append({'name':label,'command':[str(x) for x in command],'exitCode':code,'passed':passed})
        if not passed:raise ValueError('Fault not detected: '+name+'/'+label)
    shutil.rmtree(root/'out',ignore_errors=True);shutil.rmtree(root/'cache',ignore_errors=True)
    results.append(result)
(a.output/'results.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS: all four source faults pass translation and fail native semantics and EVM fixtures')
