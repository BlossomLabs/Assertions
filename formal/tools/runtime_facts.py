"""Generate proof obligations for runtime windows and PUSH-aware jump boundaries.

Generated facts grant no credit until their entire Dafny closure verifies.
"""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]

def facts_source(code):
    out=['include "OperationsRuntime.dfy"',
         'include "../../proof-tools/dafnyevm/src/dafny/boundaries.dfy"',
         'module OperationsCodeFacts {','  import Code','  import OperationsRuntime',
         '  import InstructionBoundaries']
    for base in range(0,len(code),256):
        n=base//256;end=min(base+256,len(code))
        out += [f'  lemma Window{n:03d}(c: Code.T)',
                '    requires c.contents == OperationsRuntime.Code()',
                f'    ensures c.contents[{base}..{end}] == OperationsRuntime.Chunk{n:03d}()',
                f'    ensures forall i | {base} <= i < {end} :: c.contents[i] == OperationsRuntime.Chunk{n:03d}()[i-{base}]',
                f'  {{ OperationsRuntime.Window{n:03d}(); }}']
    targets=[15,655,2984,3085,1329,1301,2108,2122,5974,18650,18667,20232,20125,2455,2469,20855,20886,353,445,7531]
    def scan(start,target):
        n=0
        while start<target:
            op=code[start];start+=1+(op-95 if 96<=op<=127 else 0);n+=1
        return n+1 if start==target else None
    for target in targets:
        low=0 if target<33 else next(k for k in range(target-33,-1,-1) if all(scan(s,target) for s in range(k,k+33)))
        starts=[0] if target<33 else list(range(low,low+33))
        cursors=set()
        for start in starts:
            cursor=start
            while cursor<target:
                cursors.add(cursor);op=code[cursor];cursor+=1+(op-95 if 96<=op<=127 else 0)
        windows=list(range(low//256,target//256+1))
        out += [f'  lemma Destination{target}(c: Code.T)',
                '    requires c.contents == OperationsRuntime.Code()',
                f'    ensures Code.IsInstructionStart(c,0,{target}) && c.contents[{target}] == 0x5b','  {']
        for window in windows:
            out.append(f'    Window{window:03d}(c); reveal OperationsRuntime.Chunk{window:03d}();')
        out.append(f'    assert Code.IsInstructionStart(c,{target},{target}) by {{ reveal Code.IsInstructionStart(); }}')
        for cursor in sorted(cursors,reverse=True):
            out.append(f'    assert c.contents[{cursor}] == {code[cursor]};')
            out.append(f'    InstructionBoundaries.Predecessor(c,{cursor},{target});')
        if target>=33:
            out += [f'    forall start | {low} <= start <= {low+32}',
                    f'      ensures Code.IsInstructionStart(c,start,{target})','    {']
            for start in starts:out.append(f'      if start == {start} {{}}')
            out += ['    }',f'    InstructionBoundaries.Synchronize(c,0,{low},{target});']
        out.append('  }')
    out += ['  lemma JumpDestinations(c: Code.T)', '    requires c.contents == OperationsRuntime.Code()']
    for target in targets:out.append(f'    ensures Code.IsInstructionStart(c,0,{target}) && c.contents[{target}] == 0x5b')
    out += ['  {']
    for target in targets:out.append(f'    Destination{target}(c);')
    out += ['  }','}']
    return '\n'.join(out)+'\n'

def generate():
    code=bytes.fromhex((ROOT/'formal/.generated/Operations.runtime.hex').read_text())
    (ROOT/'formal/.generated/OperationsCodeFacts.dfy').write_text(facts_source(code))

if __name__=='__main__':generate()
