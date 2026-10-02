#!/usr/bin/env python3
"""Generate connection of all seven checked physical seed branches to radix-four mathematics."""
import argparse
from pathlib import Path
HERE=Path(__file__).resolve().parent
STAGES=[(64,11130,11151),(32,11151,11178),(16,11178,11201),(8,11201,11222),(4,11222,11242),(2,11242,11261),(1,11261,11273)]
def generate(out):
 out.mkdir(parents=True,exist_ok=True)
 text='// SPDX-License-Identifier: MIT\n// Generated checked threshold constants; never edit directly.\ninclude "Core.dfy"\nmodule OperationsSquareRootSeedConnectionConstants {\n  import S = OperationsSquareRootSeed\n  lemma Known()\n'
 for width,_,_ in STAGES:text+=f'    ensures S.Power4({width})=={1<<(2*width)}\n'
 text+='  {\n'
 for exponent in range(65):text+=f'    assert S.Power4({exponent})=={4**exponent};\n'
 text+='  }\n}\n';(out/'Constants.generated.dfy').write_text(text)
 text='// SPDX-License-Identifier: MIT\n// Generated seven-stage compiled seed/mathematical connection; never edit directly.\ninclude "Constants.generated.dfy"\n'
 for width,_,_ in STAGES:
  for kind in ['Taken','Skip']:text+=f'include "../sqrt-seed-controls/Seed{width}{kind}.generated.dfy"\n'
 text+='module OperationsSquareRootSeedConnection {\n  import M = OperationsBytecodeLog2Machine\n  import E = OperationsSquareRootExecution\n  import S = OperationsSquareRootSeed\n  import L = OperationsSquareRootLimits\n  import Q = OperationsSquareRootSeedScan\n  import C = OperationsSquareRootSeedConnectionCore\n  import K = OperationsSquareRootSeedConnectionConstants\n'
 for width,_,_ in STAGES:
  for kind in ['Taken','Skip']:text+=f'  import R{width}{kind} = OperationsSquareRootSeed{width}{kind}\n'
 text+='  predicate Matches(code: seq<M.Byte>) {\n    '+' &&\n    '.join(f'R{w}{kind}.Matches(code)' for w,_,_ in STAGES for kind in ['Taken','Skip'])+'\n  }\n'
 text+='''  method Run(code: seq<M.Byte>,destinations: set<nat>,initial: M.State,n: M.Word,prefix: seq<M.Word>,mem: seq<M.Byte>,value: M.Word,size: M.Word,word: M.Word,a: M.Word)
    returns(state: M.State,trace: seq<M.State>,physicalAA: M.Word,seed: M.Word)
    requires n>=2 && |prefix|<=1000 && Matches(code)
    requires {11151,11178,11201,11222,11242,11261,11273}<=destinations
    requires initial==M.Running(11130,prefix+[n,1],mem)
    ensures state==M.Running(11273,prefix+[physicalAA,seed],mem) && 1<=physicalAA<16
    ensures seed==S.Initial(n) && seed*seed<=n<4*seed*seed
    ensures C.Trace(code,destinations,trace,value,size,word,a) && trace[0]==initial && trace[|trace|-1]==state
  {
    K.Known();L.WordLimit();
    var aa:M.Word:=n;var k:nat:=0;seed:=1;state:=initial;trace:=[state];physicalAA:=n;
    assert aa==n/S.Power4(k) && 1<=aa<S.Power4(128) && seed==S.Power2(k);
'''
 for width,start,end in STAGES:
  text+='    {\n      var oldAA:=aa;var oldSeed:=seed;var oldK:=k;\n'
  text+=f'      aa,seed,k:=C.Reduce(n,oldAA,oldSeed,oldK,{width});\n      var steps:seq<M.State>;\n      if oldAA>=S.Power4({width}) {{\n'
  text+=f'        assert R{width}Taken.Good(0,state,oldAA,oldSeed,prefix,mem);\n        state,steps:=R{width}Taken.Run(code,destinations,state,oldAA,oldSeed,prefix,mem,value,size,word,a);\n      }} else {{\n'
  text+=f'        assert R{width}Skip.Good(0,state,oldAA,oldSeed,prefix,mem);\n        state,steps:=R{width}Skip.Run(code,destinations,state,oldAA,oldSeed,prefix,mem,value,size,word,a);\n      }}\n'
  if width==1:text+='      physicalAA:=oldAA;\n'
  text+=f'      assert state==M.Running({end},prefix+[{"physicalAA" if width==1 else "aa"},seed],mem);\n      assert C.Trace(code,destinations,steps,value,size,word,a);\n      C.Append(code,destinations,trace,steps,value,size,word,a);trace:=trace+steps[1..];\n    }}\n'
 text+='''    Q.DecodedBounds(n,S.Power4(k),aa);Q.ClassUnique(n,k);S.Powers(k);S.Bounds(n);
  }
}
''';(out/'Connection.generated.dfy').write_text(text)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);generate(p.parse_args().output)
