// Complete public witnesses for scanName; finite receipts supplement native proofs.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
import {encodeAbiParameters,encodeFunctionData,encodeErrorResult} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const baseline=artifact.deployedBytecode,runtime=process.argv[3]?JSON.parse(readFileSync(process.argv[3])).runtime:baseline;
const bytes=Buffer.from(runtime.slice(2),'hex'),base=Buffer.from(baseline.slice(2),'hex');
if(process.argv[3]){
 const changes=Array.from(base.keys()).filter(i=>base[i]!==bytes[i]);
 if(bytes.length!==base.length||changes.length!==1||changes[0]!==12553||base[12553]!==17||bytes[12553]!==16)throw Error('Unexpected scanner mutation');
}
const sha=b=>createHash('sha256').update(b).digest('hex'),digest=sha(bytes);
if(!process.argv[3]&&digest!==JSON.parse(readFileSync('formal/bytecode/dispatch/inventory.json')).Assertions.runtimeSha256)throw Error('Runtime drift');
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntrySha256:sha(readFileSync(hh)),edrEntrySha256:sha(readFileSync(edr)),nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003705';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const payload=encodeAbiParameters([{type:'uint256'}],[1n]);
const cases=[...['a','z','0','9','uint256','abc0123456789xyz','a'.repeat(257)].map(name=>({descriptor:`(${name})`,error:null})),{descriptor:'(A)',error:1},{descriptor:'(a_)',error:2},{descriptor:'()',error:1}];
const results=[];
for(let i=0;i<cases.length;i++){
 const {descriptor,error}=cases[i];
 const data=encodeFunctionData({abi:artifact.abi,functionName:'nav',args:[{paramType:0,fetcherType:0,paramData:payload,constraints:[]},descriptor,[0n]]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const expected=error===null?payload:encodeErrorResult({abi:artifact.abi,errorName:'InvalidTypeDescriptor',args:[BigInt(error)]});
 const actual='0x'+trace.returnValue.replace(/^0x/,'');const file=`case-${i}.json`;
 writeFileSync(resolve(out,file),JSON.stringify({runtimeSha256:digest,descriptor,data,expected,actual,trace},null,2)+'\n');
 if(Boolean(trace.failed)!==(error!==null)||actual!==expected||!trace.structLogs.some(r=>r.pc===12520&&r.depth===1))throw Error('Name receipt mismatch '+descriptor);
 results.push({descriptor,expected,actual,trace:file,passed:true});
}
await connection.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log(`PASS: ${results.length} complete public descriptor-name receipts`);
