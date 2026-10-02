// Physical suffixStart witnesses. Finite receipts do not prove its unbounded loop.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeAbiParameters,encodeFunctionData} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const baseline=artifact.deployedBytecode;
const runtime=process.argv[3]?JSON.parse(readFileSync(process.argv[3])).runtime:baseline;
if(process.argv[3]) {
 const before=Buffer.from(baseline.slice(2),'hex'),after=Buffer.from(runtime.slice(2),'hex');
 const changed=Array.from(before.keys()).filter(i=>before[i]!==after[i]);
 if(before.length!==after.length||changed.length!==1||changed[0]!==8288||before[8288]!==0x10||after[8288]!==0x11)throw Error('Unexpected suffix mutation');
}
const digest=createHash('sha256').update(Buffer.from(runtime.slice(2),'hex')).digest('hex');
if(!process.argv[3]&&digest!==JSON.parse(readFileSync('formal/bytecode/dispatch/inventory.json')).Assertions.runtimeSha256)throw Error('Runtime drift');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003704';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const results=[];
for(const count of [1,12,123]){
 const values=Array.from({length:count},(_,i)=>BigInt(i+1));
 const payload=encodeAbiParameters([{type:`uint256[${count}]`}],[values]);
 const descriptor=`(uint256[${count}])`;
 const data=encodeFunctionData({abi:artifact.abi,functionName:'nav',args:[{paramType:0,fetcherType:0,paramData:payload,constraints:[]},descriptor,[0n,0n]]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,gas:'0x989680',data},'latest',{enableMemory:false,disableStorage:true,disableStack:false}]});
 const expected=encodeAbiParameters([{type:'uint256'}],[1n]);
 const actual='0x'+trace.returnValue.replace(/^0x/,'');
 const name=`case-${count}.json`;
 writeFileSync(resolve(out,name),JSON.stringify({runtimeSha256:digest,count,descriptor,data,expected,actual,trace},null,2)+'\n');
 if(trace.failed||actual!==expected||!trace.structLogs.some(r=>r.pc===8219&&r.depth===1))throw Error('Suffix receipt mismatch');
 results.push({count,descriptor,expected,actual,trace:name,passed:true});
}
await connection.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log(`PASS: ${results.length} full public fixed-array suffix receipts`);
