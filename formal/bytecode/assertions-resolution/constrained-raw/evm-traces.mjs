// Complete mixed-constraint public resolver fixtures corroborate the native loop.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {network} from 'hardhat';
import {encodeFunctionData,toHex} from 'viem';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const candidate=process.argv[3]??null,runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const map=name=>{const x=JSON.parse(readFileSync(new URL(name,import.meta.url)));if(!candidate&&x.runtimeSha256!==digest)throw Error('Runtime drift: '+name);return x.states.map(s=>s.pc);};
const before=map('./Before.mapping.json'),prefix=map('../raw/public/Prefix.mapping.json'),tail=map('../raw/public/Return.mapping.json');
const init=map('../constraints/Init.mapping.json'),prepare=map('../constraints/Prepare.mapping.json'),decoder=map('../constraints/Decoder.mapping.json'),dispatch=map('../constraints/Dispatch.mapping.json'),increment=map('../constraints/Increment.mapping.json'),exit=map('../constraints/Exit.mapping.json'),empty=map('../constraints/Empty.mapping.json');
const after=[3967,3968,3969,3970,3971,3972,3973,3974],kinds=[0,1,2,3,4,5,7,8],leaves=new Map(kinds.map(kind=>[kind,map(`../Kind${kind}${kind===3||kind===8?'Inside':'Valid'}.mapping.json`)]));
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000006630';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const word=n=>toHex(n,{size:32});
const cases=[];
for(const count of [0,1,2,5,13])for(const extra of [0,1])cases.push({name:`mixed-${count}-extra-${extra}`,selected:Array.from({length:count},(_,i)=>kinds[i%kinds.length]),extra});
for(const kind of kinds)cases.push({name:`kind-${kind}`,selected:[kind],extra:31});
const results=[];
for(const c of cases){
 const values=c.selected.map((_,i)=>7n+BigInt(i)),constraints=c.selected.map((kind,i)=>({constraintType:kind,referenceData:kind===7?'0x':kind===3||kind===8?word(values[i]-1n)+word(values[i]+1n).slice(2):word(values[i]+(kind===0?0n:kind===2||kind===5?1n:-1n))}));
 const value='0x'+values.map(x=>word(x).slice(2)).join('')+Buffer.alloc(c.extra,0xa5).toString('hex');
 const data=encodeFunctionData({abi:artifact.abi,functionName:'resolve',args:[{paramType:0,fetcherType:0,paramData:value,constraints}]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,data,value:'0x0',gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const logs=trace.structLogs.filter(r=>r.depth===1),errors=[];
 if(trace.failed||'0x'+trace.returnValue.replace(/^0x/,'')!==value)errors.push('Independent exact public receipt differs');
 const body=c.selected.length===0?empty:[...init,...c.selected.flatMap(kind=>[...prepare,...decoder,...dispatch,...leaves.get(kind),...increment]),...exit];
 const expected=[...prefix,...before,...body,...after,...tail];
 if(JSON.stringify(logs.map(r=>r.pc))!==JSON.stringify(expected))errors.push('Complete public physical PC sequence differs');
 const helper=logs.findIndex(r=>r.pc===3393),finish=logs.findIndex((r,i)=>i>helper&&r.pc===1017);
 if(helper<0||finish<0)errors.push('Complete resolver boundary absent');
 else{
  const nat=x=>BigInt('0x'+x.replace(/^0x/,'')),mem=r=>Buffer.from(r.memory.map(w=>w.replace(/^0x/,'')).join(''),'hex'),load=(b,o)=>BigInt('0x'+b.subarray(Number(o),Number(o)+32).toString('hex'));
  const first=logs[helper],initial=first.stack.map(nat),old=mem(first),free=load(old,64n),last=logs[finish],final=last.stack.map(nat),heap=mem(last),payload=Buffer.from(value.slice(2),'hex');
  const cost=constraints.reduce((n,x)=>n+96n+BigInt(Math.ceil((x.referenceData.length-2)/2/32)*32),0n),next=free+32n+BigInt(Math.ceil(payload.length/32)*32)+cost;
  if(final.length!==initial.length-4||final.at(-1)!==free||final.slice(0,-1).some((v,i)=>v!==initial[i]))errors.push('Physical resolver stack differs');
  if(load(heap,free)!==BigInt(payload.length)||load(heap,64n)!==next||!heap.subarray(Number(free+32n),Number(free+32n)+payload.length).equals(payload))errors.push('Independent final original payload or allocator differs');
 }
 const path=c.name+'.json';writeFileSync(resolve(out,path),JSON.stringify({fixture:c,runtimeSha256:digest,data,expected:value,trace},null,2)+'\n');results.push({name:c.name,passed:errors.length===0,errors,trace:path,instructionCount:logs.length});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete mixed-constraint public resolver traces');process.exitCode=results.every(x=>x.passed)?0:1;
