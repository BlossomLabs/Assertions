#!/usr/bin/env python3
"""Match the exact native serializer witness to both complete physical packets."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def load(p):return json.loads(p.read_text())
def integer(x):return int(x,16)
def word(x):return x.to_bytes(32,'big')
def require(ok,message):
 if not ok:raise RuntimeError(message)
def main():
 p=argparse.ArgumentParser();p.add_argument('baseline',type=Path);p.add_argument('fault',type=Path);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--report',type=Path,required=True);a=p.parse_args()
 canonical=bytes.fromhex(load(ROOT/'artifacts/contracts/Operations.sol/Operations.json')['deployedBytecode'][2:]);candidate=a.runtime.read_bytes();require(len(candidate)==len(canonical) and [i for i,(x,y) in enumerate(zip(canonical,candidate)) if x!=y]==[18907] and canonical[18907]==94 and candidate[18907]==55,'Exact one-byte MCOPY/CALLDATACOPY candidate')
 base_rows=load(a.baseline/'results.json');fault_rows=load(a.fault/'results.json');require(len(base_rows)==len(fault_rows)==405 and all(r['passed'] for r in base_rows),'405 baseline receipts')
 ordinal=5;b=load(a.baseline/base_rows[ordinal]['trace']);f=load(a.fault/fault_rows[ordinal]['trace']);require(b['ordinal']==f['ordinal']==ordinal and b['name']==f['name']=='valid1-index0','Selected witness identity')
 data=bytes.fromhex('a1bc2139')+word(64)+word(0)+word(1)+bytes([65,165,255]);before=bytes(64)+word(192)+bytes(32)+word(1)+bytes([65])+bytes(31)+word(32)+word(1);after=before+bytes([65])+bytes(31);changed=before+bytes(32)
 require(bytes.fromhex(b['data'][2:])==bytes.fromhex(f['data'][2:])==data and b['value']==f['value']=='0','Exact fitting witness calldata/value')
 pre=[2713461049,1301,128,192,0,3085,224,128,0,1,1,160,256];post=pre[:-3];bl=b['trace']['structLogs'];fl=f['trace']['structLogs'];i=next(j for j,s in enumerate(bl) if s['pc']==18907);j=next(j for j,s in enumerate(fl) if s['pc']==18907)
 require(i==j and bl[:i]==fl[:j],'Complete original/fault history matches before selected instruction')
 mem=lambda s:bytes.fromhex(''.join(x.removeprefix('0x') for x in s['memory']))
 require([integer(x) for x in bl[i]['stack']]==[integer(x) for x in fl[j]['stack']]==pre and mem(bl[i])==mem(fl[j])==before,'Whole native pre-state matches physical frontier')
 require(bl[i]['op']=='MCOPY' and fl[j]['op']=='CALLDATACOPY' and bl[i+1]['pc']==fl[j+1]['pc']==18908,'Same reached frontier')
 require([integer(x) for x in bl[i+1]['stack']]==[integer(x) for x in fl[j+1]['stack']]==post and mem(bl[i+1])==after and mem(fl[j+1])==changed,'Complete native expected post-state and faithful faulty post-state')
 expected=word(32)+word(1)+bytes([65])+bytes(31);actual=word(32)+word(1)+bytes(32)
 require(base_rows[ordinal]['actual']==expected.hex() and fault_rows[ordinal]['actual']==actual.hex() and not b['trace']['failed'] and not f['trace']['failed'],'Same native byte-preservation witness reaches two different complete ABI RETURN packets')
 wrong=[r for r in fault_rows if not r['passed']];require(len(wrong)==27 and all(r['reason']=='Success' for r in wrong),'27 complete semantic contradictions')
 report=dict(status='prepared-frontier-passed-native-pending',nativeVerified=False,publicCredit=False,runtimeSha256=hashlib.sha256(canonical).hexdigest(),candidateSha256=hashlib.sha256(candidate).hexdigest(),pc=18907,originalOpcode=94,candidateOpcode=55,witnessOrdinal=ordinal,preStack=pre,postStack=post,calldata=data.hex(),beforeMemory=before.hex(),expectedAfterMemory=after.hex(),candidateAfterMemory=changed.hex(),expectedReturn=expected.hex(),candidateReturn=actual.hex(),baselineReceipts=405,faultReceipts=405,wrongCompleteReturns=len(wrong),faultyReversions=0)
 a.report.parent.mkdir(parents=True,exist_ok=True);a.report.write_text(json.dumps(report,indent=2)+'\n');print('PASS exact native whole-state witness5/full physical packets; 27 contradictions; native pending')
if __name__=='__main__':main()
