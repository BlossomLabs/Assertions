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
if(!candidate&&digest!==inventory.runtimeSha256||inventory.compilerIdentity.methodIdentifiers['byteAt(bytes,int256)']!=='9ae8e8ea')throw new Error('Compiler/runtime/selector drift');
const M=1n<<256n,U64=(1n<<64n)-1n,selector='9ae8e8ea',word=x=>((x%M+M)%M).toString(16).padStart(64,'0');
const H=M/2n,examples=[],errorSelector=keccak256('0x'+Buffer.from('InvalidByteIndex(int256,uint256)').toString('hex')).slice(2,10);
const append=(name,hex,value=0n)=>examples.push({name,data:'0x'+hex,value});
for(const length of [0,1,2,3,31,32,33,129])for(const index of [...new Set([0n,BigInt(length)-1n,BigInt(length),M-1n,M-BigInt(length),M-BigInt(length)-1n,H,H-1n])]){
 const payload=Array.from({length},(_,i)=>(i*37+165)%256).map(x=>x.toString(16).padStart(2,'0')).join('');
 append('length'+length+'-index'+index,selector+word(64n)+word(index)+word(BigInt(length))+payload+'ff'.repeat(7));
}
for(const size of [0,1,2,3])append('short-selector-'+size,selector.slice(0,size*2));
for(const size of [4,5,35,36,67])append('short-head-'+size,selector+'00'.repeat(size-4));
append('nonzero-empty','',1n);append('nonzero-valid',selector+word(64n)+word(0n)+word(1n)+'a5',M-1n);
append('oversized-offset',selector+word(U64+1n)+word(0n)+word(0n));
append('missing-length',selector+word(64n)+word(0n));
append('short-length',selector+word(64n)+word(0n)+'00'.repeat(31));
append('oversized-length',selector+word(64n)+word(0n)+word(U64+1n));
append('short-payload',selector+word(64n)+word(0n)+word(2n)+'a5');
append('zero-offset-empty',selector+word(0n)+word(0n));
append('alias-index-length',selector+word(32n)+word(1n)+'a5');
append('unaligned-one',selector+word(65n)+word(0n)+'ff'+word(1n)+'a5');
append('gapped-one',selector+word(96n)+word(0n)+'ff'.repeat(32)+word(1n)+'a5');
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x00000000000000000000000000000000000022a1';
const accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});
function intended(hex,value){
 const bs=Buffer.from(hex.slice(2),'hex'),size=BigInt(bs.length);
 const load=offset=>{let n=0n;for(let i=0n;i<32n;i++)n=256n*n+(offset+i<size?BigInt(bs[Number(offset+i)]):0n);return n;};
 if(value!==0n)return {reason:'Nonzero',expected:''};
 if(size<4n)return {reason:'Short',expected:''};
 if(bs.subarray(0,4).toString('hex')!==selector)throw new Error('Unknown fixture selector');
 if(size<68n)return {reason:'Args',expected:''};
 const offset=load(4n),indexWord=load(36n),index=indexWord<H?indexWord:indexWord-M;
 if(offset>U64)return {reason:'OffsetBound',expected:''};
 const lengthAt=4n+offset;
 if(lengthAt+32n>size)return {reason:'LengthWindow',expected:''};
 const length=load(lengthAt);
 if(length>U64)return {reason:'LengthBound',expected:''};
 if(lengthAt+32n+length>size)return {reason:'PayloadWindow',expected:''};
 if(index>=length||index< -length)return {reason:'InvalidByteIndex',expected:errorSelector+word(indexWord)+word(length),index:index.toString(),length:length.toString()};
 const position=index<0n?length+index:index,byte=bs[Number(lengthAt+32n+position)].toString(16).padStart(2,'0');
 return {reason:'Success',offset:offset.toString(),length:length.toString(),index:index.toString(),position:position.toString(),byte,expected:word(32n)+word(1n)+byte+'00'.repeat(31)};
}
const results=[];
for(const [ordinal,x] of examples.entries()){
 const model=intended(x.data,x.value),trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:x.data,value:'0x'+x.value.toString(16),gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const name=x.name+'.json',actual=trace.returnValue.replace(/^0x/,'');
 const expectedFailure=model.reason!=='Success',last=trace.structLogs.at(-1),nat=x=>BigInt('0x'+x.replace(/^0x/,''));
 const memory=last.memory.map(x=>x.replace(/^0x/,'')).join('');
 const returnOffset=nat(last.stack.at(-1)),returnLength=nat(last.stack.at(-2));
 const passed=trace.failed===expectedFailure&&actual===model.expected&&last.op===(expectedFailure?'REVERT':'RETURN')&&returnLength===BigInt(model.expected.length/2)&&memory.slice(Number(returnOffset*2n),Number((returnOffset+returnLength)*2n))===model.expected;
 writeFileSync(resolve(out,name),JSON.stringify({ordinal,name:x.name,data:x.data,value:x.value.toString(),runtimeSha256:digest,candidate:Boolean(candidate),model,trace},null,2)+'\n');results.push({ordinal,name:x.name,reason:model.reason,trace:name,expected:model.expected,actual,passed,instructions:trace.structLogs.length});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
if(results.some(x=>!x.passed))throw new Error('Raw ABI model differs from physical compiler decoder');console.log('PASS: '+results.length+' complete byteAt raw admission/index/physical byte serialization receipts; native proof remains open');
