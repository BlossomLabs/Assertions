#!/usr/bin/env python3
"""Gate the production navigation AST and translate supported kernel slots.

This restricted translator is trusted. Its complete structural gate preserves
branch/statement order, checked arithmetic, errors and raw return assembly.
Unsupported changes are rejected; selected faults are lowered to the prover.
"""
import argparse
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

if not __debug__:
    raise RuntimeError('Run without Python -O: source gates use assertions')

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
spec = importlib.util.spec_from_file_location('shape_generator', HERE.parent / 'abi/shape/generate.py')
shape = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shape)
byte_spec = importlib.util.spec_from_file_location('byte_generator', HERE.parent / 'abi/source/generate.py')
byte_generator = importlib.util.module_from_spec(byte_spec)
byte_spec.loader.exec_module(byte_generator)
FUNCTIONS = {
    'nav', '_navLength', '_navPayload', '_returnDynamic', '_checkWords',
    '_extent', '_navWord', '_navigate', '_navArrayStep', '_navTupleStep', '_normalizeIndex',
}


def normalized_form(node):
    """Discard compiler byte-location annotations, never executable fields."""
    def strip(value):
        if isinstance(value, dict):
            return {k: strip(v) for k, v in value.items() if k != 'nameLocations'}
        if isinstance(value, list):
            return [strip(v) for v in value]
        return value
    return strip(shape.form(node))


def expression(n, aliases=None):
    aliases = aliases or {}
    kind = n['nodeType']
    if kind == 'TupleExpression':
        assert not n['isInlineArray'] and len(n['components']) == 1 and n['components'][0] is not None
        return expression(n['components'][0], aliases)
    if kind == 'Identifier':
        return aliases.get(n['name'], n['name'])
    if kind == 'Literal':
        return str(int(n['value'], 0))
    if kind == 'MemberAccess':
        key = n['expression'].get('name', '') + '.' + n['memberName']
        assert key in aliases, key
        return aliases[key]
    if kind == 'UnaryOperation':
        assert n['operator'] == '-'
        return '(-' + expression(n['subExpression'], aliases) + ')'
    if kind == 'FunctionCall':
        # This slot uses uint256(-index) only after proving safe negation and a
        # nonnegative result. It must not erase arbitrary signed conversions.
        assert n['kind'] == 'typeConversion'
        assert n['expression']['typeName']['name'] == 'uint256'
        operand = n['arguments'][0]
        assert operand['nodeType'] == 'UnaryOperation' and operand['operator'] == '-'
        assert operand['subExpression'].get('name') == 'index'
        return 'magnitude'
    if kind == 'BinaryOperation':
        assert n['operator'] in ('+', '-', '*', '/', '%', '<', '>', '<=', '>=', '==', '!=', '||', '&&')
        return '(' + expression(n['leftExpression'], aliases) + ' ' + n['operator'] + ' ' + expression(n['rightExpression'], aliases) + ')'
    raise ValueError('Unsupported expression: ' + kind)


