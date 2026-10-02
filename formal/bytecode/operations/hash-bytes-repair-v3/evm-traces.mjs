// Development raw ABI decoder receipts. Native universal correspondence remains open.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {keccak256} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const candidate=process.argv[3]??null;
const art=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json')),runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):art.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
if(!candidate&&digest!==inventory.runtimeSha256||inventory.compilerIdentity.methodIdentifiers['hash(bytes)']!=='aa1e84de')throw new Error('Compiler/runtime/selector drift');
const M=1n<<256n,U64=(1n<<64n)-1n,selector='aa1e84de',word=x=>x.toString(16).padStart(64,'0');
const examples=[];
const append=(name,hex,value=0n)=>examples.push({name,data:'0x'+hex,value});
for(const length of [0,1,2,3,31,32,33,64,129])for(const trailing of [0,7])append('valid-'+length+'-tail'+trailing,selector+word(32n)+word(BigInt(length))+'a5'.repeat(length+trailing));
for(const size of [0,1,2,3])append('short-selector-'+size,selector.slice(0,size*2));
for(const size of [4,5,35])append('short-head-'+size,selector+'00'.repeat(size-4));
append('nonzero-empty','',1n);append('nonzero-valid',selector+word(32n)+word(0n),M-1n);
append('oversized-offset',selector+word(U64+1n)+word(0n));
append('max-offset',selector+word(U64)+word(0n));
append('missing-length',selector+word(32n));
append('short-length-word',selector+word(32n)+'00'.repeat(31));
append('oversized-length',selector+word(32n)+word(U64+1n));
append('max-length',selector+word(32n)+word(U64));
append('short-payload',selector+word(32n)+word(2n)+'a5');
append('zero-offset-empty',selector+word(0n));
append('unaligned-offset-empty',selector+word(33n)+'ff'+word(0n));
append('unaligned-offset-one',selector+word(35n)+'ffeedd'+word(1n)+'a5');
append('offset-gap-empty',selector+word(64n)+'ff'.repeat(32)+word(0n));
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x00000000000000000000000000000000000022a3';
const accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});
function intended(hex,value){
 const bs=Buffer.from(hex.slice(2),'hex'),size=BigInt(bs.length);
 const load=offset=>{let n=0n;for(let i=0n;i<32n;i++)n=256n*n+(offset+i<size?BigInt(bs[Number(offset+i)]):0n);return n;};
 if(value!==0n)return {reason:'Nonzero',expected:''};
 if(size<4n)return {reason:'Short',expected:''};
 if(bs.subarray(0,4).toString('hex')!==selector)throw new Error('Unknown fixture selector');
 if(size<36n)return {reason:'Args',expected:''};
 const offset=load(4n);
 if(offset>U64)return {reason:'OffsetBound',expected:''};
 const lengthAt=4n+offset;
 if(lengthAt+32n>size)return {reason:'LengthWindow',expected:''};
 const length=load(lengthAt);
 if(length>U64)return {reason:'LengthBound',expected:''};
 if(lengthAt+32n+length>size)return {reason:'PayloadWindow',expected:''};
 const preimage=bs.subarray(Number(lengthAt+32n),Number(lengthAt+32n+length)).toString('hex');
 return {reason:'Success',offset:offset.toString(),length:length.toString(),preimage,expected:keccak256('0x'+preimage).slice(2)};
}
const results=[];
for(const [ordinal,x] of examples.entries()){
 const model=intended(x.data,x.value),trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:x.data,value:'0x'+x.value.toString(16),gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const name=x.name+'.json',actual=trace.returnValue.replace(/^0x/,'');
 const expectedFailure=model.reason!=='Success',last=trace.structLogs.at(-1),nat=x=>BigInt('0x'+x.replace(/^0x/,''));
 const memory=last.memory.map(x=>x.replace(/^0x/,'')).join('');
 const hashes=trace.structLogs.filter(s=>s.op==='SHA3'||s.op==='KECCAK256');let hashObservation=null,hashPassed=expectedFailure?hashes.length===0:false;
 if(!expectedFailure){
  if(hashes.length!==1)throw new Error('Unexpected reached hash count');
  const h=hashes[0],at=nat(h.stack.at(-1)),length=nat(h.stack.at(-2)),span=h.memory.map(x=>x.replace(/^0x/,'')).join('').slice(Number(at*2n),Number((at+length)*2n));
  const observed=trace.structLogs[trace.structLogs.indexOf(h)+1].stack.at(-1).replace(/^0x/,'').padStart(64,'0');
  hashObservation={pc:h.pc,offset:at.toString(),length:length.toString(),preimage:span,observed};hashPassed=length===BigInt(model.length)&&span===model.preimage&&observed===model.expected;
 }
 const returnOffset=nat(last.stack.at(-1)),returnLength=nat(last.stack.at(-2));
 const passed=hashPassed&&trace.failed===expectedFailure&&actual===model.expected&&last.op===(expectedFailure?'REVERT':'RETURN')&&returnLength===(expectedFailure?0n:32n)&&(expectedFailure?returnOffset===0n:memory.slice(Number(returnOffset*2n),Number((returnOffset+32n)*2n))===model.expected);
 writeFileSync(resolve(out,name),JSON.stringify({ordinal,name:x.name,data:x.data,value:x.value.toString(),runtimeSha256:digest,candidate:Boolean(candidate),model,hashObservation,trace},null,2)+'\n');results.push({ordinal,name:x.name,reason:model.reason,trace:name,expected:model.expected,actual,passed,instructions:trace.structLogs.length});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu'),viem=fileURLToPath(import.meta.resolve('viem'));
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),viemEntry:viem,viemEntrySha256:sha(readFileSync(viem)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
if(results.some(x=>!x.passed))throw new Error('Wrong physical raw hash/preimage receipt');console.log('PASS: '+results.length+' complete physical hash raw admission/preimage receipts; faithful hash engine explicit, native universal correspondence remains open');
