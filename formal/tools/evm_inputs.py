"""Complete producer inputs shared by the adoption run and independent review."""
from check import ROOT, LIBRARY
from evm_dependency import LOCK


def producer_paths():
    paths = list((LIBRARY/'tools').glob('*.py'))
    paths += list((LIBRARY/'tools').glob('*.mjs'))
    paths += [LOCK, LOCK.parent/'generic.patch', LOCK.parent/'crypto.patch',
              LOCK.parent/'tools.json', LOCK.parent/'requirements.lock',
              LIBRARY/'migrations/dafnyevm.json',
              LIBRARY/'bytecode/dafnyevm/runtime-binding.json',
              LIBRARY/'bytecode/dafnyevm/public-resolve.json',
              LIBRARY/'claims.json', ROOT/'docs/claim-evidence.json']
    return sorted(paths)
