"""Receipt primitives shared by execution and independent review."""
import csv
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POLICY = ['--verify-included-files', '--manual-lemma-induction',
          '--isolate-assertions', '--cores', '2', '--verification-time-limit', '30']
STATUSES = {'pending', 'implemented-unverified', 'verified', 'failed-incomplete'}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write(path, data):
    path.write_text(json.dumps(data, indent=2) + '\n')


def theorem_contract(path, entrypoint):
    text = re.sub(r'/\*.*?\*/|//[^\n]*', '', path.read_text(), flags=re.S)
    name = entrypoint.rsplit('.', 1)[1]
    matches = list(re.finditer(r'\blemma\s+(?:\{:[^}]*\}\s*)*' + re.escape(name) + r'\s*\(', text))
    assert len(matches) == 1, 'Missing or ambiguous public-entry lemma'
    header = text[matches[0].start():text.index('{', matches[0].end())]
    return hashlib.sha256(re.sub(r'\s+', '', header).encode()).hexdigest()


def closure(root, entries):
    found = set()

    def visit(path):
        # Preserve logical dependency paths when installations are symlinks.
        path = Path(os.path.normpath(path))
        assert path.is_relative_to(root), 'Include outside proof root: ' + str(path)
        if path in found:
            return
        found.add(path)
        for include in re.findall(r'^\s*include\s+"([^"\n]+)"', path.read_text(), re.M):
            visit(path.parent / include)

    for entry in entries:
        visit(root / entry)
    return sorted(found)


def tools(dafny):
    z3 = dafny.parent / 'z3/bin/z3-4.12.1'
    assert subprocess.check_output([str(dafny), '--version'], text=True).strip().split('+')[0] == '4.11.0'
    assert subprocess.check_output([str(z3), '-version'], text=True).startswith('Z3 version 4.12.1')
    lock = json.loads((ROOT / 'formal/dependencies/dafnyevm/tools.json').read_text())
    paths = {'dafny/dafny': dafny, 'dafny/Dafny.dll': dafny.parent / 'Dafny.dll',
             'dafny/z3/bin/z3-4.12.1': z3}
    assert all(sha(p) == lock['installed'][name] for name, p in paths.items()), 'Modified proof tools'
    return z3, {name: sha(p) for name, p in paths.items()}


def audit_sources(sources):
    for path in sources:
        text = re.sub(r'/\*.*?\*/|//[^\n]*', '', path.read_text(), flags=re.S)
        assert not re.search(r'\bassume\b|\{:\s*(?:axiom|verify\s+false)', text), 'Admission in ' + str(path)


def partitions(root, sources):
    """Cover the complete closure while keeping large generated facts separate."""
    result = []
    for path in sources:
        relative = str(path.relative_to(root))
        if relative == 'formal/.generated/OperationsRuntime.dfy':
            for name in ['Byte', 'Chunk', 'Node', 'Code.', 'Window']:
                result.append(['--filter-symbol', 'OperationsRuntime.' + name])
        elif relative == 'formal/.generated/OperationsCodeFacts.dfy':
            result.append(['--filter-symbol', 'OperationsCodeFacts.Window'])
            for name in re.findall(r'^\s*lemma (Destination\d+|JumpDestinations)\(', path.read_text(), re.M):
                result.append(['--filter-symbol', 'OperationsCodeFacts.' + name + '.'])
        else:
            text = re.sub(r'/\*.*?\*/|//[^\n]*', '', path.read_text(), flags=re.S)
            modules = re.findall(r'\bmodule\s+(\w+)\s*\{', text)
            lemmas = re.findall(r'\blemma\s+(?:\{:[^}]*\}\s*)*(\w+)\s*\(', text)
            other = re.search(r'\b(?:function|predicate|const|datatype|type|method)\b', text)
            if relative.startswith('formal/') and len(modules) == 1 and lemmas and not other:
                result.extend(['--filter-symbol', modules[0] + '.' + name + '.'] for name in lemmas)
            else:
                result.append(['--filter-position', relative])
    return result


def native_result(log, csv_path, entrypoints):
    rows = []
    if csv_path.is_file():
        with csv_path.open() as source:
            rows = list(csv.DictReader(source))
    summary = re.search(r'finished with (\d+) verified, (\d+) errors', log)
    passed = bool(rows) and all(r['TestResult.Outcome'] == 'Passed' for r in rows)
    passed &= bool(summary) and int(summary[1]) == len(rows) and int(summary[2]) == 0
    passed &= not bool(re.search(r'time.?out|inconclusive|Error:', log, re.I))
    names = [r['TestResult.DisplayName'] for r in rows]
    coverage = {name: any(r.startswith(name + ' (correctness)') for r in names)
                for name in entrypoints}
    return bool(passed and all(coverage.values())), rows, coverage


def partition_result(log, csv_path):
    rows = []
    if csv_path.is_file():
        with csv_path.open() as source:
            rows = list(csv.DictReader(source))
    summary = re.search(r'finished with (\d+) verified, (\d+) errors', log)
    passed = bool(summary) and int(summary[1]) == len(rows) and int(summary[2]) == 0
    passed &= all(r['TestResult.Outcome'] == 'Passed' for r in rows)
    passed &= not bool(re.search(r'time.?out|inconclusive|Error:', log, re.I))
    return bool(passed and csv_path.is_file()), rows


def entry_coverage(rows, entrypoints):
    return {name: any(r['TestResult.DisplayName'].startswith(name + ' (correctness)') for r in rows)
            for name in entrypoints}


def select(catalog, signatures):
    by_id = {f['id']: f for f in catalog['functions']}
    ids = signatures or [f['id'] for f in catalog['functions'] if f['theorems']]
    assert ids and len(ids) == len(set(ids)), 'Empty or duplicate selection'
    assert all(i in by_id for i in ids), 'Unknown public signature'
    selected = [by_id[i] for i in ids]
    assert all(f['theorems'] for f in selected), 'Selected signature has no implemented theorem'
    return selected
