#!/usr/bin/env python3
"""Recompile current canonical job inputs without modifying Hardhat artifacts."""
import argparse,copy,gzip,hashlib,json,re,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def source_path(key):
    if key.startswith('project/'):return ROOT/key.removeprefix('project/')
    m=re.fullmatch(r'npm/(@[^/]+/[^/@]+)@([^/]+)/(.+)',key)
    if m:
        base=ROOT/'node_modules'/m[1];assert json.loads((base/'package.json').read_text())['version']==m[2],'Dependency version drift'
        return base/m[3]
    raise ValueError('Unmapped canonical source '+key)
def rebuild(solc,out,contracts=('Assertions','Expressions','Collections')):
    assert contracts and len(set(contracts))==len(contracts)
    assert set(contracts)<= {'Assertions','Expressions','Collections'}
    assert '0.8.36+commit.8a079791' in subprocess.check_output([str(solc),'--version'],text=True)
    out.mkdir(parents=True,exist_ok=True);jobs={};results=[]
    for name in contracts:
        ap=ROOT/'artifacts/contracts'/f'{name}.sol'/f'{name}.json';a=json.loads(ap.read_text());job=a['buildInfoId']
        if job not in jobs:
            bp=ROOT/'artifacts/build-info'/(job+'.json');build=json.loads(bp.read_text());req=copy.deepcopy(build['input']);updated=[];sources={}
            for key,item in req['sources'].items():
                sp=source_path(key);current=sp.read_text();sources[str(sp.relative_to(ROOT))]=sha(sp)
                if item['content']!=current:updated.append(key);item['content']=current
            proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(req),text=True,capture_output=True,check=True);data=json.loads(proc.stdout)
            assert not any(e['severity']=='error' for e in data.get('errors',[]))
            (out/(job+'-input.json')).write_text(json.dumps(req,indent=2)+'\n');(out/(job+'-output.json.gz')).write_bytes(gzip.compress(proc.stdout.encode(),mtime=0));(out/(job+'-stderr.log')).write_text(proc.stderr)
            jobs[job]={'data':data,'sourceSha256':sources,'refreshedJobInputs':updated,'buildInfoSha256':sha(bp),'settings':req['settings']}
        j=jobs[job];c=j['data']['contracts'][a['inputSourceName']][name];runtime=bytes.fromhex(c['evm']['deployedBytecode']['object']);expected=bytes.fromhex(a['deployedBytecode'][2:])
        assert runtime==expected,('Exact canonical runtime mismatch',name)
        assert c['abi']==a['abi'] and not a['immutableReferences'] and not a['deployedLinkReferences']
        (out/(name+'.runtime.bin')).write_bytes(runtime)
        results.append({'contract':name,'identicalRuntime':True,'runtimeBytes':len(runtime),'runtimeSha256':hashlib.sha256(runtime).hexdigest(),'artifactSha256':sha(ap),'buildInfoId':job,'buildInfoSha256':j['buildInfoSha256'],'sourceSha256':j['sourceSha256'],'refreshedJobInputs':j['refreshedJobInputs'],'compilerSettings':j['settings'],'methodIdentifiers':c['evm']['methodIdentifiers'],'abi':c['abi']})
    (out/'identity.json').write_text(json.dumps(results,indent=2)+'\n')
    print('PASS: '+', '.join(contracts)+' full canonical runtimes, including metadata, reproduce from current inputs; no semantic claim from identity')
    return results
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--contract',action='append',choices=['Assertions','Expressions','Collections']);a=p.parse_args();rebuild(a.solc,a.output,a.contract or ('Assertions','Expressions','Collections'))
