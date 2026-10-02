#!/usr/bin/env python3
"""Generate checked radix-four constant unfolding; never native credit by generation."""
import argparse
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
lines=['// SPDX-License-Identifier: MIT','// Generated checked constant unfolding. Never edit directly.','include "Seed.dfy"','module OperationsSquareRootLimits {','  import S = OperationsSquareRootSeed','  import F = OperationsSquareRootMath','  lemma WordLimit()','    ensures S.Power4(128)==F.Modulus','    ensures S.Power2(127)==F.Limit/2','  {']
lines += ['    assert S.Power4('+str(i)+')=='+str(4**i)+';' for i in range(129)]
lines += ['    assert S.Power2('+str(i)+')=='+str(2**i)+';' for i in range(128)]
lines += ['  }','  lemma Fitting(n: F.Word)','    requires n>0','    ensures S.Class(n)<128','    ensures S.Initial(n)<=F.Limit/2','  {','    WordLimit(); S.Bounds(n);','    if S.Class(n)>=128 { S.Monotone(128,S.Class(n)); }','    S.Power2Monotone(S.Class(n),127);','  }','}']
(a.output/'Limits.generated.dfy').write_text('\n'.join(lines)+'\n')
