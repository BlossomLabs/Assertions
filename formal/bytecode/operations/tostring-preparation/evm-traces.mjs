// Exact decimal rendering physical preparation; native and retained proof pending.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json')),inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
const canonical=Buffer.from(artifact.deployedBytecode.slice(2),'hex'),sha=x=>createHash('sha256').update(x).digest('hex');
if(sha(canonical)!==inventory.runtimeSha256||inventory.compilerIdentity.methodIdentifiers['toString(uint256)']!=='6900a3ae'||inventory.compilerIdentity.methodIdentifiers['toString(int256)']!=='a322c40e')throw Error('Canonical decimal rendering identity drift');
const candidate=process.argv[3]?readFileSync(process.argv[3]):null,code=candidate??canonical,digest=sha(code),runtime='0x'+code.toString('hex'),M=1n<<256n,H=M/2n,word=x=>((x%M+M)%M).toString(16).padStart(64,'0');
if(candidate){const config=JSON.parse(readFileSync(new URL('fault.json',import.meta.url))),diffs=[...canonical.keys()].filter(i=>canonical[i]!==code[i]);if(code.length!==canonical.length||diffs.length!==1||diffs[0]!==config.pc||canonical[config.pc]!==config.original||code[config.pc]!==config.candidate)throw Error('Expected one-byte same-arity decimal semantic fault');}
const cases=[],add=(mode,name,hex,value=0n)=>cases.push({mode,name:mode+'-'+name,data:'0x'+hex,value:value.toString()});
let nums=[0n,1n,2n,7n,9n,10n,11n,19n,20n,31n,32n,33n,99n,100n,101n,255n,256n,999n,1000n,1001n,123456789n];for(const n of [18n,31n,32n,38n,63n,76n,77n]){const x=10n**n;nums.push(x-1n,x,x+1n);}nums.push(H-1n,H,M-1n);
for(const [mode,selector] of [['unsigned','6900a3ae'],['signed','a322c40e']]){
 const unique=[...new Set((mode==='signed'?[...nums.filter(x=>x<H),...nums.filter(x=>0n<x&&x<=H).map(x=>M-x),H]:nums).map(x=>x.toString()))].map(BigInt);
 for(const [i,n] of unique.entries()){add(mode,'value-'+i,selector+word(n));if(i%4===0)add(mode,'dirty-'+i,selector+word(n)+'a5ff01');}
 for(const n of [0,1,2,3,4,5,35])add(mode,'short-'+n,(selector+word(0n)).slice(0,n*2));
 add(mode,'nonzero-empty','',1n);add(mode,'nonzero-valid',selector+word(1n),M-1n);
}
function intended(data,value,mode){
 const bytes=Buffer.from(data.slice(2),'hex');if(value!=='0')return {reason:'Nonzero',expected:''};if(bytes.length<4)return {reason:'Short',expected:''};if(bytes.subarray(0,4).toString('hex')!==(mode==='unsigned'?'6900a3ae':'a322c40e'))throw Error('Fixture selector');if(bytes.length<36)return {reason:'Args',expected:''};
 const input=BigInt('0x'+bytes.subarray(4,36).toString('hex')),number=mode==='signed'&&input>=H?input-M:input,text=number.toString(10),payload=Buffer.from(text,'ascii');return {reason:'Success',input:input.toString(),number:number.toString(),text,length:payload.length,expected:word(32n)+word(BigInt(payload.length))+payload.toString('hex')+'00'.repeat((32-payload.length%32)%32)};
}
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x0000000000000000000000000000000000002347',accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});const results=[];
for(const [ordinal,item] of cases.entries()){
 const model=intended(item.data,item.value,item.mode),trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:item.data,value:'0x'+BigInt(item.value).toString(16),gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]}),actual=trace.returnValue.replace(/^0x/,''),last=trace.structLogs.at(-1),nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),failed=model.reason!=='Success',offset=nat(last.stack.at(-1)),length=nat(last.stack.at(-2)),memory=last.memory.map(x=>x.replace(/^0x/,'')).join('');
 const passed=trace.failed===failed&&actual===model.expected&&last.op===(failed?'REVERT':'RETURN')&&memory.slice(Number(offset*2n),Number((offset+length)*2n))===model.expected;
 const file=item.name+'.json';writeFileSync(resolve(out,file),JSON.stringify({...item,ordinal,runtimeSha256:digest,model,trace},null,2)+'\n');results.push({...item,ordinal,reason:model.reason,trace:file,expected:model.expected,actual,passed,instructions:trace.structLogs.length,terminalPc:last.pc});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
const wrong=results.filter(r=>!r.passed);if(!candidate&&wrong.length||candidate&&(!wrong.length||wrong.some(r=>r.reason!=='Success')))throw Error('Wrong finite decimal rendering campaign');console.log('PASS '+results.length+' complete physical receipts; '+wrong.length+' semantic contradictions; native/retained public proof pending');
