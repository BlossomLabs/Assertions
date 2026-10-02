#!/usr/bin/env python3
"""Compose current fold selectors, wrappers and exhaustive raw decoder outcomes."""
import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def generate(out):
    artifact = json.loads((ROOT / 'artifacts/contracts/Collections.sol/Collections.json').read_text())
    digest = hashlib.sha256(bytes.fromhex(artifact['deployedBytecode'][2:])).hexdigest()
    pin = json.loads((ROOT / 'formal/bytecode/dispatch/inventory.json').read_text())['Collections']
    assert digest == pin['runtimeSha256']
    bindings = [
        ('foldRange(uint256,address,bytes,uint256,uint256[],bytes32,uint8)', 'f1d88dc8', 1055),
        ('foldBytes(bytes,address,bytes,uint256,uint256[],bytes32,uint8)', '6d24e79c', 713),
        ('foldWords(bytes,address,bytes,uint256,uint256[],bytes32,uint8)', '6de60cb0', 732),
    ]
    for signature, selector, pc in bindings:
        assert pin['methodIdentifiers'][signature] == selector
        assert pin['selectorToDeclaredEntryPc'][str(int(selector, 16))] == pc
    for mode in ['Range', 'Source']:
        range_mode = mode == 'Range'
        rm = 'true' if range_mode else 'false'
        cases = [('HeadShort', '|data| < 228')]
        if not range_mode:
            cases += [
                ('SourceOffsetLarge', 'I.SourceHead(data) >= I.U64()'),
                ('SourceHeaderShort', '(I.SourceHead(data) as nat)+36 > |data|'),
                ('SourceLengthLarge', 'I.SourceLength(data) >= I.U64()'),
                ('SourceTailShort', '(I.SourceHead(data) as nat)+36+(I.SourceLength(data) as nat) > |data|'),
            ]
        cases += [
            ('BadAddress', 'I.Target(data) >= I.AddressBound()'),
            ('TemplateOffsetLarge', 'I.TemplateHead(data) >= I.U64()'),
            ('TemplateHeaderShort', '(I.TemplateHead(data) as nat)+36 > |data|'),
            ('TemplateLengthLarge', 'I.TemplateLength(data) >= I.U64()'),
            ('TemplateTailShort', '(I.TemplateHead(data) as nat)+36+(I.TemplateLength(data) as nat) > |data|'),
            ('ArrayOffsetLarge', 'I.ArrayHead(data) >= I.U64()'),
            ('ArrayHeaderShort', '(I.ArrayHead(data) as nat)+36 > |data|'),
            ('ArrayCountLarge', 'I.Count(data) >= I.U64()'),
            ('ArrayTailShort', '(I.ArrayHead(data) as nat)+36+32*(I.Count(data) as nat) > |data|'),
            ('BadExit', 'I.Exit(data) >= 3'),
        ]
        names = [mode + name for name, _ in cases]
        assert len(names) == (11 if range_mode else 15)
        selected = [HERE.parent / 'raw-rejections' / (name + '.generated.dfy') for name in names]
        for path in selected:
            mapping = json.loads(path.with_name(path.name.removesuffix('.generated.dfy') + '.mapping.json').read_text())
            assert mapping['runtimeSha256'] == digest
        lines = ['// SPDX-License-Identifier: MIT',
                 '// Generated exhaustive compiler decoder partition and PC-zero entry composition.']
        lines += ['include "../raw-rejections/' + name + '.generated.dfy"' for name in names]
        lines.append('include "../raw-decoder/' + mode + 'Accepted.generated.dfy"')
        kinds = ['Range'] if range_mode else ['Bytes', 'Words']
        for kind in kinds:
            lines += ['include "../prefix-' + kind.lower() + '/Prefix.generated.dfy"',
                      'include "../decoder-invocation/' + kind + '.generated.dfy"']
        lines += ['module BytecodeFoldRawEntry' + mode + ' {',
                  '  import opened BytecodeScanMachine',
                  '  import G = BytecodeGetterMachine',
                  '  import E = BytecodeScanExecution',
                  '  import I = BytecodeFoldRawInputs',
                  '  import A = BytecodeFoldDecoder' + mode + 'Accepted']
        for i, name in enumerate(names):
            lines.append('  import P' + str(i) + ' = BytecodeFoldRejection' + name)
        for kind in kinds:
            lines += ['  import ' + kind + 'Prefix = BytecodeFold' + kind + 'Prefix',
                      '  import ' + kind + 'Invoke = BytecodeFoldDecodeInvoke' + kind]
        aliases = ['A'] + ['P' + str(i) for i in range(len(names))]
        routing = [kind + suffix for kind in kinds for suffix in ['Prefix', 'Invoke']]
        lines += ['  predicate LeafMatches(code: seq<Byte>) { ' + ' && '.join(alias + '.Matches(code)' for alias in aliases) + ' }',
                  '  function LeafDestinations(): set<nat> { ' + '+'.join(alias + '.Destinations()' for alias in aliases) + ' }',
                  '  predicate Rejected(data: seq<Byte>) { ' + ' || '.join('P' + str(i) + '.Admitted(data)' for i in range(len(names))) + ' }',
                  '  predicate Matches(code: seq<Byte>) { LeafMatches(code) && ' + ' && '.join(alias + '.Matches(code)' for alias in routing) + ' }',
                  '  function Destinations(): set<nat> { LeafDestinations()+' + '+'.join(alias + '.Destinations()' for alias in routing) + ' }']
        outputs = (['I.RangeCount(data)'] if range_mode else ['I.Offset(I.SourceHead(data))', 'I.SourceLength(data)']) + [
            'I.Target(data)', 'I.Offset(I.TemplateHead(data))', 'I.TemplateLength(data)', 'I.AccOffset(data)',
            'I.Offset(I.ArrayHead(data))', 'I.Count(data)', 'I.Initial(data)', 'I.Exit(data)']
        lines.append('  function Decoded(data: seq<Byte>): seq<Word> { [' + ','.join(outputs) + '] }')
        lines += ['  lemma Partition(data: seq<Byte>)',
                  '    requires 4 <= |data| < I.U64()',
                  '    ensures I.Fits(data,' + rm + ') || Rejected(data)',
                  '  {',
                  '    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight();']
        for i, (_, condition) in enumerate(cases):
            lines.append('    ' + ('if' if i == 0 else 'else if') + ' ' + condition + ' { reveal P' + str(i) + '.Admitted(); assert P' + str(i) + '.Admitted(data); }')
        lines += ['    else { assert I.Fits(data,' + rm + '); }', '  }',
                  '  lemma Disjoint(data: seq<Byte>)',
                  '    ensures !(I.Fits(data,' + rm + ') && Rejected(data))',
                  '  { hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); }',
                  '  lemma ExactPartition(data: seq<Byte>)',
                  '    requires 4 <= |data| < I.U64()',
                  '    ensures Rejected(data) == !I.Fits(data,' + rm + ')',
                  '  { Partition(data); Disjoint(data); }',
                  '  ghost method Rejection(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,value: Word) returns (state: State,trace: seq<State>)',
                  '    requires LeafMatches(code) && Rejected(data) && I.ValidReturn(returnPc,' + rm + ') && |prefix| <= 1001',
                  '    ensures state == Reverted([]) && E.Trace(code,Destinations(),value,data,trace)',
                  '    ensures |trace| > 0 && trace[0] == Running(' + ('23187' if range_mode else '22132') + ',prefix+[returnPc,|data|,4],mem) && trace[|trace|-1] == state',
                  '  {', '    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide E.Trace();']
        for i in range(len(names)):
            if i < len(names) - 1:
                lines.append('    ' + ('if' if i == 0 else 'else if') + ' P' + str(i) + '.Admitted(data) {')
            else:
                lines += ['    else {', '      assert P' + str(i) + '.Admitted(data);']
            lines += ['      state,trace := P' + str(i) + '.Run(code,data,mem,prefix,returnPc,value);',
                      '      E.WidenTrace(code,P' + str(i) + '.Destinations(),Destinations(),value,data,trace);', '    }']
        lines += ['  }',
                  '  ghost method Decode(code: seq<Byte>,data: seq<Byte>,mem: seq<Byte>,prefix: seq<Word>,returnPc: Word,value: Word) returns (state: State,trace: seq<State>)',
                  '    requires LeafMatches(code) && 4 <= |data| < I.U64() && I.ValidReturn(returnPc,' + rm + ') && |prefix| <= 1001',
                  '    ensures state == (if I.Fits(data,' + rm + ') then Running(returnPc,prefix+Decoded(data),mem) else Reverted([]))',
                  '    ensures E.Trace(code,Destinations(),value,data,trace) && |trace| > 0',
                  '    ensures trace[0] == Running(' + ('23187' if range_mode else '22132') + ',prefix+[returnPc,|data|,4],mem) && trace[|trace|-1] == state',
                  '  {', '    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide E.Trace();',
                  '    if I.Fits(data,' + rm + ') {', '      reveal A.Admitted(); assert A.Admitted(data);',
                  '      state,trace := A.Run(code,data,mem,prefix,returnPc,value);',
                  '      E.WidenTrace(code,A.Destinations(),Destinations(),value,data,trace);',
                  '    } else { Partition(data); state,trace := Rejection(code,data,mem,prefix,returnPc,value); }', '  }']
        for kind in kinds:
            selector = {'Range': 4057501128, 'Bytes': 1831135132, 'Words': 1843793072}[kind]
            return_pc = {'Range': 1069, 'Bytes': 727, 'Words': 746}[kind]
            lines += ['  ghost method Run' + kind + '(code: seq<Byte>,data: seq<Byte>) returns (state: State,trace: seq<State>)',
                      '    requires Matches(code) && ' + kind + 'Prefix.Admitted(0,data)',
                      '    ensures state == (if I.Fits(data,' + rm + ') then Running(' + str(return_pc) + ',[' + str(selector) + ',604]+Decoded(data),Store([],64,128)) else Reverted([]))',
                      '    ensures E.Trace(code,Destinations(),0,data,trace) && |trace| > 0',
                      '    ensures trace[0] == Running(0,[],[]) && trace[|trace|-1] == state',
                      '  {', '    hide G.BitAnd(); hide BitNot(); hide DataWord(); hide ShiftRight(); hide E.Trace();',
                      '    var part: seq<State>;',
                      '    state,trace := ' + kind + 'Prefix.Run(code,0,data);',
                      '    E.WidenTrace(code,' + kind + 'Prefix.Destinations(),Destinations(),0,data,trace);',
                      '    state,part := ' + kind + 'Invoke.Run(code,data,Store([],64,128),[' + str(selector) + '],0);',
                      '    E.WidenTrace(code,' + kind + 'Invoke.Destinations(),Destinations(),0,data,part);',
                      '    assert trace[|trace|-1] == part[0]; E.Join(code,Destinations(),0,data,trace,part); trace := trace+part[1..];',
                      '    state,part := Decode(code,data,Store([],64,128),[' + str(selector) + ',604],' + str(return_pc) + ',0);',
                      '    assert trace[|trace|-1] == part[0]; E.Join(code,Destinations(),0,data,trace,part); trace := trace+part[1..];',
                      '  }']
        lines.append('}')
        (out / (mode + '.generated.dfy')).write_text('\n'.join(lines) + '\n')
        (out / (mode + '.mapping.json')).write_text(json.dumps({
            'runtimeSha256': digest, 'kind': 'composition-not-instruction-extraction',
            'orderedCases': [{'owner': name, 'firstInvalidCondition': condition} for name, (_, condition) in zip(names, cases)],
            'acceptedOwner': 'BytecodeFoldDecoder' + mode + 'Accepted',
            'decodedOutputs': outputs, 'entries': [row for row in bindings if (row[0].startswith('foldRange') == range_mode)],
        }, indent=2) + '\n')
    subprocess.run([sys.executable, '-B', HERE / 'format-generated.py', '--output', out, '--include-root', HERE], check=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    generate(args.output)
