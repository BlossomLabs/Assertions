"""Regenerate supported source adapters into fresh evidence; originals are read-only."""
import argparse
import datetime
import importlib.util
import json
import os
import shutil
import subprocess
from pathlib import Path
from check import ROOT, LIBRARY, check, digest
from declarations import declarations

CONFIG = {
    'original-operations-scalars':{
        'generator':'formal/source/generators/operations/scalars/generate.py',
        'inputs':['structure.json','entries.json'],
        'adapter':'Control.generated.dfy',
        'formatDependencies':['formal/source/operations/scalars/Model.dfy'],
        'canonical':'formal/source/operations/scalars/Control.generated.dfy'}}


for family in ['environment','byte-bounds','word-match','ascii']:
    CONFIG['original-operations-'+family] = {
        'generator':f'formal/source/generators/operations/{family}/generate.py',
        'inputs':['structure.json','entries.json']+([] if family=='environment' else ['Control.template.dfy']),
        'adapter':'Control.generated.dfy',
        'formatDependencies':[f'formal/source/operations/{family}/Model.dfy'],
        'canonical':f'formal/source/operations/{family}/Control.generated.dfy'}


for family in ['binary-log','checked-power','decimal-digits','decimal-render','decimal-units','utf8','integer-root','raw-call']:
    root=LIBRARY/'source/operations'/family
    visited=set()
    def visit(path):
        if path in visited:return
        visited.add(path)
        import re
        for include in re.findall(r'^include "([^"]+)"',path.read_text(),re.M):
            visit((path.parent/include).resolve())
    visit(root/'Control.generated.dfy')
    CONFIG['original-operations-'+family]={
        'generator':f'formal/source/generators/operations/{family}/generate.py',
        'inputs':['structure.json','entries.json','Control.template.dfy'],
        'adapter':'Control.generated.dfy',
        'formatDependencies':sorted(str(p.relative_to(ROOT)) for p in visited if p!=root/'Control.generated.dfy'),
        'canonical':str((root/'Control.generated.dfy').relative_to(ROOT))}


def format_dependency_path(output, config, relative):
    destination=(output/os.path.relpath(ROOT/relative,(ROOT/config['canonical']).parent)).resolve()
    assert destination.is_relative_to(output.parent.resolve()), 'Format dependency escapes evidence directory'
    return destination


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('package',choices=sorted(CONFIG))
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    check()
    config=CONFIG[args.package]
    output=args.output.resolve()
    assert not output.exists(),'Generation evidence must be fresh'
    output.mkdir(parents=True)
    generator=ROOT/config['generator']
    staged=output/'generator'/generator.name
    staged.parent.mkdir()
    shutil.copy2(generator,staged)
    inputs=[generator,Path(__file__),LIBRARY/'tools/declarations.py',LIBRARY/'tools/declaration_body.py',ROOT/config['canonical']]
    for name in config['inputs']:
        source=generator.parent/name
        inputs.append(source);shutil.copy2(source,staged.parent/name)
    spec=importlib.util.spec_from_file_location('staged_generator',staged)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    inputs += [ROOT/path for path in module.SOURCES]
    inputs += [ROOT/path for path in config['formatDependencies']]
    bound={str(p.relative_to(ROOT)):digest(p) for p in inputs}
    solc=ROOT/'proof-tools/assertions/solc-0.8.36'
    dafny=ROOT/'proof-tools/assertions/dafny/dafny'
    tools={str(p.relative_to(ROOT)):digest(p) for p in [solc,dafny,ROOT/'proof-tools/assertions/dafny/Dafny.dll']}
    receipt={'package':args.package,'status':'running','inputs':bound,'tools':tools,
             'scope':'Current restricted AST generation and exact canonical declaration correspondence; native verification, semantic faults and independent source acceptance remain separate.',
             'configuration':config,'startedAt':datetime.datetime.now(datetime.timezone.utc).isoformat()}
    def save():
        (output/'manifest.json').write_text(json.dumps(receipt,indent=2)+'\n')
    save()
    try:
        for relative in bound:
            destination=output/'inputs'/relative
            destination.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ROOT/relative,destination)
        generated=output/'generated'
        module.generate(solc,ROOT,generated,False)
        for relative in config['formatDependencies']:
            destination=format_dependency_path(generated,config,relative)
            destination.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(ROOT/relative,destination)
        command=[str(dafny),'format',str(generated/config['adapter'])]
        with (output/'format.log').open('w') as log:
            subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,check=True)
        assert declarations(generated/config['adapter'])==declarations(ROOT/config['canonical']), 'Generated declarations differ from canonical adapter'
        assert all(digest(ROOT/p)==h for p,h in bound.items()),'Generation inputs changed'
        assert all(digest(ROOT/p)==h for p,h in tools.items()),'Generation tools changed'
        receipt.update(status='generation-and-canonical-declarations-passed',formatCommand=command,
                       declarations=len(declarations(generated/config['adapter'])),sourceAcceptance=False,bytecodeCredit=False)
    except BaseException as error:
        receipt.update(status='failed-or-interrupted',error=str(error));save();raise
    receipt['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    receipt['evidenceSha256']={str(p.relative_to(output)):digest(p) for p in output.rglob('*') if p.is_file() and p.name!='manifest.json'}
    save()
    print(receipt['status'],receipt['declarations'],'declarations')

if __name__=='__main__':
    main()
