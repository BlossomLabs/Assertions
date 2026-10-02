// Same retained Solidity source oracle executed by Hardhat/EDR; no bytecode proof credit.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {network} from 'hardhat';
const args=Object.fromEntries(Array.from({length:(process.argv.length-2)/2},(_,i)=>[process.argv[2+2*i],process.argv[3+2*i]]));
const snap=resolve(args['--snapshot']),out=resolve(args['--output']);mkdirSync(out,{recursive:false});
const sha=x=>createHash('sha256').update(x).digest('hex'),solc=resolve('proof-tools/assertions/solc-0.8.36');
const paths=['contracts/Assertions.sol', 'contracts/lib/AbiCodec.sol', 'contracts/lib/ERC8211.sol', 'formal/constraints/ConstraintOracle.t.sol'];
const sources=Object.fromEntries(paths.map(p=>[p.replace('node_modules/',''),{content:readFileSync(resolve(snap,p),'utf8')}]))
const request={language:'Solidity',sources,settings:{evmVersion:'cancun',optimizer:{enabled:true,runs:200},outputSelection:{'*':{'*':['abi','evm.bytecode.object','evm.methodIdentifiers']}}}};
writeFileSync(resolve(out,'solc-input.json'),JSON.stringify(request));const compiledOutput=readFileSync(resolve(args['--compiled']),'utf8');writeFileSync(resolve(out,'solc-output.json'),compiledOutput);const artifact=JSON.parse(compiledOutput);if(artifact.errors?.some(e=>e.severity==='error'))throw Error(JSON.stringify(artifact.errors));
const oracle=artifact.contracts['formal/constraints/ConstraintOracle.t.sol'].ConstraintOracleTest;
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'});
const tx=await provider.request({method:'eth_sendTransaction',params:[{from:accounts[0],data:'0x'+oracle.evm.bytecode.object,gas:'0xf00000'}]});const receipt=await provider.request({method:'eth_getTransactionReceipt',params:[tx]});if(receipt.status!=='0x1')throw Error('Oracle deployment failed');
const results=[];
const methods=Object.entries(oracle.evm.methodIdentifiers).filter(([s])=>s.startsWith('test'));
for(const [signature,selector] of methods){
 const count=signature.startsWith('testFuzzScalar(')?256:1;
 for(let i=0;i<count;i++){
  let data='0x'+selector;
  if(count>1){let x=sha('constraint-x-'+i),y=sha('constraint-y-'+i);if(i%8===0)y=x;if(i%8===1)x='0'.repeat(64);if(i%8===2)x='f'.repeat(64);if(i%8===3)x='8'+'0'.repeat(63);data+=x+y+i.toString(16).padStart(64,'0')}
  let passed=true,error=null;try{await provider.request({method:'eth_call',params:[{from:accounts[0],to:receipt.contractAddress,data,gas:'0xf00000'},'latest']})}catch(e){passed=false;error=String(e)}
  results.push({signature,caseIndex:i,data,passed,error})
 }
}

await connection.close();const result={engine:'Hardhat/EDR',nodeVersion:process.version,oracle:'unchanged retained ConstraintOracle.t.sol; eight fixed tests plus 256 deterministic scalar samples, not a Foundry fuzz run',sourceSha256:Object.fromEntries(paths.map(p=>[p,sha(readFileSync(resolve(snap,p)))])),solcSha256:sha(readFileSync(solc)),tests:results};writeFileSync(resolve(out,'results.json'),JSON.stringify(result,null,2)+'\n');for(const r of results)console.log((r.passed?'[PASS] ':'[FAIL] ')+r.signature);if(methods.length!==9 || results.length!==264)throw Error('Oracle inventory differs');process.exitCode=results.every(x=>x.passed)?0:1;
