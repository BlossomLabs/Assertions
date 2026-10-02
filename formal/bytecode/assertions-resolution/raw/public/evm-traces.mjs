// Physical raw/no-constraints resolver traces; fixtures corroborate arbitrary-length proofs.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeFunctionData} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const candidate=process.argv[3]??null;
const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex');
const digest=sha(Buffer.from(runtime.slice(2),'hex'));
const mapping=JSON.parse(readFileSync(new URL('../Raw.mapping.json',import.meta.url)));
if(!candidate&&mapping.runtimeSha256!==digest)throw new Error('Exact runtime drift');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000006610';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const nat=x=>BigInt('0x'+x.replace(/^0x/,''));
const memory=r=>Buffer.from(r.memory.map(w=>w.replace(/^0x/,'')).join(''),'hex');
const load=(bytes,offset)=>BigInt('0x'+bytes.subarray(Number(offset),Number(offset)+32).toString('hex'));
const results=[];
for(const length of [0,1,31,32,33,64,97,257]){
 const payload=Buffer.from(Array.from({length},(_,i)=>(i*197+length*31)%256));
 const value='0x'+payload.toString('hex');
 const param={paramType:0,fetcherType:0,paramData:value,constraints:[]};
 const data=encodeFunctionData({abi:artifact.abi,functionName:'resolve',args:[param]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,data,value:'0x0',gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const logs=trace.structLogs.filter(r=>r.depth===1),start=logs.findIndex(r=>r.pc===3393),errors=[];
 if(trace.failed||'0x'+trace.returnValue.replace(/^0x/,'')!==value)errors.push('Exact physical public receipt differs');
 if(start<0)errors.push('Physical raw resolver not reached');
 else{
  const initial=logs[start],stack=initial.stack.map(nat),[ret,paramPointer,assertion,entry,paramIndex]=stack.slice(-5);
  const before=memory(initial),free=load(before,64n),end=logs.findIndex((r,i)=>i>start&&r.pc===Number(ret));
  const calldata=Buffer.from(data.slice(2),'hex'),relative=load(calldata,paramPointer+64n),constraints=load(calldata,paramPointer+96n);
  if(entry!==0n||paramIndex!==0n||load(calldata,paramPointer+32n)!==0n||load(calldata,paramPointer+relative)!==BigInt(length)||load(calldata,paramPointer+constraints)!==0n||load(before,assertion)!==0n)errors.push('Caller representation boundary differs');
  if(end<0)errors.push('Complete raw resolver return missing');
  else{
   const final=logs[end],after=memory(final),returnedStack=final.stack.map(nat),rounded=BigInt(Math.ceil(length/32)*32);
   if(returnedStack.length!==stack.length-4||returnedStack.at(-1)!==free||returnedStack.slice(0,-1).some((v,i)=>v!==stack[i]))errors.push('Physical resolver return stack differs');
   if(load(after,free)!==BigInt(length)||load(after,64n)!==free+32n+rounded||!after.subarray(Number(free+32n),Number(free+32n)+length).equals(payload)||!after.subarray(Number(free+32n)+length,Number(free+64n)+length).equals(Buffer.alloc(32)))errors.push('Physical raw bytes allocation differs');
   const actualPcs=logs.slice(start,end).map(r=>r.pc);
   if(JSON.stringify(actualPcs)!==JSON.stringify(mapping.states.map(s=>s.pc)))errors.push('Complete instruction PC path differs from generated certificate');
  }
 }
 const name='length-'+length,path=name+'.json';
 writeFileSync(resolve(out,path),JSON.stringify({length,runtimeSha256:digest,data,expected:value,trace},null,2)+'\n');
 results.push({name,passed:errors.length===0,errors,trace:path});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log((results.every(r=>r.passed)?'PASS':'FAIL')+': '+results.length+' complete raw resolver fixtures');
process.exitCode=results.every(r=>r.passed)?0:1;

const prefix=JSON.parse(readFileSync(new URL('./Prefix.mapping.json',import.meta.url)));
const body=JSON.parse(readFileSync(new URL('../Raw.mapping.json',import.meta.url)));
const tail=JSON.parse(readFileSync(new URL('./Return.mapping.json',import.meta.url)));
if(prefix.runtimeSha256!==body.runtimeSha256||tail.runtimeSha256!==body.runtimeSha256)throw new Error('Runtime identity mismatch');
const expected=[...prefix.states,...body.states,...tail.states].map(state=>state.pc);
const fullResults=JSON.parse(readFileSync(resolve(out,'results.json')));
for(const result of fullResults){
 const fixture=JSON.parse(readFileSync(resolve(out,result.trace)));
 const actual=fixture.trace.structLogs.filter(state=>state.depth===1).map(state=>state.pc);
 if(JSON.stringify(actual)!==JSON.stringify(expected))result.errors.push('Complete public PC sequence differs from its native certificate');
 result.passed=result.errors.length===0;
}
writeFileSync(resolve(out,'results.json'),JSON.stringify(fullResults,null,2)+'\n');
console.log((fullResults.every(r=>r.passed)?'PASS':'FAIL')+': '+fullResults.length+' complete public raw resolver instruction traces');
process.exitCode=fullResults.every(r=>r.passed)?0:1;
