#!/usr/bin/env python3
"""Run the fourteen actual source oracle fixtures with the retained campaign configuration.

Diagnostic concrete check only: no Dafny run, retained snapshot or public credit.
"""
import argparse,datetime,importlib.util,json,re,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--output',type=Path,required=True);a=parser.parse_args()
 spec=importlib.util.spec_from_file_location('fold_source_campaign_preflight',HERE/'verify.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
 scope=json.loads((HERE/'proof-spec.json').read_text());files=[p for p in v.inputs(scope)if p.suffix=='.sol' or p==ROOT/'node_modules/@openzeppelin/contracts/package.json']
 fixtures=[ROOT/'formal/collections/word-fold-entry/WordFoldEntryOracle.t.sol',ROOT/'formal/collections/word-fold-loop/WordFoldLoopOracle.t.sol'];expected=[name for p in fixtures for name in re.findall(r'function (test\w+)\(',p.read_text())];assert len(expected)==len(set(expected))==14
 out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);work=out/'diagnostic-project';hashes={str(p.relative_to(ROOT)):v.sha(p)for p in files}
 for p in files:
  destination=work/p.relative_to(ROOT);destination.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,destination)
 solc=Path('/home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791');forge=Path(shutil.which('forge')).resolve();tools={'forge':forge,'solc':solc};tool_hashes={k:v.sha(p)for k,p in tools.items()}
 config=v.source_campaign_config(solc);(work/'foundry.toml').write_text(config)
 command=[str(forge),'test','--root',str(work),'--match-contract','^(WordFoldEntryOracleTest|WordFoldLoopOracleTest)$','-vv']
 with (out/'forge.log').open('w')as log:
  process=subprocess.Popen(command,stdout=log,stderr=subprocess.STDOUT);code=process.wait()
 body=(out/'forge.log').read_text();actual=re.findall(r'^\[PASS\] (test\w+)\(',body,re.M);unchanged=all(v.sha(ROOT/k)==h and v.sha(work/k)==h for k,h in hashes.items());same_tools=tool_hashes=={k:v.sha(p)for k,p in tools.items()};passed=code==0 and sorted(actual)==sorted(expected)and unchanged and same_tools
 shutil.rmtree(work/'out',ignore_errors=True);shutil.rmtree(work/'cache',ignore_errors=True)
 record=dict(status='source-baseline-physical-preflight-passed-not-retained'if passed else 'source-baseline-physical-preflight-failed',completedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),command=command,exitCode=code,sourceSha256=hashes,expectedTests=expected,actualPassedTests=actual,currentAndDiagnosticSourcesUnchanged=unchanged,toolSha256=tool_hashes,toolsUnchanged=same_tools,derivedConfig=config,scope='Fourteen actual source fixture outcomes only using complete captured Solidity imports and retained diagnostic compiler configuration. No native proof, retained bytecode or public credit.')
 record['evidenceSha256']={str(p.relative_to(out)):v.sha(p)for p in out.rglob('*')if p.is_file()and p.name!='results.json'};(out/'results.json').write_text(json.dumps(record,indent=2)+'\n');print(record['status'],len(actual),'actual passed tests',flush=True);raise SystemExit(0 if passed else 1)
if __name__=='__main__':main()
