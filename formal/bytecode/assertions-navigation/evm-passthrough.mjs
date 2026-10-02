// Concrete complete public nav calls exercising the actual normalized-index helper.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
import {encodeAbiParameters,encodeFunctionData,encodeErrorResult} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const baseline=artifact.deployedBytecode;
const runtime=process.argv[3]?JSON.parse(readFileSync(process.argv[3])).runtime:baseline;
if(process.argv[3]) {
 const before=Buffer.from(baseline.slice(2),'hex'),after=Buffer.from(runtime.slice(2),'hex');
 const changed=Array.from(before.keys()).filter(i=>before[i]!==after[i]);
 if(before.length!==after.length||changed.length!==1||changed[0]!==1100||before[1100]!==0xf3||after[1100]!==0xfd)throw Error('Unexpected candidate mutation');
}
const digest=createHash('sha256').update(Buffer.from(runtime.slice(2),'hex')).digest('hex');
const frozen=JSON.parse(readFileSync('formal/bytecode/dispatch/inventory.json'));
if(!process.argv[3]&&digest!==frozen.Assertions.runtimeSha256)throw Error('Assertions runtime drift');
const sha=bytes=>createHash('sha256').update(bytes).digest('hex');
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'});
const target='0x0000000000000000000000000000000000003702';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const results=[];
for(const length of [0,1,31,32,33,257]) {
 const payload='0x'+Array.from({length},(_,i)=>(i%256).toString(16).padStart(2,'0')).join('');
 const data=encodeFunctionData({abi:artifact.abi,functionName:'nav',args:[{paramType:0,fetcherType:0,paramData:payload,constraints:[]},'invalid descriptor ignored',[]]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const actual='0x'+trace.returnValue.replace(/^0x/,'');
 const file='case-'+length+'.json';
 writeFileSync(resolve(out,file),JSON.stringify({length,payload,actual,runtimeSha256:digest,data,trace},null,2)+'\n');
 if(trace.failed||actual!==payload)throw Error('Wrong nav passthrough receipt '+length);
 results.push({length,expected:payload,actual,trace:file,passed:true});
}
await connection.close();
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log('PASS: '+results.length+' complete public nav passthrough receipts on exact Assertions runtime');
