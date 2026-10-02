#!/usr/bin/env python3
"""Run detecting source-fault controls only in a temporary source snapshot."""
import argparse,json,os,re,shutil,subprocess,tempfile,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main():
 p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 sources=['contracts/'+n+'.sol' for n in ['Assertions','Operations','Collections','Expressions']]+['contracts/lib/AbiCodec.sol','contracts/lib/ERC8211.sol']
 tests=['contracts/tests/'+n for n in ['ClaimCoverageEasy.t.sol','ClaimCoverageModerate.t.sol','ClaimCoverageOracle.t.sol','ClaimCoverageSort.t.sol','ClaimEvidenceGaps.t.sol','BiconomyERC8211Runtime.sol']]
 with tempfile.TemporaryDirectory(prefix='assertions-coverage-negative-') as directory:
  snap=Path(directory)
  for path in sources+tests:
   target=snap/path;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(ROOT/path,target)
  shutil.copy2(ROOT/'foundry.toml',snap/'foundry.toml');(snap/'node_modules').symlink_to(ROOT/'node_modules',target_is_directory=True)
  commands=[];results=[]
  snapshot_hashes={path:hashlib.sha256((snap/path).read_bytes()).hexdigest() for path in sources+tests+['foundry.toml']}
  def run(name,contract,test=None):
   command=['forge','test','--root',str(snap),'--match-contract',contract,'-vv']
   if test:command+=['--match-test',test]
   process=subprocess.run(command,capture_output=True,text=True);log=process.stdout+process.stderr;(a.output/(name+'.log')).write_text(log);commands.append({'name':name,'command':command,'exitCode':process.returncode});return process.returncode,log
  code,log=run('baseline','ClaimCoverage(Easy|Moderate|Oracle|Sort)Test')
  if code!=0 or '34 tests passed, 0 failed' not in log:raise RuntimeError('Scratch baseline must pass all 34 tests')
  cases=[
   ('C8-wrong-index','contracts/Assertions.sol','revert InvalidAddressWord(index, word);','revert InvalidAddressWord(0, word);','ClaimCoverageEasyTest','test_C8_DirtyTargetNamesNonzeroIndex'),
   ('O64-noncanonical-plus','contracts/Operations.sol','return string.concat(value < 0 ? "-" : "", toString(_magnitude(value)));','return string.concat(value < 0 ? "-" : "+", toString(_magnitude(value)));','ClaimCoverageOracleTest','test_O64_O68_IndependentPythonCanonicalFormatVectors'),
   ('O26-quantized-coefficient','contracts/Operations.sol','3822833074963236453042738258902158003155416615667','3822833074963236453042738258902158003155416616667','ClaimCoverageOracleTest','test_O26_GeneratedFiniteWordKernelAndExactErrors'),
   ('O59-tail-mask','contracts/Operations.sol','x := shr(drop, x)','x := x','ClaimCoverageModerateTest','test_O59_WordAndMaskedTailBoundariesAgainstByteOracle'),
  ]
  for name,path,before,after,contract,test in cases:
   original=(ROOT/path).read_text();assert original.count(before)==1;target=snap/path;target.write_text(original.replace(before,after,1))
   code,log=run(name,contract,test);detected=code!=0 and bool(re.search(r'^\[FAIL:.*\] '+re.escape(test)+r'\(',log,re.M)) and 'Compiler run successful' in log
   results.append({'name':name,'claim':name.split('-')[0],'status':'detected' if detected else 'failed-negative-control','test':test,'mutation':{'file':path,'before':before,'after':after}});print(name,results[-1]['status'],flush=True)
   target.write_text(original)
   if not detected:raise RuntimeError('Mutation must compile and fail intended assertion: '+name)
  (a.output/'results.json').write_text(json.dumps({'baseline':'34 tests passed','sourceSha256':snapshot_hashes,'forgeVersion':subprocess.check_output(['forge','--version'],text=True).strip(),'results':results,'commands':commands},indent=2)+'\n')
if __name__=='__main__':main()
