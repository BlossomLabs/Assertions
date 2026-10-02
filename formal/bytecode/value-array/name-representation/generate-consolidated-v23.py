#!/usr/bin/env python3
"""Constructive exact five/six-byte top-word shifts through checked small joins."""
import argparse,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
def generate(out):
 out.mkdir(parents=True,exist_ok=True)
 for name,size in [('Five',5),('Six',6)]:
  shift=64-8*size;div=1<<shift
  s=f'// SPDX-License-Identifier: MIT\n// Generated exact top {size}-byte bridge; all bodies require whole native proof.\ninclude "../../word-apply/word-conversion/Conversion.generated.dfy"\nmodule BytecodeCollectionsNameShift{name} {{\n  import V = BytecodeApplyWordConversion\n'
  for width in [16,32,64,128,256]:
   half=width//2;s+=f'  lemma Extend{width}(bits: bv{half})\n    ensures ((bits as bv{width}) as int) == (bits as int)\n  {{\n    assert (bits as bv{width}) == (((0 as bv{half}) as bv{width}) << {half}) | (bits as bv{width});\n    V.Join{width}(0,bits);\n  }}\n'
  args=','.join(f'b{i}: bv8' for i in range(8)); vals=','.join(f'b{i}' for i in range(8)); nargs=','.join(f'n{i}: nat' for i in range(8))
  full=' | '.join(f'((b{i} as bv64) << {8*(7-i)})' for i in range(8))
  prefix_bits=' | '.join(f'((b{i} as bv64) << {8*(size-1-i)})' for i in range(size))
  fullval='+'.join(f'{1<<(8*(7-i))}*(b{i} as int)' for i in range(8))
  prefix='+'.join(f'{1<<(8*(size-1-i))}*(b{i} as int)' for i in range(size))
  nfull='+'.join(f'{1<<(8*(7-i))}*n{i}' for i in range(8))
  nprefix='+'.join(f'{1<<(8*(size-1-i))}*n{i}' for i in range(size))
  ntail='+'.join(f'{1<<(8*(7-i))}*n{i}' for i in range(size,8))
  s+=f'  function Packed64({args}): bv64 {{ {full} }}\n  function Prefix64({args}): bv64 {{ {prefix_bits} }}\n'
  if size==5:
   s+=f'  lemma OrRight(a: bv64,b: bv64)\n    ensures (a|b) >> {shift} == (a >> {shift}) | (b >> {shift})\n  {{}}\n'
   for i in range(8):
    lhs=f'((b as bv64) << {8*(7-i)}) >> {shift}';rhs=f'(b as bv64) << {8*(size-1-i)}' if i<size else '(0 as bv64)'
    s+=f'  lemma ShiftByte{i}(b: bv8)\n    ensures {lhs} == {rhs}\n  {{}}\n'
  s+=f'  lemma PrefixBits64({args})\n    ensures Packed64({vals}) >> {shift} == Prefix64({vals})\n  {{\n'
  if size==5:
   terms=[f'((b{i} as bv64) << {8*(7-i)})' for i in range(8)]
   for i in range(1,8):s+=f'    OrRight('+ '|'.join(terms[:i])+','+terms[i]+');\n'
   for i in range(8):s+=f'    ShiftByte{i}(b{i});\n'
  s+='  }\n'
  s+=f'  lemma PrefixValue64({args})\n    ensures (Prefix64({vals}) as int) == {prefix}\n  {{\n'
  if size==5:
   s+='    var high := b0 as bv32; Extend16(b0); Extend32(b0 as bv16);\n    var first := ((b1 as bv16) << 8) | (b2 as bv16); V.Join16(b1,b2);\n    var second := ((b3 as bv16) << 8) | (b4 as bv16); V.Join16(b3,b4);\n'
  else:
   s+='    var head := ((b0 as bv16) << 8) | (b1 as bv16); V.Join16(b0,b1);\n    var high := head as bv32; Extend32(head);\n    var first := ((b2 as bv16) << 8) | (b3 as bv16); V.Join16(b2,b3);\n    var second := ((b4 as bv16) << 8) | (b5 as bv16); V.Join16(b4,b5);\n'
  s+='    var low := ((first as bv32) << 16) | (second as bv32); V.Join32(first,second);\n'
  s+=f'    assert Prefix64({vals}) == ((high as bv64) << 32) | (low as bv64); V.Join64(high,low);\n  }}\n'
  s+=f'  lemma QuotientValue64({nargs})\n    requires '+ ' && '.join(f'n{i} < 256' for i in range(8))+f'\n    ensures ({nfull})/{div} == {nprefix}\n  {{\n    var prefix := {nprefix};var tail := {ntail};\n    assert tail < {div};\n    assert {nfull} == prefix*{div}+tail;\n    assert (prefix*{div}+tail)/{div} == prefix;\n  }}\n'
  s+='  lemma Bytes(bits: bv64) returns ('+args+')\n'
  s+=f'    ensures (bits as int) == {fullval}\n    ensures bits == Packed64({vals})\n  {{\n'
  for i in range(8):s+=f'    b{i} := ((bits >> {8*(7-i)}) & 255) as bv8;\n'
  for i in range(4):s+=f'    var a{i} := ((b{2*i} as bv16) << 8) | (b{2*i+1} as bv16); V.Join16(b{2*i},b{2*i+1});\n'
  s+='    var high := ((a0 as bv32) << 16) | (a1 as bv32); V.Join32(a0,a1);\n    var low := ((a2 as bv32) << 16) | (a3 as bv32); V.Join32(a2,a3);\n    assert bits == ((high as bv64) << 32) | (low as bv64); V.Join64(high,low);\n'
  s+=f'    assert bits == Packed64({vals});\n  }}\n'
  s+=f'  lemma Top64(bits: bv64)\n    ensures ((bits >> {shift}) as int) == (bits as int)/{div}\n  {{\n    hide Packed64();hide Prefix64();\n    var {vals} := Bytes(bits);\n    PrefixBits64({vals});PrefixValue64({vals});\n    QuotientValue64('+','.join(f'b{i} as nat' for i in range(8))+');\n  }\n'
  for width in [128,256]:
   half=width//2;factor=1<<half;amount=width-8*size;small=1<<(half-8*size);divisor=1<<amount
   s+=f'  lemma Halves{width}(bits: bv{width}) returns (hi: bv{half},lo: bv{half})\n    ensures (bits as int) == {factor}*(hi as int)+(lo as int)\n    ensures bits >> {amount} == ((hi >> {half-8*size}) as bv{width})\n  {{\n    hi := (bits >> {half}) as bv{half}; lo := (bits & {factor-1}) as bv{half};\n    assert bits == ((hi as bv{width}) << {half}) | (lo as bv{width}); V.Join{width}(hi,lo);\n  }}\n'
   s+=f'  lemma Divide{width}(n: int,hi: int,lo: int)\n    requires n == {factor}*hi+lo && 0 <= hi && 0 <= lo < {factor}\n    ensures n/{divisor} == hi/{small}\n  {{\n    assert n/{factor} == hi;\n    assert (n/{factor})/{small} == n/{divisor};\n  }}\n'
   s+=f'  lemma Top{width}(bits: bv{width})\n    ensures ((bits >> {amount}) as int) == (bits as int)/{divisor}\n  {{\n    var hi,lo := Halves{width}(bits); Extend{width}(hi >> {half-8*size}); Top{half}(hi); Divide{width}(bits as int,hi as int,lo as int);\n  }}\n'
  s+=f'  lemma Natural256(n: int)\n    requires 0 <= n < {1<<256}\n    ensures (((n as bv256) >> {256-8*size}) as nat) == n/{1<<(256-8*size)}\n  {{ V.Nat256(n); Top256(n as bv256); }}\n}}\n'
  (out/(name+'.generated.dfy')).write_text(s)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();generate(a.output)
 subprocess.run([sys.executable,'-B',str(HERE/'format-generated-consolidated-v23.py'),'--output',str(a.output),'--include-root',str(HERE)],check=True)
