// Concrete complete public nav calls exercising the actual normalized-index helper.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeAbiParameters,encodeFunctionData,encodeErrorResult} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const runtime=artifact.deployedBytecode;
const digest=createHash('sha256').update(Buffer.from(runtime.slice(2),'hex')).digest('hex');
const frozen=JSON.parse(readFileSync('formal/bytecode/dispatch/inventory.json'));
if(digest!==frozen.Assertions.runtimeSha256)throw Error('Assertions runtime drift');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'});
const target='0x0000000000000000000000000000000000003702';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const errorAbi=[{type:'error',name:'ReturnDataOutOfBounds',inputs:[{name:'index',type:'int256'},{name:'length',type:'uint256'}]}];
const results=[];
const fixtures=[];
for(const length of [32,64,96]) for(const pos of [length-31,length]) {
 const payload='0x'+BigInt(pos).toString(16).padStart(64,'0')+'00'.repeat(length-32);
 fixtures.push({length,pos,payload,expected:encodeErrorResult({abi:errorAbi,errorName:'ReturnDataOutOfBounds',args:[BigInt(Math.floor(pos/32)),BigInt(length)]})});
}
for(const fixture of fixtures){
 const {length,pos,payload,expected}=fixture;
 const data=encodeFunctionData({abi:artifact.abi,functionName:'nav',args:[{paramType:0,fetcherType:0,paramData:payload,constraints:[]},'(uint256[])',[0n,0n]]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const actual='0x'+trace.returnValue.replace(/^0x/,'');
 const file='case-'+results.length+'.json';
 writeFileSync(resolve(out,file),JSON.stringify({length,pos,expected,actual,runtimeSha256:digest,data,trace},null,2)+'\n');
 if(!trace.failed||actual!==expected)throw Error('Wrong nav word receipt '+length+'/'+pos+' '+actual+' expected '+expected);
 if(!trace.structLogs.some(r=>r.pc===8130&&r.depth===1))throw Error('Actual nav-word helper not reached');
 results.push({length,pos,expected,actual,trace:file,passed:true});
}
await connection.close();
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log('PASS: '+results.length+' complete public nav word error receipts on exact Assertions runtime');
