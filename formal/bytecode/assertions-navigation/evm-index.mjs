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
const errorAbi=[{type:'error',name:'ElementIndexOutOfBounds',inputs:[{name:'index',type:'int256'},{name:'count',type:'uint256'}]}];
const results=[];
for(const count of [0n,1n,3n]){
 const values=Array.from({length:Number(count)},(_,i)=>BigInt(0x1234+i));
 const payload=encodeAbiParameters([{type:'uint256[]'}],[values]);
 const indexes=[...new Set([-count-1n,-count,-1n,0n,count-1n,count,(1n<<255n)-1n,-(1n<<255n)])];
 for(const index of indexes){
  const normalized=index<0n?count+index:index;
  const valid=normalized>=0n&&normalized<count;
  // int256.min is a sentinel only in the final path slot. Put a later slot after
  // it so the actual array index check must reject it before reaching that slot.
  const path=index===-(1n<<255n)?[0n,index,0n]:[0n,index];
  const data=encodeFunctionData({abi:artifact.abi,functionName:'nav',args:[{paramType:0,fetcherType:0,paramData:payload,constraints:[]},'(uint256[])',path]});
  const expected=valid?encodeAbiParameters([{type:'uint256'}],[values[Number(normalized)]]):encodeErrorResult({abi:errorAbi,errorName:'ElementIndexOutOfBounds',args:[index,count]});
  const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
  const actual='0x'+trace.returnValue.replace(/^0x/,'');
  const file='case-'+results.length+'.json';
  writeFileSync(resolve(out,file),JSON.stringify({count:String(count),index:String(index),valid,expected,actual,runtimeSha256:digest,data,trace},null,2)+'\n');
  if(trace.failed===valid||actual!==expected)throw Error('Wrong nav index receipt '+count+'/'+index);
  if(!trace.structLogs.some(r=>r.pc===12574&&r.depth===1))throw Error('Actual normalized-index helper not reached');
  results.push({count:String(count),index:String(index),valid,expected,actual,trace:file,passed:true});
 }
}
await connection.close();
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log('PASS: '+results.length+' complete public nav index receipts on exact Assertions runtime');
