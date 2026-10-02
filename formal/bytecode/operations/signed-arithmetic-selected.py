#!/usr/bin/env python3
"""Selected repair/checkpoint development checks; never retained public coverage."""
import argparse, csv, importlib.util, json, re, shutil
from pathlib import Path

OWNER = Path(__file__).resolve().parent
ROOT = OWNER.parents[2]

def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

v = load('unsigned_arithmetic_retainer', OWNER/'signed-arithmetic-retention/verify.py')

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dafny', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    files = sorted(set(v.inputs()+[Path(__file__).resolve()]))
    hashes = {str(p.relative_to(ROOT)): v.sha(p) for p in files}
    for file in files:
        target = out/'source-snapshot'/file.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(file, target)
    dafny = args.dafny.resolve()
    tools = {'dafny':dafny,'Dafny.dll':dafny.parent/'Dafny.dll','z3':dafny.parent/'z3/bin/z3-4.12.1'}
    manifest = {'status':'development-running-not-retained', 'sourceSha256':hashes,
                'executableSha256':{name:v.sha(file) for name,file in tools.items()},
                'scope':'Checked signed sum/difference model, overlapping panic serialization, final panic paths and actual MSTORE semantic witnesses; no complete retained public native graph.', 'checks':[]}
    def save():
        (out/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    def record(name, command):
        job = v.common.run(command, out/(name+'.log'), 300)
        job.update(name=name, passed=job['exitCode']==0)
        manifest['checks'].append(job)
        save()
        return job
    save()
    for filename in ['Conversion.generated.dfy','Machine.dfy','Binary.dfy']:
        owner=OWNER/'signed-arithmetic'/filename
        source=out/'source-snapshot'/owner.relative_to(ROOT)
        symbol=re.search(r'^module (\w+)',owner.read_text(),re.M)[1]
        csvfile=out/(symbol+'.csv')
        job=record(symbol,v.common.proof_command(dafny,source,csvfile)+['--filter-symbol',symbol,'--progress','Symbol'])
        v.common.check_proof(job,out/(symbol+'.log'),csvfile,v.v.inventory(owner))
        save()
    for name in ['AddSOk','AddSOverflow','SubSOk','SubSOverflow']:
        owner=OWNER/'signed-arithmetic'/(name+'.generated.dfy')
        source=out/'source-snapshot'/owner.relative_to(ROOT)
        mapping=json.loads((owner.parent/(name+'.mapping.json')).read_text())
        for node in mapping['states']:
            if node['opcode']==0x57 and 'BitOr' in ''.join(node['stack']):
                symbol='OperationsSignedArithmetic'+name+'.Advance'+str(node['id'])
                csvfile=out/(name+'-overflow-guard.csv')
                job=record(name+'-overflow-guard',v.common.proof_command(dafny,source,csvfile)+['--filter-symbol',symbol,'--progress','Symbol'])
                v.common.check_proof(job,out/(name+'-overflow-guard.log'),csvfile,[d for d in v.v.inventory(owner) if d['name']==symbol])
                save()
    for name in ['AddSOverflow','SubSOverflow']:

        owner = OWNER/'signed-arithmetic'/(name+'.generated.dfy')
        source = out/'source-snapshot'/owner.relative_to(ROOT)
        mapping = json.loads(owner.with_suffix('').with_suffix('.mapping.json').read_text())
        symbol = 'OperationsSignedArithmetic'+name+'.Advance'+str(len(mapping['states'])-1)
        csvfile = out/(name+'-final.csv')
        job = record(name+'-final', v.common.proof_command(dafny,source,csvfile)+['--filter-symbol',symbol,'--progress','Symbol'])
        v.common.check_proof(job,out/(name+'-final.log'),csvfile,[d for d in v.v.inventory(owner) if d['name']==symbol])
        save()
    for name in ['AddSOk','SubSOk']:
        owner = OWNER/'signed-arithmetic'/(name+'.generated.dfy')
        source = out/'source-snapshot'/owner.relative_to(ROOT)
        symbol = 'OperationsSignedArithmetic'+name+'.Semantic'
        csvfile = out/(name+'-semantic.csv')
        job = record(name+'-semantic',v.common.proof_command(dafny,source,csvfile)+['--filter-symbol',symbol,'--progress','Symbol'])
        v.common.check_proof(job,out/(name+'-semantic.log'),csvfile,[d for d in v.v.inventory(owner) if d['name'].startswith(symbol)])
        save()
    snapshot = out/'source-snapshot'/OWNER.relative_to(ROOT)
    generation = record('candidate-generation', ['python3','-B',snapshot/'signed-arithmetic-retention/make-candidates.py','--output',out/'candidates'])
    if generation['passed']:
        for candidate in json.loads((out/'candidates/inventory.json').read_text()):
            name = candidate['entry']
            folder = out/'mutations'/candidate['name']
            folder.mkdir(parents=True)
            for filename in ['Conversion.generated.dfy','Machine.dfy','Binary.dfy']:
                shutil.copy2(snapshot/'signed-arithmetic'/filename,folder/filename)
            generation = record(candidate['name']+'-translation',['python3','-B',snapshot/'signed-arithmetic/generate.py','--runtime',out/'candidates'/(candidate['name']+'.bin'),'--output',folder])
            formatting = record(candidate['name']+'-format',['python3','-B',snapshot/'signed-arithmetic/format-generated.py','--output',folder,'--include-root',folder])
            if not generation['passed'] or not formatting['passed']:
                continue
            source = folder/(name+'.generated.dfy')
            lines = source.read_text().splitlines()
            begin = next(i for i,line in enumerate(lines) if 'lemma SemanticWitness(' in line)
            anchor = next(i for i in range(begin,len(lines)) if 'ensures state.stack[|state.stack|-2] == Result(a,b)' in lines[i])
            csvfile = folder/'proof.csv'
            job = record(candidate['name']+'-native',v.common.proof_command(dafny,source,csvfile)+['--filter-symbol',candidate['baselineSemanticSymbol'],'--filter-position',str(source)+':'+str(anchor+1),'--progress','Symbol'])
            text = (out/(candidate['name']+'-native.log')).read_text()
            rows = list(csv.DictReader(csvfile.open())) if csvfile.exists() else []
            job['passed'] = job['exitCode'] not in [0,None] and bool(rows) and any(r['TestResult.Outcome']=='Failed' for r in rows) and all(r['TestResult.Outcome'] in {'Passed','Failed'} for r in rows) and 'postcondition could not be proved' in text and not re.search(r'timed out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call',text,re.I)
            job['semanticAssertion'] = {'line':anchor+1,'text':lines[anchor]}
            job['nativeResults'] = rows
            save()
    manifest['inputsUnchanged'] = hashes == {str(p.relative_to(ROOT)):v.sha(p) for p in sorted(set(v.inputs()+[Path(__file__).resolve()]))}
    manifest['toolsUnchanged'] = manifest['executableSha256'] == {name:v.sha(file) for name,file in tools.items()}
    manifest['status'] = 'development-selected-passed-not-retained' if manifest['inputsUnchanged'] and manifest['toolsUnchanged'] and all(j['passed'] for j in manifest['checks']) else 'development-selected-failed-preserved'
    save()
    raise SystemExit(0 if manifest['status']=='development-selected-passed-not-retained' else 1)

if __name__ == '__main__':
    main()
