// Actual EVM fixtures corroborate the arbitrary-kind/reference decoder theorem.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeFunctionData,toHex} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const candidate=process.argv[3]??null;
const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex');
const digest=sha(Buffer.from(runtime.slice(2),'hex'));
const mapping=JSON.parse(readFileSync(new URL('./Decoder.mapping.json',import.meta.url)));
if(!candidate&&mapping.runtimeSha256!==digest)throw new Error('Exact runtime drift');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000006620';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const nat=x=>BigInt('0x'+x.replace(/^0x/,''));
const memory=r=>Buffer.from(r.memory.map(w=>w.replace(/^0x/,'')).join(''),'hex');
const load=(bytes,offset)=>BigInt('0x'+bytes.subarray(Number(offset),Number(offset)+32).toString('hex'));
const store=(bytes,offset,value)=>Buffer.from(toHex(value,{size:32}).slice(2),'hex').copy(bytes,Number(offset));
const results=[];
for(const kind of [0,1,2,3,4,5,6,7,8])for(const length of [0,1,31,32,33,64,97,257]){
 const payload=Buffer.from(Array.from({length},(_,i)=>(i*197+length*31+kind*13)%256));
 const param={paramType:0,fetcherType:0,paramData:toHex(7n,{size:32}),constraints:[{constraintType:kind,referenceData:'0x'+payload.toString('hex')}]};
 const data=encodeFunctionData({abi:artifact.abi,functionName:'resolve',args:[param]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,data,value:'0x0',gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const logs=trace.structLogs.filter(r=>r.depth===1),start=logs.findIndex(r=>r.pc===19377),errors=[];
 if(start<0)errors.push('Physical decoder entry absent');
 else{
  const initial=logs[start],stack=initial.stack.map(nat),[ret,offset]=stack.slice(-2),before=memory(initial),free=load(before,64n);
  const end=logs.findIndex((r,i)=>i>start&&r.pc===Number(ret));
  const calldata=Buffer.from(data.slice(2),'hex'),relative=load(calldata,offset+32n);
  if(load(calldata,offset)!==BigInt(kind)||load(calldata,offset+relative)!==BigInt(length))errors.push('Caller calldata representation differs');
  if(end<0)errors.push('Complete decoder continuation absent');
  else{
   const final=logs[end],after=memory(final),returnedStack=final.stack.map(nat),rounded=BigInt(Math.ceil(length/32)*32),nextFree=free+96n+rounded;
   const expected=Buffer.alloc(Math.max(before.length,Number(nextFree+32n)));before.copy(expected);
   store(expected,64n,nextFree);store(expected,free,BigInt(kind));store(expected,free+32n,free+64n);store(expected,free+64n,BigInt(length));
   calldata.subarray(Number(offset+relative+32n),Number(offset+relative+32n)+length).copy(expected,Number(free+96n));
   expected.fill(0,Number(free+96n)+length,Number(free+128n)+length);
   if(returnedStack.length!==stack.length-1||returnedStack.at(-1)!==free||returnedStack.slice(0,-1).some((v,i)=>v!==stack[i]))errors.push('Physical decoder return stack differs');
   if(!after.equals(expected))errors.push('Independent complete decoder heap differs');
   const actualPcs=logs.slice(start,end).map(r=>r.pc);
   if(JSON.stringify(actualPcs)!==JSON.stringify(mapping.states.map(s=>s.pc)))errors.push('Complete decoder PC sequence differs');
  }
 }
 const name=`kind-${kind}-length-${length}`,path=name+'.json';
 writeFileSync(resolve(out,path),JSON.stringify({kind,length,runtimeSha256:digest,candidate:Boolean(candidate),data,trace},null,2)+'\n');
 results.push({name,passed:errors.length===0,errors,trace:path});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log((results.every(r=>r.passed)?'PASS':'FAIL')+': '+results.length+' complete physical decoder fixtures');
process.exitCode=results.every(r=>r.passed)?0:1;
