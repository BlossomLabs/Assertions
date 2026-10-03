"""Install the published interpreter revision atomically; refuse installation drift."""
import argparse, hashlib, json, os, shutil, tempfile, types, urllib.request, zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
DEPS=ROOT/'formal/dependencies/dafnyevm'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()

def validate(root,lock):
    sources=lock['installationSources']|lock['cryptoSources']|lock['effectiveSources']
    actual={str(p.relative_to(root)) for p in root.rglob('*') if p.is_file()}
    assert actual==set(sources), 'Incomplete or modified installation inventory'
    for path,expected in sources.items():
        assert (root/path).is_file() and sha(root/path)==expected, 'Modified installation: '+path

def extract(url,destination):
    archive=destination.parent/(destination.name+'.zip')
    with urllib.request.urlopen(url) as response, archive.open('wb') as output:
        shutil.copyfileobj(response,output)
    with zipfile.ZipFile(archive) as zip:
        for entry in zip.infolist():
            path=Path(entry.filename)
            assert not path.is_absolute() and '..' not in path.parts
        zip.extractall(destination)
    archive.unlink()
    roots=list(destination.iterdir())
    assert len(roots)==1 and roots[0].is_dir()
    return roots[0]

def install_solc(destination,fetch):
    lock=json.loads((DEPS/'tools.json').read_text())
    if destination.exists():
        assert sha(destination)==lock['solcSha256'], 'Modified Solidity compiler'
        return destination
    assert fetch, 'Missing compiler: run bootstrap --fetch'
    destination.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(dir=destination.parent,prefix='.solc-stage-') as temp:
        source=Path(temp)/'solc'
        with urllib.request.urlopen(lock['solcUrl']) as response, source.open('wb') as output:
            shutil.copyfileobj(response,output)
        assert sha(source)==lock['solcSha256'], 'Solidity compiler download hash mismatch'
        source.chmod(0o755);os.rename(source,destination)
    return destination

def bootstrap(fetch=False,destination=None,tools=None,solc=None):
    lock=json.loads((DEPS/'lock.json').read_text())
    destination=destination or ROOT/'proof-tools/dafnyevm'
    if destination.exists():
        validate(destination,lock)
    else:
        assert fetch, 'Missing interpreter: run bootstrap --fetch'
        destination.parent.mkdir(parents=True,exist_ok=True)
        with tempfile.TemporaryDirectory(dir=destination.parent,prefix='.dafnyevm-stage-') as temp:
            stage=Path(temp)
            source=extract(f"https://github.com/BlossomLabs/evm-dafny/archive/{lock['revision']}.zip",stage/'fork')
            crypto=extract(f"https://github.com/Consensys/DafnyCrypto/archive/{lock['cryptoRevision']}.zip",stage/'crypto')
            target=source/'libs/DafnyCrypto';target.mkdir(parents=True,exist_ok=True)
            shutil.copytree(crypto,target,dirs_exist_ok=True)
            validate(source,lock)
            os.rename(source,destination)
    source=destination/'tools/bootstrap.py'
    module=types.ModuleType('fork_bootstrap');module.__file__=str(source)
    exec(compile(source.read_bytes(),str(source),'exec'),module.__dict__)
    tools=tools or ROOT/'proof-tools/dafny'
    if tools.exists() or fetch:
        module.install_dafny(tools)
    else: raise AssertionError('Missing tools: run bootstrap --fetch')
    install_solc(solc or ROOT/'proof-tools/solc-0.8.36',fetch)
    return destination

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--fetch',action='store_true')
    p.add_argument('--destination',type=Path);p.add_argument('--tools',type=Path)
    p.add_argument('--solc',type=Path)
    a=p.parse_args();print(bootstrap(a.fetch,a.destination,a.tools,a.solc))
