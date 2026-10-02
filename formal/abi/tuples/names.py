#!/usr/bin/env python3
"""Map the existing 96-name SMT whitelist into Dafny model constructors."""
import ast
from pathlib import Path
HERE=Path(__file__).resolve().parent

def render():
    source=(HERE.parent/'words/generate.py').read_text()
    fn=next(n for n in ast.parse(source).body if isinstance(n,ast.FunctionDef) and n.name=='rules')
    ns={'range':range}
    exec(compile(ast.Module(body=[fn],type_ignores=[]),'word-whitelist','exec'),ns)
    entries=ns['rules']()
    assert len(entries)==len(set(x[0] for x in entries))==96
    lines=['// SPDX-License-Identifier: MIT','// Generated from the separately SMT-verified 96-name whitelist.',
           'include "Words.dfy"','','module AbiTupleNames {','  import opened AbiFrames','  import opened AbiEncoding',
           '  import opened AbiWordSemantics','','  opaque function Rule(name: seq<Byte>): WordRule','  {']
    for name,kind,bits in entries:
        rule={'address':'Address','bool':'Boolean','function':'Function'}.get(name)
        if rule is None:rule=f'Unsigned({bits})' if kind==1 else f'Signed({bits})' if kind==2 else f'HighBytes({bits//8})'
        chars='['+','.join(map(str,name.encode()))+']'
        lines.append(f'    if name == {chars} then {rule} else')
    lines += ['    Opaque','  }','','  lemma RuleClassified(name: seq<Byte>)',
              '    ensures ClassifiedRule(Rule(name))','  { reveal Rule(); }','}']
    return '\n'.join(lines)+'\n',entries
if __name__=='__main__':
    (HERE/'Names.generated.dfy').write_text(render()[0])
