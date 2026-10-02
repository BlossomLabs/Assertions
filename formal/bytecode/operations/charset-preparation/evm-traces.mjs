// Exact charset physical preparation; finite receipts give no public proof credit.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json')),inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
const canonical=Buffer.from(artifact.deployedBytecode.slice(2),'hex'),sha=x=>createHash('sha256').update(x).digest('hex');
if(sha(canonical)!==inventory.runtimeSha256||inventory.compilerIdentity.methodIdentifiers['charset(bytes,uint256)']!=='3e8c97e3')throw Error('Canonical charset identity drift');
const candidate=process.argv[3]?readFileSync(process.argv[3]):null,code=candidate??canonical,digest=sha(code),runtime='0x'+code.toString('hex'),M=1n<<256n,U64=1n<<64n,selector='3e8c97e3',word=x=>x.toString(16).padStart(64,'0');
if(candidate){const diffs=[...canonical.keys()].filter(i=>canonical[i]!==code[i]);if(code.length!==canonical.length||diffs.length!==1||diffs[0]!==4164||canonical[diffs[0]]!==0x16||code[diffs[0]]!==0x17)throw Error('Expected exact one-byte AND-to-OR membership fault');}
const cases=[],add=(name,hex,value=0n)=>cases.push({name,data:'0x'+hex,value:value.toString()});
function packet(bytes,mask,tail=0){return selector+word(64n)+word(mask)+word(BigInt(bytes.length))+Buffer.from(bytes).toString('hex')+'a5'.repeat(tail);}
for(const n of [0,1,2,3,7,31,32,33,63,64,65,127,128,129]){
 const bytes=Array.from({length:n},(_,i)=>(i*37+7)%256),exact=bytes.reduce((m,b)=>m|(1n<<BigInt(b)),0n);
 add('length-'+n+'-all',packet(bytes,M-1n));add('length-'+n+'-exact',packet(bytes,exact,7));
 add('length-'+n+'-zero',packet(bytes,0n));
 if(n)add('length-'+n+'-missing-last',packet(bytes,exact&~(1n<<BigInt(bytes.at(-1)))));
}
for(const [name,bytes,mask] of [['high-bit',[255],1n<<255n],['low-bit',[0],1n],['miss-high',[255],0n],['all-bytes',Array.from({length:256},(_,i)=>i),M-1n],['late-miss',Array.from({length:256},(_,i)=>i),(1n<<255n)-1n]])add(name,packet(bytes,mask));
for(const n of [0,1,2,3,4,5,35,36,67])add('short-'+n,(selector+word(64n)+word(M-1n)).slice(0,n*2));
add('nonzero-empty','',1n);add('nonzero-valid',packet([],0n),M-1n);
add('offset-large',selector+word(U64)+word(0n)+word(0n));add('offset-max',selector+word(U64-1n)+word(0n));
add('length-missing',selector+word(64n)+word(0n));add('length-short',selector+word(64n)+word(0n)+'00'.repeat(31));
add('length-large',selector+word(64n)+word(0n)+word(U64));add('payload-short',selector+word(64n)+word(0n)+word(2n)+'ff');
add('offset-zero',selector+word(0n)+word(0n));add('offset-mask',selector+word(32n)+word(0n));
add('unaligned-empty',selector+word(65n)+word(0n)+'ff'+word(0n));add('unaligned-one',selector+word(67n)+word(1n<<255n)+'ffeedd'+word(1n)+'ff');
function intended(data,value){
 const bytes=Buffer.from(data.slice(2),'hex'),size=BigInt(bytes.length),load=at=>{let x=0n;for(let i=0n;i<32n;i++)x=256n*x+(at+i<size?BigInt(bytes[Number(at+i)]):0n);return x;};
 if(value!=='0')return {reason:'Nonzero',expected:''};if(size<4n)return {reason:'Short',expected:''};if(bytes.subarray(0,4).toString('hex')!==selector)throw Error('Fixture selector');
 if(size<68n)return {reason:'Args',expected:''};const offset=load(4n),mask=load(36n);if(offset>=U64)return {reason:'OffsetBound',expected:''};if(offset+36n>size)return {reason:'LengthWindow',expected:''};
 const length=load(offset+4n);if(length>=U64)return {reason:'LengthBound',expected:''};if(offset+36n+length>size)return {reason:'PayloadWindow',expected:''};
 const payload=bytes.subarray(Number(offset+36n),Number(offset+36n+length)),result=[...payload].every(b=>((mask>>BigInt(b))&1n)===1n);return {reason:'Success',offset:offset.toString(),length:length.toString(),mask:mask.toString(),expected:word(result?1n:0n)};
}
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x0000000000000000000000000000000000002346',accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});const results=[];
for(const [ordinal,item] of cases.entries()){
 const model=intended(item.data,item.value),trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:item.data,value:'0x'+BigInt(item.value).toString(16),gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]}),actual=trace.returnValue.replace(/^0x/,''),last=trace.structLogs.at(-1),nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),failed=model.reason!=='Success',offset=nat(last.stack.at(-1)),length=nat(last.stack.at(-2)),memory=last.memory.map(x=>x.replace(/^0x/,'')).join('');
 const passed=trace.failed===failed&&actual===model.expected&&last.op===(failed?'REVERT':'RETURN')&&memory.slice(Number(offset*2n),Number((offset+length)*2n))===model.expected;
 const file=item.name+'.json';writeFileSync(resolve(out,file),JSON.stringify({...item,ordinal,runtimeSha256:digest,model,trace},null,2)+'\n');results.push({...item,ordinal,reason:model.reason,trace:file,expected:model.expected,actual,passed,instructions:trace.structLogs.length,terminalPc:last.pc});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
const wrong=results.filter(r=>!r.passed);if(!candidate&&wrong.length||candidate&&(!wrong.length||wrong.some(r=>r.reason!=='Success')))throw Error('Wrong finite charset campaign');console.log('PASS '+results.length+' complete physical receipts; '+wrong.length+' semantic contradictions; native/retained public proof pending');
