"""Restore pinned generic DafnyEVM sources and checksummed tools; no proof credit."""
import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import urllib.request
import zipfile
from pathlib import Path
from check import ROOT, LIBRARY, digest
from evm_dependency import DEPENDENCY, LOCK, external_sources


def fetch(url, destination, expected):
    request = urllib.request.Request(url,headers={'User-Agent':'Assertions-formal-bootstrap'})
    with urllib.request.urlopen(request) as response, destination.open('wb') as stream:
        shutil.copyfileobj(response,stream)
    assert digest(destination) == expected, 'Downloaded artifact checksum mismatch'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fetch',action='store_true')
    args = parser.parse_args()
    lock = json.loads(LOCK.read_text())
    for name, key in [('generic.patch','patchSha256'),('crypto.patch','cryptoPatchSha256'),('requirements.lock','requirementsSha256'),('tools.json','toolsSha256')]:
        assert digest(LOCK.parent/name) == lock[key], 'Dependency input drift: '+name
    tools = ROOT/'proof-tools'
    tools.mkdir(exist_ok=True)
    if not DEPENDENCY.exists():
        assert args.fetch, 'Missing DafnyEVM; bootstrap with --fetch'
        with tempfile.TemporaryDirectory(prefix='dafnyevm-bootstrap-',dir=tools) as temporary:
            staged = Path(temporary)/'checkout'
            subprocess.run(['git','clone','--filter=blob:none','--no-checkout',lock['upstreamUrl'],str(staged)],check=True)
            subprocess.run(['git','-C',str(staged),'sparse-checkout','set','src','libs','gradle','.github'],check=True)
            subprocess.run(['git','-C',str(staged),'checkout','--detach',lock['upstream']],check=True)
            subprocess.run(['git','-C',str(staged),'apply','--binary',str(LOCK.parent/'generic.patch')],check=True)
            crypto = staged/'libs/DafnyCrypto'
            subprocess.run(['git','clone',lock['cryptoUrl'],str(crypto)],check=True)
            subprocess.run(['git','-C',str(crypto),'checkout','--detach',lock['crypto']],check=True)
            subprocess.run(['git','-C',str(crypto),'apply',str(LOCK.parent/'crypto.patch')],check=True)
            for relative, expected in lock['installationSources'].items():
                suffix = (ROOT/relative).relative_to(DEPENDENCY)
                assert digest(staged/suffix) == expected, 'Restored semantics mismatch'
            staged.rename(DEPENDENCY)
    external_sources()  # Refuse modified source installs; never reset a checkout.
    config = json.loads((LOCK.parent/'tools.json').read_text())
    home = tools/'assertions'
    home.mkdir(exist_ok=True)
    if not (home/'dafny/dafny').exists():
        assert args.fetch, 'Missing Dafny; bootstrap with --fetch'
        with tempfile.TemporaryDirectory(dir=tools) as temporary:
            archive = Path(temporary)/'dafny.zip'
            fetch(config['dafnyUrl'],archive,config['dafnySha256'])
            with zipfile.ZipFile(archive) as zipped:
                for info in zipped.infolist():
                    target = (Path(temporary)/info.filename).resolve()
                    assert target.is_relative_to(Path(temporary).resolve()), 'Archive path escape'
                    zipped.extract(info,temporary)
                    mode = info.external_attr >> 16
                    if mode:
                        target.chmod(mode & 0o777)
            (Path(temporary)/'dafny').rename(home/'dafny')
    solc = home/'solc-0.8.36'
    if not solc.exists():
        assert args.fetch, 'Missing solc; bootstrap with --fetch'
        with tempfile.TemporaryDirectory(dir=tools) as temporary:
            staged = Path(temporary)/'solc'
            fetch(config['solcUrl'],staged,config['solcSha256'])
            staged.chmod(0o755)
            staged.rename(solc)
    for relative, expected in config['installed'].items():
        assert digest(home/relative) == expected, 'Installed tool drift: '+relative
    vendor = tools/'evm-python'
    if not vendor.exists():
        assert args.fetch, 'Missing Python reference EVM; bootstrap with --fetch'
        with tempfile.TemporaryDirectory(prefix='evm-python-',dir=tools) as temporary:
            staged = Path(temporary)/'vendor'
            subprocess.run([sys.executable,'-m','pip','install','--require-hashes','--only-binary=:all:',
                            '--target',str(staged),'-r',str(LOCK.parent/'requirements.lock')],check=True)
            files = {str(p.relative_to(staged)):digest(p) for p in staged.rglob('*')
                     if p.is_file() and '__pycache__' not in p.parts and p.suffix!='.pyc'}
            (staged/'installation.json').write_text(json.dumps({'requirementsSha256':lock['requirementsSha256'],'files':files},indent=2)+'\n')
            staged.rename(vendor)
    validate_python(vendor,lock['requirementsSha256'])
    print('PASS pinned generic dependency and tools; no proof credit granted.')


def validate_python(vendor, expected):
    stamp = json.loads((vendor/'installation.json').read_text())
    assert stamp['requirementsSha256'] == expected, 'Python dependency lock drift'
    files = {str(p.relative_to(vendor)):digest(p) for p in vendor.rglob('*')
             if p.is_file() and '__pycache__' not in p.parts and p.suffix!='.pyc' and p.name!='installation.json'}
    assert files == stamp['files'], 'Modified Python dependency install'
    import importlib.metadata
    import re
    normalize = lambda name: name.lower().replace('_','-')
    expected_versions = {normalize(m[1]):m[2] for m in re.finditer(r'(?m)^([\w-]+)==([^\s]+)',(LOCK.parent/'requirements.lock').read_text())}
    versions = {normalize(d.metadata['Name']):d.version for d in importlib.metadata.distributions(path=[str(vendor)])}
    assert versions == expected_versions, 'Python package version or inventory drift'
    return files


if __name__ == '__main__':
    main()
