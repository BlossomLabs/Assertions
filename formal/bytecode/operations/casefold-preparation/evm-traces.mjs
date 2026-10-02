// Exact ASCII case-fold physical preparation; finite receipts give no public proof credit.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json')),inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
const canonical=Buffer.from(artifact.deployedBytecode.slice(2),'hex'),sha=x=>createHash('sha256').update(x).digest('hex');
if(sha(canonical)!==inventory.runtimeSha256||inventory.compilerIdentity.methodIdentifiers['toLower(bytes)']!=='c1459c04'||inventory.compilerIdentity.methodIdentifiers['toUpper(bytes)']!=='feec0cff')throw Error('Canonical case-fold identity drift');
const candidate=process.argv[3]?readFileSync(process.argv[3]):null,code=candidate??canonical,digest=sha(code),runtime='0x'+code.toString('hex'),M=1n<<256n,U64=1n<<64n,word=x=>x.toString(16).padStart(64,'0');
if(candidate){const diffs=[...canonical.keys()].filter(i=>canonical[i]!==code[i]);if(code.length!==canonical.length||diffs.length!==1||diffs[0]!==12297||canonical[diffs[0]]!==0x18||code[diffs[0]]!==0x16)throw Error('Expected one-byte same-arity XOR-to-AND case-fold fault');}
const cases=[],add=(mode,name,hex,value=0n)=>cases.push({mode,name:mode+'-'+name,data:'0x'+hex,value:value.toString()});
for(const [mode,selector] of [['lower','c1459c04'],['upper','feec0cff']]){
 function packet(bytes,tail=0){return selector+word(32n)+word(BigInt(bytes.length))+Buffer.from(bytes).toString('hex')+'a5'.repeat(tail);}
 for(const n of [0,1,2,3,7,31,32,33,63,64,65,127,128,129,255,256]){
  const bytes=Array.from({length:n},(_,i)=>(i*37+65)%256);add(mode,'length-'+n,packet(bytes));add(mode,'dirty-'+n,packet(bytes,7));
 }
 for(const byte of [0,31,32,33,64,65,66,90,91,96,97,122,123,127,128,255])add(mode,'byte-'+byte,packet([byte]));
 add(mode,'all-bytes',packet(Array.from({length:256},(_,i)=>i)));
 for(const n of [0,1,2,3,4,5,35])add(mode,'short-'+n,(selector+word(32n)).slice(0,n*2));
 add(mode,'nonzero-empty','',1n);add(mode,'nonzero-valid',packet([],0),M-1n);
 add(mode,'offset-large',selector+word(U64)+word(0n));add(mode,'offset-max',selector+word(U64-1n));
 add(mode,'length-missing',selector+word(32n));add(mode,'length-short',selector+word(32n)+'00'.repeat(31));
 add(mode,'length-large',selector+word(32n)+word(U64));add(mode,'payload-short',selector+word(32n)+word(2n)+'ff');
 add(mode,'offset-zero',selector+word(0n));add(mode,'unaligned-empty',selector+word(33n)+'ff'+word(0n));add(mode,'unaligned-one',selector+word(35n)+'ffeedd'+word(1n)+'41');
}
function intended(data,value,mode){
 const bytes=Buffer.from(data.slice(2),'hex'),size=BigInt(bytes.length),load=at=>{let x=0n;for(let i=0n;i<32n;i++)x=256n*x+(at+i<size?BigInt(bytes[Number(at+i)]):0n);return x;};
 if(value!=='0')return {reason:'Nonzero',expected:''};if(size<4n)return {reason:'Short',expected:''};if(bytes.subarray(0,4).toString('hex')!==(mode==='lower'?'c1459c04':'feec0cff'))throw Error('Fixture selector');
 if(size<36n)return {reason:'Args',expected:''};const offset=load(4n);if(offset>=U64)return {reason:'OffsetBound',expected:''};if(offset+36n>size)return {reason:'LengthWindow',expected:''};
 const length=load(offset+4n);if(length>=U64)return {reason:'LengthBound',expected:''};if(offset+36n+length>size)return {reason:'PayloadWindow',expected:''};
 const payload=[...bytes.subarray(Number(offset+36n),Number(offset+36n+length))],low=mode==='lower'?65:97,high=low+25,result=payload.map(b=>low<=b&&b<=high?b^32:b);return {reason:'Success',offset:offset.toString(),length:length.toString(),expected:word(32n)+word(length)+Buffer.from(result).toString('hex')+'00'.repeat((32-result.length%32)%32)};
}
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x0000000000000000000000000000000000002346',accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});const results=[];
for(const [ordinal,item] of cases.entries()){
 const model=intended(item.data,item.value,item.mode),trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:item.data,value:'0x'+BigInt(item.value).toString(16),gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]}),actual=trace.returnValue.replace(/^0x/,''),last=trace.structLogs.at(-1),nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),failed=model.reason!=='Success',offset=nat(last.stack.at(-1)),length=nat(last.stack.at(-2)),memory=last.memory.map(x=>x.replace(/^0x/,'')).join('');
 const passed=trace.failed===failed&&actual===model.expected&&last.op===(failed?'REVERT':'RETURN')&&memory.slice(Number(offset*2n),Number((offset+length)*2n))===model.expected;
 const file=item.name+'.json';writeFileSync(resolve(out,file),JSON.stringify({...item,ordinal,runtimeSha256:digest,model,trace},null,2)+'\n');results.push({...item,ordinal,reason:model.reason,trace:file,expected:model.expected,actual,passed,instructions:trace.structLogs.length,terminalPc:last.pc});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
const wrong=results.filter(r=>!r.passed);if(!candidate&&wrong.length||candidate&&(!wrong.length||wrong.some(r=>r.reason!=='Success')))throw Error('Wrong finite case-fold campaign');console.log('PASS '+results.length+' complete physical receipts; '+wrong.length+' semantic contradictions; native/retained public proof pending');
