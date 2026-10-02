#!/usr/bin/env python3
"""Derive a context-isolated signed-range certificate from the frozen leaf map."""
import argparse
import importlib.util
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]


def generate(out):
    spec = importlib.util.spec_from_file_location('original_leaf_generator', HERE.parents[1] / 'generate.py')
    original = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(original)
    with tempfile.TemporaryDirectory(prefix='assertions-signed-leaf-') as folder:
        temp = Path(folder)
        original.generate(temp)
        case = (temp / 'Kind8BadRange.generated.dfy').read_text()
        case = re.sub(r'^include "([^"]+)"', lambda m: 'include "../../' + m[1] + '"', case, flags=re.M)
        case = case.replace('include "../../Scalar.dfy"', 'include "../../Scalar.dfy"\ninclude "PhysicalRange.dfy"')
        case = case.replace('  import B = AssertionsConstraintErrorMemory', '  import B = AssertionsConstraintErrorMemory\n  import X = AssertionsConstraintPhysicalRange')
        case = case.replace('  lemma Advance29(', '  lemma {:isolate_assertions} Advance29(')
        start = case.index('  lemma {:isolate_assertions} Advance164(')
        end = case.index('  lemma Start(', start)
        body = case[start:end]
        body = body[:body.index('\n  {')] + '''
  {
    reveal Matches(); reveal Good();
    assert ((((100 as nat)+(free as nat))%G.Modulus() as nat)+G.Modulus()-(free as nat))%G.Modulus() == 100;
    assert state == S.Running(1431,prefix+[ret,actual,constraint,entry,param,index,0,8,length,lower,higher,100,free],B.RangeWithSelector(mem,free,0x295a41c5,entry,param,index));
    assert prefix+[ret,actual,constraint,entry,param,index,0,8,length,lower,higher,100,free] ==
      (prefix+[ret,actual,constraint,entry,param,index,0,8,length,lower,higher])+[100,free];
    X.Step(code,Destinations(ret),prefix+[ret,actual,constraint,entry,param,index,0,8,length,lower,higher],mem,free,entry,param,index,value,data);
    assert P.Error(P.BadRange,entry,param,index,length) == G.Encode(0x295a41c5,4)+G.Encode(entry,32)+G.Encode(param,32)+G.Encode(index,32);
  }
'''
        case = case[:start] + body + case[end:]
        connection = (temp / 'Connection.generated.dfy').read_text()
        connection = re.sub(r'^include "([^"]+)"', lambda m: 'include "' +
                            (m[1] if m[1] == 'Kind8BadRange.generated.dfy' else '../../' + m[1]) + '"', connection, flags=re.M)
        out.mkdir(parents=True, exist_ok=True)
        (out / 'Kind8BadRange.generated.dfy').write_text(case)
        (out / 'Connection.generated.dfy').write_text(connection)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--dafny', type=Path)
    args = parser.parse_args()
    generate(args.output)
    if args.dafny:
        subprocess.run([sys.executable, '-B', ROOT / 'formal/bytecode/format-generated.py', '--output', args.output,
                        '--include-root', HERE], env=dict(os.environ, DAFNY=str(args.dafny.resolve())), check=True)
