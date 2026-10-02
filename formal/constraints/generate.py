#!/usr/bin/env python3
"""Restricted, trusted AST-to-Dafny translation for the constraint engine."""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
spec = importlib.util.spec_from_file_location('navigation_generator', HERE.parent / 'navigation/generate.py')
nav = importlib.util.module_from_spec(spec)
spec.loader.exec_module(nav)


def expression(n):
    kind = n['nodeType']
    if kind == 'Identifier':
        if n['name'] not in {'actual', 'lower', 'upper', 'bound', 'signed', 'words', 'length'}:
            raise ValueError(n)
        return n['name']
    if kind == 'FunctionCall' and n['kind'] == 'typeConversion':
        name = n['expression']['typeName']['name']
        if name == 'int256':
            return 'Signed(' + expression(n['arguments'][0]) + ')'
        if name == 'uint256':
            return expression(n['arguments'][0])
    if kind == 'BinaryOperation' and n['operator'] in {'>', '<', '>=', '<=', '==', '!=', '&&', '||'}:
        return '(' + expression(n['leftExpression']) + ' ' + n['operator'] + ' ' + expression(n['rightExpression']) + ')'
    raise ValueError(n)


def generate(solc, root, output, bootstrap=False):
    sources = {p: (root / p).read_text() for p in ['contracts/Assertions.sol', 'contracts/lib/AbiCodec.sol', 'contracts/lib/ERC8211.sol']}
    request = {'language': 'Solidity', 'sources': {p: {'content': s} for p, s in sources.items()},
               'settings': {'evmVersion': 'cancun', 'outputSelection': {'*': {'': ['ast']}}}}
    version = subprocess.check_output([str(solc), '--version'], text=True)
    if '0.8.36+commit.8a079791' not in version:
        raise ValueError('Wrong solc version')
    result = subprocess.run([str(solc), '--standard-json'], input=json.dumps(request), capture_output=True, text=True, check=True)
    ast = json.loads(result.stdout)
    if any(e['severity'] == 'error' for e in ast.get('errors', [])):
        raise ValueError(ast['errors'])
    contract = next(n for n in ast['sources']['contracts/Assertions.sol']['ast']['nodes'] if n.get('name') == 'Assertions')
    functions = {n['name']: nav.normalized_form(n) for n in contract['nodes'] if n.get('name') in {'_checkConstraint', '_validateConstraints'}}
    if len(functions) != 2:
        raise ValueError('Missing functions')
    slots = {}
    check = functions['_checkConstraint']['body']['statements']
    # Slots are actual AST expressions, with a full structural gate around them.
    range_body = check[3]['trueBody']['statements']
    signed_body = range_body[2]['trueBody']['statements']
    locations = [('SIGNED_RANGE', signed_body[0], 'condition'), ('SIGNED_IN', signed_body[2], 'expression'),
                 ('UNSIGNED_RANGE', range_body[3], 'condition'), ('UNSIGNED_IN', range_body[4], 'expression')]
    for key, statement in zip(['EQ', 'GTE', 'LTE', 'GTE_SIGNED'], check[6:10]):
        locations.append((key, statement['trueBody'], 'expression'))
    locations.append(('LTE_SIGNED', check[10], 'expression'))
    locations.append(('BOUNDS', functions['_validateConstraints']['body']['statements'][3], 'condition'))
    for key, node, field in locations:
        slots[key] = expression(node[field])
        node[field] = {'slot': key}
    wire = [nav.normalized_form(n) for n in ast['sources']['contracts/lib/ERC8211.sol']['ast']['nodes']
            if n.get('name') in {'Constraint', 'ConstraintType', 'ConstraintFailed', 'InvalidConstraintData', 'InvalidConstraintRange', 'InvalidOrConstraint', 'ReturnDataOutOfBounds'}]
    structure = {'functions': functions, 'wire': wire}
    if bootstrap:
        (HERE / 'structure.json').write_text(json.dumps(structure, indent=2) + '\n')
        return
    if structure != json.loads((HERE / 'structure.json').read_text()):
        raise ValueError('Unsupported constraint source drift')
    text = (HERE / 'Engine.template.dfy').read_text().replace('$HASH', hashlib.sha256(sources['contracts/Assertions.sol'].encode()).hexdigest())
    for key in sorted(slots, key=len, reverse=True):
        text = text.replace('$' + key, slots[key])
    if '$' in text:
        raise ValueError('Unexpanded slot')
    output.mkdir(parents=True, exist_ok=True)
    (output / 'Engine.generated.dfy').write_text(text)
    (output / 'solc-input.json').write_text(json.dumps(request))
    (output / 'solc-output.json.gz').write_bytes(gzip.compress(result.stdout.encode(), mtime=0))
    (output / 'mapping.json').write_text(json.dumps({'translatedSlots': slots, 'sourceSha256': {p: hashlib.sha256(s.encode()).hexdigest() for p, s in sources.items()}}, indent=2) + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--solc', required=True, type=Path)
    parser.add_argument('--root', type=Path, default=ROOT)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--bootstrap', action='store_true')
    args = parser.parse_args()
    generate(args.solc, args.root, args.output, args.bootstrap)
