"""Pinned foreign semantics, closed imports and qualified declaration inventory."""
import json
import re
from pathlib import Path
from check import ROOT, LIBRARY, digest
from declarations import body

DEPENDENCY = ROOT / 'proof-tools/dafnyevm'
LOCK = LIBRARY / 'dependencies/dafnyevm/lock.json'


def includes(path):
    return re.findall(r'^\s*include\s+"([^"]+)"', path.read_text(), re.M)


def closure(entries, boundary=ROOT):
    result = {}
    pending = list(entries)
    while pending:
        path = Path(pending.pop()).resolve()
        relative = str(path.relative_to(boundary.resolve()))
        if relative in result:
            continue
        assert path.is_file(), 'Missing closure input: ' + relative
        result[relative] = digest(path)
        pending.extend(path.parent / include for include in includes(path))
    return dict(sorted(result.items()))


def external_sources():
    if not LOCK.exists():
        return {}
    lock = json.loads(LOCK.read_text())
    assert digest(LOCK.parent / 'generic.patch') == lock['patchSha256'], 'DafnyEVM patch drift'
    for name,key in [('crypto.patch','cryptoPatchSha256'),('requirements.lock','requirementsSha256'),('tools.json','toolsSha256')]:
        assert digest(LOCK.parent/name) == lock[key], 'Dependency input drift: '+name
    assert set(lock['sources']) <= set(lock['installationSources']), 'Incomplete semantics install binding'
    for relative, expected in lock['installationSources'].items():
        path = ROOT / relative
        assert path.is_file() and digest(path) == expected, 'DafnyEVM source drift: ' + relative
    expected = closure([ROOT / p for p in lock['verificationEntries']])
    assert expected == lock['sources'], 'Incomplete DafnyEVM closure binding'
    for relative in expected:
        masked = body.mask_literals_and_comments((ROOT / relative).read_text())
        assert not re.search(r'\bassume\b|\{:axiom\b|\{:verify\s+false\b', masked), 'Admitted semantics: ' + relative
    return expected


def qualified_inventory(path):
    """Read namespace/declaration boundaries, independent of upstream indentation.

    Dafny resolve checks syntax; this reader only supports the pinned source
    layout. Anonymous blocks never become namespaces. Datatype members retain
    their enclosing type, matching Dafny's native result names.
    """
    masked = body.mask_literals_and_comments(path.read_text())
    token = re.compile(r'\{:[^}]*\}|\b(module|datatype|class|trait|function|predicate|lemma|method|const|type|newtype)\b\s*(?:\{:[^}]*\}\s*)*(\w+)|[=|]\s*(\w+)\s*\(|[{}]')
    depth = 0
    namespaces = []
    pending = None
    result = {}
    modules = 0
    for match in token.finditer(masked):
        value = match[0]
        if value.startswith('{:'):
            continue
        if match[3]:
            if pending is not None and pending[2] == 'datatype':
                name = '#'+'.'.join(n[0] for n in namespaces)+'.'+pending[0]+'.'+match[3]
                result[name] = 'constructor'
            continue
        if value == '{':
            depth += 1
            if pending is not None and pending[1] == depth - 1:
                namespaces.append((pending[0], depth))
            pending = None
        elif value == '}':
            if namespaces and namespaces[-1][1] == depth:
                namespaces.pop()
            depth -= 1
            assert depth >= 0, 'Unbalanced foreign source'
            pending = None
        else:
            kind, name = match[1], match[2]
            modules += kind == 'module'
            pending = None
            if namespaces and depth == namespaces[-1][1]:
                full = '.'.join(n[0] for n in namespaces) + '.' + name
                assert full not in result, 'Duplicate foreign declaration: ' + full
                result[full] = kind
            if kind in ('module', 'datatype', 'class', 'trait'):
                pending = (name, depth, kind)
    assert depth == 0 and modules, 'Unsupported foreign inventory: ' + str(path)
    return result


def file_inventory(path, external):
    relative = str(path.relative_to(ROOT))
    if relative in external:
        return qualified_inventory(path)
    from declarations import declarations
    module = re.search(r'^module (\w+)', path.read_text(), re.M)[1]
    return {module + '.' + name: d['kind'] for name, d in declarations(path).items()}
