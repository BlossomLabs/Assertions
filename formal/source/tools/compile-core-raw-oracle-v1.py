import argparse,subprocess,json,hashlib
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
root=Path.cwd();solc=root/'proof-tools/assertions/solc-0.8.36';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
paths=['contracts/Assertions.sol', 'contracts/lib/AbiCodec.sol', 'contracts/lib/ERC8211.sol', 'formal/core/CoreOracle.t.sol']
request={'language':'Solidity','sources':{p.replace('node_modules/',''):{'content':(a.snapshot/p).read_text()} for p in paths},'settings':{'evmVersion':'cancun','optimizer':{'enabled':True,'runs':200},'outputSelection':{'*':{'*':['abi','evm.bytecode.object','evm.methodIdentifiers']}}}}
(a.output/'solc-input.json').write_text(json.dumps(request));proc=subprocess.run([str(solc),'--standard-json'],input=json.dumps(request),capture_output=True,text=True,timeout=120)
(a.output/'solc-output.json').write_text(proc.stdout);(a.output/'solc-stderr.log').write_text(proc.stderr)
result={'command':[str(solc),'--standard-json'],'exitCode':proc.returncode,'compilerSha256':sha(solc),'sourceSha256':{p:sha(a.snapshot/p) for p in paths},'settings':request['settings']};(a.output/'compile-receipt.json').write_text(json.dumps(result,indent=2)+'\n');assert proc.returncode==0;data=json.loads(proc.stdout);assert not any(e['severity']=='error' for e in data.get('errors',[]));print('PASS compiled unchanged oracle and production imports')
