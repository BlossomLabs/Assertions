"""Omit a single production dispatch check for semantic mutation testing."""
import hashlib
BASE = 'dc53eb78d3550ded3d9dce3f61172a9a16e103a6be33cea95b1de04701c7124d'

def apply(source, omit=None):
    if hashlib.sha256(source.encode()).hexdigest() != BASE:
        raise ValueError('Production source drift')
    if omit is None: return source
    line = {'call':'        _checkPublicCall(target, data);\n', 'probe':'        _checkPublicCall(target, callData);\n'}[omit]
    if source.count(line) != 1: raise ValueError('Dispatch check drift')
    return source.replace(line, '')
