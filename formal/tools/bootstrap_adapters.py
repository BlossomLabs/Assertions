"""Restore ignored adapter artifacts from the pinned historical save.

This is artifact bootstrap, not production AST generation or proof acceptance.
"""
import argparse
import hashlib
import json
import posixpath
import re
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
FORMAL=ROOT/'formal'

def digest(data):return hashlib.sha256(data).hexdigest()

def bootstrap(check=False,fetch=False):
    manifest=json.loads((FORMAL/'generated-adapters.json').read_text())
    commit=manifest['archiveCommit']
    assert re.fullmatch(r'[0-9a-f]{40}',commit)
    if check:
        for record in manifest['files']:
            path=ROOT/record['path']
            assert path.is_relative_to(FORMAL) and digest(path.read_bytes())==record['sha256'],record['path']
        return len(manifest['files'])
    exists=subprocess.run(['git','cat-file','-e',commit+'^{commit}'],cwd=ROOT,capture_output=True).returncode==0
    if not exists:
        if not fetch:
            raise RuntimeError('Pinned historical save is absent. Push the saved historical branch first, then rerun with --fetch.')
        subprocess.run(['git','fetch','--no-tags','origin',commit],cwd=ROOT,check=True)
    staged=[]
    for record in manifest['files']:
        relative,old=record['path'],record['archivePath']
        destination=ROOT/relative
        assert destination.is_relative_to(FORMAL) and '..' not in destination.relative_to(FORMAL).parts
        data=subprocess.check_output(['git','show',commit+':'+old],cwd=ROOT)
        assert digest(data)==record['archiveSha256'],'Historical artifact mismatch: '+old
        def include(match):
            child=posixpath.normpath(posixpath.join(posixpath.dirname(old),match[1]))
            target=manifest['pathMapping'].get(child,child.replace('formal/source/library/src/','formal/source/'))
            return 'include "'+posixpath.relpath(target,posixpath.dirname(relative))+'"'
        output=re.sub(r'^include "([^\"]+)"',include,data.decode(),flags=re.M).encode()
        assert digest(output)==record['sha256'],'Reconstructed artifact mismatch: '+relative
        if destination.exists():
            assert digest(destination.read_bytes())==record['sha256'],'Refusing to overwrite edited adapter: '+relative
        staged.append((destination,output))
    for destination,data in staged:
        if not destination.exists():
            destination.parent.mkdir(parents=True,exist_ok=True)
            destination.write_bytes(data)
    return len(staged)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check',action='store_true')
    parser.add_argument('--fetch',action='store_true',help='Fetch the pinned historical save when absent locally.')
    args=parser.parse_args()
    print('PASS:',bootstrap(args.check,args.fetch),'adapter artifacts; no proof credit granted.')

if __name__=='__main__':main()
