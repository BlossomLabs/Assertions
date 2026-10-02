"""Independently replay fresh adapter generation from frozen inputs and compare canonical declarations."""
import argparse
import gzip
import importlib.util
import json
import subprocess
import tempfile
from pathlib import Path
from check import ROOT, LIBRARY, check, digest
from declarations import declarations
from generate import CONFIG, format_dependency_path


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('package',choices=sorted(CONFIG))
    parser.add_argument('--evidence',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    check()
    assert not args.output.exists(),'Review output must be fresh'
    evidence=args.evidence.resolve()
    manifest=json.loads((evidence/'manifest.json').read_text())
    assert manifest['package']==args.package
    assert manifest['status']=='generation-and-canonical-declarations-passed'
    config=CONFIG[args.package]
    if 'configuration' in manifest:
        assert manifest['configuration']==config,'Generation configuration changed'
    for relative,value in manifest['evidenceSha256'].items():
        assert digest(evidence/relative)==value, 'Evidence changed: '+relative
    for relative,value in manifest['inputs'].items():
        assert digest(evidence/'inputs'/relative)==value,'Frozen input changed: '+relative
    for relative,value in manifest['tools'].items():
        assert digest(ROOT/relative)==value,'Compiler/format tool changed: '+relative
    generator=evidence/'generator'/Path(config['generator']).name
    assert digest(generator)==manifest['inputs'][config['generator']]
    for name in config['inputs']:
        original=str(Path(config['generator']).parent/name)
        assert digest(generator.parent/name)==manifest['inputs'][original]
    canonical=ROOT/config['canonical']
    assert digest(canonical)==manifest['inputs'][config['canonical']],'Canonical adapter changed'
    generated=evidence/'generated'/config['adapter']
    assert declarations(generated)==declarations(canonical),'Canonical declaration mismatch'
    request=json.loads((evidence/'generated/solc-input.json').read_text())
    for name,source in request['sources'].items():
        relative=name if (evidence/'inputs'/name).exists() else 'node_modules/'+name
        assert source['content']==(evidence/'inputs'/relative).read_text(),'Compiler source input mismatch'
        assert digest(ROOT/relative)==manifest['inputs'][relative],'Current Solidity/import source changed'
    compiler=ROOT/'proof-tools/assertions/solc-0.8.36'
    result=subprocess.run([str(compiler),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,check=True)
    compiled=json.loads(result.stdout)
    assert not any(e.get('severity')=='error' for e in compiled.get('errors',[]))
    assert compiled==json.loads(gzip.decompress((evidence/'generated/solc-output.json.gz').read_bytes())), 'Compiler replay mismatch'
    spec=importlib.util.spec_from_file_location('frozen_generation',generator)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    assert {str(p) for p in module.SOURCES} <= set(manifest['inputs']), 'Incomplete generator input closure'
    with tempfile.TemporaryDirectory() as directory:
        replay=Path(directory)/'replay'
        module.generate(compiler,evidence/'inputs',replay,False)
        for relative in config['formatDependencies']:
            destination=format_dependency_path(replay,config,relative)
            destination.parent.mkdir(parents=True,exist_ok=True)
            destination.write_bytes((evidence/'inputs'/relative).read_bytes())
        subprocess.run([str(ROOT/'proof-tools/assertions/dafny/dafny'),'format',str(replay/config['adapter'])],capture_output=True,text=True,check=True)
        assert json.loads((replay/'solc-input.json').read_text())==request,'Generator replay compiler settings mismatch'
        assert declarations(replay/config['adapter'])==declarations(canonical),'Generator replay declaration mismatch'
        assert json.loads((replay/'mapping.json').read_text())==json.loads((evidence/'generated/mapping.json').read_text()),'Generator replay mapping mismatch'
    receipt={'package':args.package,'status':'independently-reviewed-generation-correspondence',
             'evidence':str(evidence.relative_to(ROOT)) if evidence.is_relative_to(ROOT) else str(evidence),'manifestSha256':digest(evidence/'manifest.json'),
             'reviewerSha256':digest(Path(__file__)),'declarations':len(declarations(canonical)),
             'scope':'Independent pinned compiler and frozen restricted-generator replay; complete canonical declaration interfaces and bodies match. Restricted translation remains an explicit premise.',
             'sourceAcceptance':False,'nativeCredit':False,'bytecodeCredit':False}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(receipt,indent=2)+'\n')
    print('PASS independent generation review:',receipt['declarations'],'declarations')

if __name__=='__main__':
    main()
