// Independent exact error receipts and complete first-error instruction paths.
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
const map=n=>{const m=JSON.parse(readFileSync(new URL(n,import.meta.url)));if(!candidate&&m.runtimeSha256!==digest)throw Error('Runtime drift');return m.states.map(x=>x.pc);};
const prefix=map('../../raw/public/Prefix.mapping.json'),before=map('../../constrained-raw/Before.mapping.json'),init=map('../Init.mapping.json'),prepare=map('../Prepare.mapping.json'),decoder=map('../Decoder.mapping.json'),dispatch=map('../Dispatch.mapping.json'),increment=map('../Increment.mapping.json'),skip=map('../../Kind7Valid.mapping.json');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;const [from]=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000006640';await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const word=x=>toHex(BigInt(x),{size:32}),cases=[];
for(const kind of [0,1,2,3,4,5,7,8])cases.push({kind,count:1,bad:0,verdict:'BadData'});
for(const kind of [3,8])cases.push({kind,count:1,bad:0,verdict:'BadRange'});
for(const bad of [0,2,4])for(const [kind,verdict] of [[0,'BadData'],[7,'BadData'],[3,'BadRange'],[8,'BadRange']])cases.push({kind,count:5,bad,verdict});
const results=[];
for(const c of cases){
 const reference=c.verdict==='BadData'?'0xa5':word(10)+word(5).slice(2),constraints=Array.from({length:c.count},(_,i)=>i===c.bad?{constraintType:c.kind,referenceData:reference}:{constraintType:7,referenceData:'0x'}),value='0x'+word(7).slice(2).repeat(c.count),data=encodeFunctionData({abi:artifact.abi,functionName:'resolve',args:[{paramType:0,fetcherType:0,paramData:value,constraints}]});
 const expected=(c.verdict==='BadData'?'0xe70ce766':'0x295a41c5')+word(0).slice(2).repeat(2)+word(c.bad).slice(2)+(c.verdict==='BadData'?word(1).slice(2):'');
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:target,data,value:'0x0',gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]}),logs=trace.structLogs.filter(x=>x.depth===1),errors=[];
 if(!trace.failed||'0x'+trace.returnValue.replace(/^0x/,'')!==expected)errors.push('Independent exact first-error receipt differs');
 const accepted=[...prepare,...decoder,...dispatch,...skip,...increment],failed=[...prepare,...decoder,...dispatch,...map(`../../Kind${c.kind}${c.verdict}.mapping.json`)],path=[...prefix,...before,...init,...Array.from({length:c.bad},()=>accepted).flat(),...failed];
 if(JSON.stringify(logs.map(x=>x.pc))!==JSON.stringify(path))errors.push('Complete first-error physical PC sequence differs');
 const last=logs.at(-1),mem=Buffer.from(last.memory.map(x=>x.replace(/^0x/,'')).join(''),'hex'),offset=BigInt('0x'+last.stack.at(-1).replace(/^0x/,'')),size=BigInt('0x'+last.stack.at(-2).replace(/^0x/,''));
 if(last.op!=='REVERT'||'0x'+mem.subarray(Number(offset),Number(offset+size)).toString('hex')!==expected)errors.push('Physical REVERT memory differs');
 const name=`kind-${c.kind}-${c.verdict}-count-${c.count}-bad-${c.bad}`,file=name+'.json';writeFileSync(resolve(out,file),JSON.stringify({fixture:c,runtimeSha256:digest,data,expected,trace},null,2)+'\n');results.push({name,passed:errors.length===0,errors,trace:file,instructionCount:logs.length});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete first-error public resolver fixtures');process.exitCode=results.every(x=>x.passed)?0:1;