def generate(source, codec, wire, solc, bootstrap=False):
    assert '0.8.36+commit.8a079791' in subprocess.check_output([str(solc), '--version'], text=True)
    sources = {'contracts/Assertions.sol': source, 'contracts/lib/AbiCodec.sol': codec, 'contracts/lib/ERC8211.sol': wire}
    request = {'language': 'Solidity', 'sources': {n: {'content': t} for n, t in sources.items()},
               'settings': {'evmVersion': 'cancun', 'outputSelection': {'*': {'': ['ast']}}}}
    proc = subprocess.run([str(solc), '--standard-json'], input=json.dumps(request), capture_output=True, text=True, check=True)
    output = json.loads(proc.stdout)
    assert not any(e['severity'] == 'error' for e in output.get('errors', []))
    contract = next(n for n in output['sources']['contracts/Assertions.sol']['ast']['nodes']
                    if n['nodeType'] == 'ContractDefinition' and n['name'] == 'Assertions')
    functions = {n['name']: n for n in contract['nodes'] if n['nodeType'] == 'FunctionDefinition' and n['name'] in FUNCTIONS}
    assert set(functions) == FUNCTIONS
    resolutions = [n for n in shape.walk(functions['nav'])
                   if n.get('nodeType') == 'FunctionCall' and n['expression'].get('name') == '_resolve']
    assert len(resolutions) == 1
    first = functions['nav']['body']['statements'][0]
    assert first['nodeType'] == 'VariableDeclarationStatement' and first['initialValue'] == resolutions[0]
    assert [x.get('name', x.get('value')) for x in resolutions[0]['arguments']] == ['a', '', '0', '0']
    assert not resolutions[0]['tryCall']
    structure = {'functions': {name: normalized_form(n) for name, n in functions.items()},
                 'definitions': [normalized_form(n) for n in contract['nodes'] if n.get('name') in {'NavCursor', 'LEN', 'PAYLOAD', 'InvalidNavigation'}]}
    read = structure['functions']['_navWord']['body']['statements'][0]
    slots = {'WORD_GUARD': expression(read['condition'], {'result.length': '|data|'})}
    read['condition'] = {'slot': 'WORD_GUARD'}
    returns = [n for n in shape.walk(structure['functions']['_normalizeIndex'])
               if n.get('nodeType') == 'Return' and n['expression'].get('nodeType') == 'BinaryOperation']
    assert len(returns) == 1
    slots['NEGATIVE_INDEX'] = expression(returns[0]['expression'])
    returns[0]['expression'] = {'slot': 'NEGATIVE_INDEX'}
    for function_name, prefix in (('_navArrayStep', 'ARRAY'), ('_navTupleStep', 'TUPLE')):
        tree = structure['functions'][function_name]
        for n in shape.walk(tree):
            if n.get('nodeType') == 'FunctionCall' and n['expression'].get('name') == '_navWord':
                argument = n['arguments'][1]
                if argument.get('nodeType') == 'BinaryOperation':
                    key = prefix + '_HEAD'
                    assert key not in slots
                    slots[key] = expression(argument, {'dataStart': 'frame', 'c.base': 'frame'})
                    n['arguments'][1] = {'slot': key}
            if n.get('nodeType') == 'Assignment' and n['leftHandSide'].get('memberName') == 'base':
                rhs = n['rightHandSide']
                is_dynamic = any(x.get('nodeType') == 'Identifier' and x.get('name') == 'off' for x in shape.walk(rhs))
                key = 'DYNAMIC_BASE' if is_dynamic else ('STATIC_BASE' if prefix == 'ARRAY' else 'TUPLE_STATIC_BASE')
                value = expression(rhs, {'dataStart': 'frame', 'c.base': 'frame', 'elemWords': 'words'})
                if key in slots:
                    assert slots[key] == value
                slots[key] = value
                n['rightHandSide'] = {'slot': key}
    for name in ('_navLength', '_navPayload'):
        for n in shape.walk(structure['functions'][name]):
            if n.get('nodeType') != 'IfStatement':
                continue
            condition = n['condition']
            if condition.get('nodeType') != 'BinaryOperation' or condition['leftExpression'].get('name') != 'length':
                continue
            if name == '_navPayload':
                key = 'PAYLOAD_BOUND'
            elif any(x.get('name') == 'elemWords' for x in shape.walk(condition)):
                key = 'LENGTH_ARRAY_BOUND'
            else:
                key = 'LENGTH_BYTES_BOUND'
            assert key not in slots
            slots[key] = expression(condition, {'result.length': '|data|'})
            n['condition'] = {'slot': key}
    for n in shape.walk(structure['functions']['_returnDynamic']):
        if n.get('nodeType') == 'VariableDeclarationStatement' and any(d and d.get('name') == 'payloadBytes' for d in n['declarations']):
            assert 'PAYLOAD_ROUND' not in slots
            slots['PAYLOAD_ROUND'] = expression(n['initialValue'])
            n['initialValue'] = {'slot': 'PAYLOAD_ROUND'}
    if bootstrap:
        return structure
    assert structure == json.loads((HERE / 'structure.json').read_text()), 'Unsupported navigation source drift'
    digest = hashlib.sha256(source.encode()).hexdigest()
    texts = {}
    for module in ('Kernels', 'Cursor', 'Traverse', 'ModesSource', 'TerminalSource', 'ReturnMemory', 'DynamicSource', 'ValueSource', 'NavSource'):
        text = (HERE / (module + '.template.dfy')).read_text().replace('$HASH', digest)
        for name, value in slots.items():
            text = text.replace('$' + name, value)
        assert '$' not in text
        texts[module + '.generated.dfy'] = text
    masks = [n for n in shape.walk(functions['_returnDynamic']) if n.get('nodeType') == 'BinaryOperation' and n.get('operator') == '&']
    assert len(masks) == 1
    texts['mask.smt2'] = byte_generator.mask_queries(masks[0])
    mapping = {
        'maskQueries': 32,
        'resolutionBoundary': {'callCount': 1, 'firstStatement': True, 'callee': '_resolve', 'arguments': ['a', '', 0, 0], 'failurePropagation': 'direct internal call; no catch'},
        'sourceSha256': {name: hashlib.sha256(content.encode()).hexdigest() for name, content in sources.items()},
        'functions': {name: {'id': n['id'], 'src': n['src']} for name, n in functions.items()},
        'translatedSlots': slots,
        'scope': 'Index/word kernels, array/tuple cursor steps and full navigation loop. LEN/PAYLOAD cursor terminals are source-connected. Full navigation source factoring, terminal validation, rewrapping and final dispatch. Independent canonical correspondence and rejection-order theorems are inventoried by the verifier; recursive codec error offsets are propagated from the source-connected helper receipt.',
        'normalizations': [
            'Compiler nameLocations byte spans are ignored; names, types and executable AST fields remain gated.',
            'Solidity signed/unsigned casts are interpreted modulo 2^256; checked negation retains Panic(0x11).',
            'Solidity memory bytes are projected to byte sequences under the stated physical-layout assumptions.',
            'MLOAD reads a big-endian word after the source bounds guard.',
            'A full navigation AST gate is not by itself a proof of the unmodeled functions.',
        ],
    }
    return texts, mapping, request, output


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--solc', required=True)
    parser.add_argument('--source', type=Path, default=ROOT / 'contracts/Assertions.sol')
    parser.add_argument('--codec', type=Path, default=ROOT / 'contracts/lib/AbiCodec.sol')
    parser.add_argument('--wire', type=Path, default=ROOT / 'contracts/lib/ERC8211.sol')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    texts, mapping, request, output = generate(args.source.read_text(), args.codec.read_text(), args.wire.read_text(), args.solc)
    args.output.mkdir(parents=True, exist_ok=True)
    for name, text in texts.items():
        (args.output / name).write_text(text)
    (args.output / 'mapping.json').write_text(json.dumps(mapping, indent=2) + '\n')
    (args.output / 'solc-input.json').write_text(json.dumps(request))
    with gzip.open(args.output / 'solc-output.json.gz', 'wt') as stream:
        json.dump(output, stream)


if __name__ == '__main__':
    main()
