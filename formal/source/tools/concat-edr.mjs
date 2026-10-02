// Same retained Solidity source oracle executed by Hardhat/EDR; no bytecode proof credit.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {network} from 'hardhat';
const args=Object.fromEntries(Array.from({length:(process.argv.length-2)/2},(_,i)=>[process.argv[2+2*i],process.argv[3+2*i]]));
const snap=resolve(args['--snapshot']),out=resolve(args['--output']);mkdirSync(out,{recursive:false});
const sha=x=>createHash('sha256').update(x).digest('hex'),solc=resolve('proof-tools/assertions/solc-0.8.36');
const paths=['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol','formal/operations/concat/ConcatOracle.t.sol'];
const sources=Object.fromEntries(paths.map(p=>[p.replace('node_modules/',''),{content:readFileSync(resolve(snap,p),'utf8')}]))
const request={language:'Solidity',sources,settings:{evmVersion:'cancun',optimizer:{enabled:true,runs:200},outputSelection:{'*':{'*':['abi','evm.bytecode.object','evm.methodIdentifiers']}}}};
writeFileSync(resolve(out,'solc-input.json'),JSON.stringify(request));const compiled=spawnSync(solc,['--standard-json'],{input:JSON.stringify(request),encoding:'utf8',maxBuffer:20*1024*1024});if(compiled.status!==0)throw Error(compiled.stderr);writeFileSync(resolve(out,'solc-output.json'),compiled.stdout);const artifact=JSON.parse(compiled.stdout);if(artifact.errors?.some(e=>e.severity==='error'))throw Error(JSON.stringify(artifact.errors));
const oracle=artifact.contracts['formal/operations/concat/ConcatOracle.t.sol'].OperationsConcatOracleTest;
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'});
const tx=await provider.request({method:'eth_sendTransaction',params:[{from:accounts[0],data:'0x'+oracle.evm.bytecode.object,gas:'0xf00000'}]});const receipt=await provider.request({method:'eth_getTransactionReceipt',params:[tx]});if(receipt.status!=='0x1')throw Error('Oracle deployment failed');
const results=[];for(const [signature,selector] of Object.entries(oracle.evm.methodIdentifiers).filter(([s])=>s.startsWith('test'))){let passed=true,error=null;try{await provider.request({method:'eth_call',params:[{from:accounts[0],to:receipt.contractAddress,data:'0x'+selector,gas:'0xf00000'},'latest']})}catch(e){passed=false;error=String(e)}results.push({signature,passed,error})}
await connection.close();const result={engine:'Hardhat/EDR',nodeVersion:process.version,oracle:'unchanged retained ConcatOracle.t.sol',sourceSha256:Object.fromEntries(paths.map(p=>[p,sha(readFileSync(resolve(snap,p)))])),solcSha256:sha(readFileSync(solc)),tests:results};writeFileSync(resolve(out,'results.json'),JSON.stringify(result,null,2)+'\n');for(const r of results)console.log((r.passed?'[PASS] ':'[FAIL] ')+r.signature);if(results.length!==2)throw Error('Oracle inventory differs');process.exitCode=results.every(x=>x.passed)?0:1;
