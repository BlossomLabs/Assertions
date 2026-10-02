#!/usr/bin/env python3
"""Make valid exact-runtime branch mutations without changing live artifacts."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def main(out):
    out.mkdir(parents=True,exist_ok=False)
    data=json.loads((ROOT/'artifacts/contracts/Assertions.sol/Assertions.json').read_text());baseline=bytes.fromhex(data['deployedBytecode'][2:]);inventory=json.loads((HERE/'inventory.json').read_text())['Assertions']
    assert hashlib.sha256(baseline).hexdigest()==inventory['runtimeSha256']
    selector=int(inventory['methodIdentifiers']['LEN()'],16);first=inventory['selectorToDeclaredEntryPc'][str(selector)];second=inventory['selectorToDeclaredEntryPc'][str(int(inventory['methodIdentifiers']['PAYLOAD()'],16))]
    marker=b'\x63'+selector.to_bytes(4,'big')+b'\x14\x61'+first.to_bytes(2,'big')+b'\x57';assert baseline.count(marker)==1
    pos=baseline.index(marker)+7
    assert baseline[first]==baseline[second]==0x5b
    replacements=[{'name':'getter-entry-redirect','offset':pos,'original':first,'replacement':second,'nativeScope':'LEN selector must reach its frozen declared entry; expected table remains baseline, never regenerated from candidate.', 'concreteScope':'Exact candidate runtime trace reaches PAYLOAD entry instead of LEN; returned getter bytes also differ.'},
      {'name':'short-frame-admission-bypass','offset':9,'original':15,'replacement':first,'nativeScope':'Zero call value with short calldata must reject; changing the global value-check branch admits the LEN entry before the size check.', 'concreteScope':'Exact candidate runtime accepts empty calldata and returns LEN instead of empty rejection.'}]
    assert baseline[8]==0x61 and baseline[9:11]==b'\x00\x0f' and baseline[11]==0x57
    for fault in replacements:
        candidate=bytearray(baseline);position=fault['offset'];assert int.from_bytes(candidate[position:position+2],'big')==fault['original'];candidate[position:position+2]=fault['replacement'].to_bytes(2,'big')
        (out/(fault['name']+'.bin')).write_bytes(candidate);fault['runtimeSha256']=hashlib.sha256(candidate).hexdigest()
    (out/'inventory.json').write_text(json.dumps(replacements,indent=2)+'\n');print('Generated two valid PUSH2 destination mutations; no detection claimed')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();main(a.output)
