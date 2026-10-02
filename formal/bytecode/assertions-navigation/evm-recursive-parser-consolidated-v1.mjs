// Fresh whole-EVM witness for a static tuple width above uint32 followed by [].
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeAbiParameters,encodeFunctionData} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:false});
const sha=b=>createHash('sha256').update(b).digest('hex');
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const digest=sha(Buffer.from(artifact.deployedBytecode.slice(2),'hex'));
if(digest!==JSON.parse(readFileSync('formal/bytecode/dispatch/inventory.json')).Assertions.runtimeSha256)throw Error('runtime drift');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003715';
await provider.request({method:'hardhat_setCode',params:[target,artifact.deployedBytecode]});
const cases=[
 ['uint256[2][]','(uint256[2][])'],
 ['(uint256,bytes)[]','((uint256,bytes)[])'],
 ['uint256[][2][]','(uint256[][2][])'],
 ['(uint256[2],(bytes,uint256[]))[]','((uint256[2],(bytes,uint256[]))[])']
];
const results=[];
for(let index=0;index<cases.length;index++){
 const [type,descriptor]=cases[index];
 const payload=encodeAbiParameters([{type}],[[]]);
 const data=encodeFunctionData({abi:artifact.abi,functionName:'nav',args:[{paramType:0,fetcherType:0,paramData:payload,constraints:[]},descriptor,[0n,-(1n<<255n)]]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const expected=encodeAbiParameters([{type:'uint256'}],[0n]),actual='0x'+trace.returnValue.replace(/^0x/,'');
 writeFileSync(resolve(out,`case-${index}.json`),JSON.stringify({runtimeSha256:digest,descriptor,data,expected,actual,trace},null,2)+'\n');
 if(trace.failed||actual!==expected)throw Error(`case ${index} rejected`);
 results.push({index,type,descriptor,passed:true});
}
await connection.close();
writeFileSync(resolve(out,'result.json'),JSON.stringify({status:'passed',scope:'Four PC0 recursive canonical descriptor executions; parser full-state replay is separate and whole-entry proof remains open',runtimeSha256:digest,nodeVersion:process.version,nodeSha256:sha(readFileSync(process.execPath)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml')),results},null,2)+'\n');
console.log('PASS four recursive parser cases');
