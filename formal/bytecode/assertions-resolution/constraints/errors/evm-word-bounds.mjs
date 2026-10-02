// Independent word-count error and complete public physical path, including malformed unread leaves.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
import {encodeFunctionData,toHex} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const candidate=process.argv[3]??null,runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const mapping=name=>{const m=JSON.parse(readFileSync(new URL(name,import.meta.url)));if(!candidate&&m.runtimeSha256!==digest)throw Error('Runtime drift');return m.states.map(x=>x.pc);};
const expectedPath=[...mapping('../../raw/public/Prefix.mapping.json'),...mapping('../../constrained-raw/Before.mapping.json'),...mapping('./WordBounds.mapping.json')];
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000006650';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const word=x=>toHex(BigInt(x),{size:32}),results=[];
for(const length of [0,1,31,32,33,63,64,65])for(const excess of [1,2]){
 const words=Math.floor(length/32),count=words+excess,value='0x'+Buffer.alloc(length,0xa5).toString('hex');
 const constraints=Array.from({length:count},(_,i)=>({constraintType:i%2===0?6:255,referenceData:'0xff'}));
 const data=encodeFunctionData({abi:artifact.abi,functionName:'resolve',args:[{paramType:0,fetcherType:0,paramData:value,constraints}]});
 const expected='0xd5cb8436'+word(words).slice(2)+word(length).slice(2);
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,data,value:'0x0',gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const logs=trace.structLogs.filter(x=>x.depth===1),errors=[];
 if(!trace.failed||'0x'+trace.returnValue.replace(/^0x/,'')!==expected)errors.push('Independent exact word-count error differs');
 if(JSON.stringify(logs.map(x=>x.pc))!==JSON.stringify(expectedPath))errors.push('Complete public word-count PC path differs');
 const last=logs.at(-1),mem=Buffer.from(last.memory.map(x=>x.replace(/^0x/,'')).join(''),'hex'),offset=BigInt('0x'+last.stack.at(-1).replace(/^0x/,'')),size=BigInt('0x'+last.stack.at(-2).replace(/^0x/,''));
 if(last.op!=='REVERT'||'0x'+mem.subarray(Number(offset),Number(offset+size)).toString('hex')!==expected)errors.push('Physical word-count REVERT bytes differ');
 const name=`length-${length}-excess-${excess}`,file=name+'.json';
 writeFileSync(resolve(out,file),JSON.stringify({fixture:{length,excess,count,unreadMalformedLeaves:true},runtimeSha256:digest,data,expected,trace},null,2)+'\n');
 results.push({name,passed:errors.length===0,errors,trace:file,instructionCount:logs.length});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete public word-count rejection fixtures');
process.exitCode=results.every(x=>x.passed)?0:1;
