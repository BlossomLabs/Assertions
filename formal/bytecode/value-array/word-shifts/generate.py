#!/usr/bin/env python3
"""Construct exact finite canonical-width bridges from checked byte assembly."""
import argparse
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
def sum_bytes(items):
    return '+'.join(f'{1 << (8*(len(items)-1-i))}*({x} as nat)' for i, x in enumerate(items)) or '0'
def bits_bytes(items):
    return ' | '.join(f'(({x} as bv256) << {8*(len(items)-1-i)})' for i, x in enumerate(items))
def generate(out):
    out.mkdir(parents=True, exist_ok=True)
    args = [f'b[{i}]' for i in range(32)]
    value = sum_bytes(args)
    bits = bits_bytes(args)
    s = '''// SPDX-License-Identifier: MIT
// Generated constructive 32-byte fixed-width bitvector/natural correspondence.
include "../../word-apply/word-conversion/Conversion.generated.dfy"
include "../word-machine/Euclidean.dfy"
include "../byte-machine/Execution.dfy"
module BytecodeCollectionsWordByteAssembly {
  import V = BytecodeApplyWordConversion
  import G = BytecodeGetterMachine
'''
    s += f'  function Value(b: seq<bv8>): nat\n    requires |b| == 32\n  {{ {value} }}\n'
    s += f'  function Bits(b: seq<bv8>): bv256\n    requires |b| == 32\n  {{ {bits} }}\n'
    s += '''  lemma Assemble(b: seq<bv8>) returns (bits: bv256)
    requires |b| == 32
    ensures bits == Bits(b) && (bits as nat) == Value(b)
  {
'''
    previous = args
    width = 16
    while width <= 256:
        current = []
        for i in range(len(previous)//2):
            name = f'w{width}_{i}'
            hi, lo = previous[2*i:2*i+2]
            s += f'    var {name} := (({hi} as bv{width}) << {width//2}) | ({lo} as bv{width}); V.Join{width}({hi},{lo});\n'
            current.append(name)
        previous = current
        width *= 2
    s += '    bits := w256_0;\n    assert bits == Bits(b);\n  }\n'
    s += '''  lemma Bytes(bits: bv256) returns (b: seq<bv8>)
    ensures |b| == 32 && Bits(b) == bits && Value(b) == (bits as nat)
  {
    b := [''' + ','.join(f'((bits >> {8*(31-i)}) & 255) as bv8' for i in range(32)) + '''];
    var rebuilt := Assemble(b);
    assert Bits(b) == bits;
  }
}
'''
    (out/'Bytes.generated.dfy').write_text(s)
    s = '''// SPDX-License-Identifier: MIT
// Generated exact canonical-width shifts; arbitrary full-width input word.
include "Bytes.generated.dfy"
include "../word-machine/Mathematics.dfy"
module BytecodeCollectionsWordCanonicalShifts {
  import B = BytecodeCollectionsWordByteAssembly
  import V = BytecodeApplyWordConversion
  import G = BytecodeGetterMachine
  import S = BytecodeScanMachine
  import U = BytecodeCollectionsWordEuclidean
  import M = BytecodeCollectionsArrayWordMathematics
  import A = AbiEncoding
  lemma Powers()
'''
    for i in range(33):
        s += f'    ensures G.Pow256({i}) == {1<<(8*i)} && A.Pow2({8*i}) == {1<<(8*i)}\n'
    s += '    ensures A.Pow2(1) == 2\n  {\n'
    for i in range(33):
        s += f'    assert G.Pow256({i}) == {1<<(8*i)}; M.ByteBits({i});\n'
    s += '  }\n'
    for count in range(1,32):
        amount = 8*count
        remaining = 32-count
        prefix = sum_bytes(args[:remaining])
        tail = sum_bytes(args[remaining:])
        right_bytes = ['(0 as bv8)']*count + args[:remaining]
        limit = 1<<amount
        s += f'''  lemma Right{amount}(word: G.Word)
    ensures S.ShiftRight(word,{amount}) == word/{limit}
  {{
    hide S.ShiftRight();V.Nat256(word);
    var b := B.Bytes(word as bv256);
    var shifted := B.Assemble([{','.join(right_bytes)}]);
    var prefix: nat := {prefix};var tail: nat := {tail};
    assert tail < {limit} && word == prefix*{limit}+tail;
    U.RemainderUnique(word,{limit},prefix,tail);
    assert (word as bv256) >> {amount} == shifted;
    assert (shifted as nat) == prefix;
    reveal S.ShiftRight();
  }}
'''
        prefix = sum_bytes(args[:count])
        tail = sum_bytes(args[count:])
        left_bytes = args[count:] + ['(0 as bv8)']*count
        limit = 1 << (256-amount)
        factor = 1 << amount
        s += f'''  lemma Left{amount}(word: G.Word)
    ensures S.ShiftLeft(word,{amount}) == (word%{limit})*{factor}
  {{
    hide S.ShiftLeft();hide G.Shift();V.Nat256(word);
    var b := B.Bytes(word as bv256);
    var shifted := B.Assemble([{','.join(left_bytes)}]);
    var prefix: nat := {prefix};var tail: nat := {tail};
    assert tail < {limit} && word == prefix*{limit}+tail;
    U.RemainderUnique(word,{limit},prefix,tail);
    assert (word as bv256) << {amount} == shifted;
    assert (shifted as nat) == tail*{factor};
    reveal S.ShiftLeft();reveal G.Shift();
  }}
'''
    s += '''  lemma BooleanBits(bits: bv256)
    requires bits >> 1 == 0
    ensures bits == 0 || bits == 1
  {}
  lemma Boolean(word: G.Word)
    ensures S.ShiftRight(word,1) == 0 <==> word <= 1
  {
    V.Nat256(word);
    var bits := word as bv256;
    var shifted := bits >> 1;
    V.Inverse256(shifted);
    if S.ShiftRight(word,1) == 0 {
      assert shifted == 0;
      BooleanBits(bits);
      assert word == 0 || word == 1;
    }
    if word <= 1 { assert bits == 0 || bits == 1; }
  }
  lemma Unsigned(word: G.Word,bits: G.Word)
    requires 1 <= bits <= 248 && (bits == 1 || bits%8 == 0)
    ensures S.ShiftRight(word,bits) == 0 <==> word < A.Pow2(bits)
  {
    Powers();hide A.Pow2();hide G.Pow256();hide S.ShiftRight();
    if bits == 1 { Boolean(word); }
'''
    for count in range(1,32):
        s += f'    else if bits == {8*count} {{ Right{8*count}(word); }}\n'
    s += '    else { assert false; }\n  }\n'
    s += '''  lemma High(word: G.Word,bits: G.Word)
    requires 8 <= bits <= 248 && bits%8 == 0
    ensures S.ShiftLeft(word,bits) == 0 <==> word%G.Pow256(32-bits/8) == 0
  {
    Powers();hide A.Pow2();hide G.Pow256();hide S.ShiftLeft();
'''
    for count in range(1,32):
        s += ('    if' if count==1 else '    else if') + f' bits == {8*count} {{ Left{8*count}(word); }}\n'
    s += '    else { assert false; }\n  }\n'
    s += '''  lemma Index(bits: G.Word)
    requires 8 <= bits <= 248 && bits%8 == 0
    ensures S.ShiftRight(bits,3) == bits/8
  {
'''
    for count in range(1,32):
        s += ('    if' if count==1 else '    else if') + f' bits == {8*count} {{ assert S.ShiftRight(bits,3) == {count}; }}\n'
    s += '    else { assert false; }\n  }\n}\n'
    (out/'Shifts.generated.dfy').write_text(s)

if __name__ == '__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);args=parser.parse_args();generate(args.output)
    subprocess.run([sys.executable,'-B',str(HERE/'format-generated.py'),'--output',str(args.output),'--include-root',str(HERE)],check=True)
