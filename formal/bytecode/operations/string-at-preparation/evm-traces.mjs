// Development raw ABI decoder receipts. Native universal correspondence remains open.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {keccak256} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const candidate=process.argv[3]&&process.argv[3]!=='-'?process.argv[3]:null;
const unitFixtures=process.argv[4]??null;
const art=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json')),runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):art.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
if(!candidate&&digest!==inventory.runtimeSha256||inventory.compilerIdentity.methodIdentifiers['stringAt(bytes,int256)']!=='a1bc2139')throw new Error('Compiler/runtime/selector drift');
if(candidate){const canonical=Buffer.from(art.deployedBytecode.slice(2),'hex'),bytes=Buffer.from(runtime.slice(2),'hex'),config=JSON.parse(readFileSync(new URL('fault.json',import.meta.url))),diff=[...canonical.keys()].filter(i=>canonical[i]!==bytes[i]);if(canonical.length!==bytes.length||diff.length!==1||diff[0]!==config.pc||canonical[config.pc]!==config.original||bytes[config.pc]!==config.candidate)throw Error('Expected selected one-byte same-arity stringAt fault');}
const M=1n<<256n,U64=(1n<<64n)-1n,selector='a1bc2139',word=x=>((x%M+M)%M).toString(16).padStart(64,'0');
const H=M/2n,examples=[],utfSelector=keccak256('0x'+Buffer.from('InvalidUtf8(uint256)').toString('hex')).slice(2,10),errorSelector=keccak256('0x'+Buffer.from('InvalidByteIndex(int256,uint256)').toString('hex')).slice(2,10);
const append=(name,hex,value=0n)=>examples.push({name,data:'0x'+hex,value});
const valid=['','41','00','7f','4142','41'.repeat(31),'41'.repeat(32),'41'.repeat(33),'41'.repeat(65),'41'.repeat(129),'c280','c2bf','df80','dfbf','e0a080','e0bfbf','e18080','ecbfbf','ed8080','ed9fbf','ee8080','efbfbf','f0908080','f0bfbfbf','f1808080','f3bfbfbf','f4808080','f48fbfbf','41c28042e0a08043ed9fbf44f090808045f48fbfbf46'];
for(const [ordinal,payload] of valid.entries()){
 const length=BigInt(payload.length/2);
 for(const [j,index] of [...new Set([0n,length-1n,length,M-1n,(M-length)%M,(M-length-1n)%M,H,H-1n])].entries())append('valid'+ordinal+'-index'+j,selector+word(64n)+word(index)+word(length)+payload+'a5ff');
}
const invalid=['80','bf','c0','c1','f5','ff','c2','df','e0','e0a0','ed80','efbf','f0','f090','f09080','f48fbf','c27f','dfc0','e09fbf','eda080','edbfbf','f08fbfbf','f4908080','f4bfbfbf','e1c080','e180c0','f1c08080','f180c080','f18080ff'];
for(const [i,bad] of invalid.entries())for(const [j,prefix] of ['','41c280'].entries())append('invalid'+i+'-prefix'+j,selector+word(64n)+word(j?H:0n)+word(BigInt((prefix+bad).length/2))+prefix+bad+'ff');
for(const size of [0,1,2,3])append('short-selector-'+size,selector.slice(0,size*2));
for(const size of [4,5,35,36,67])append('short-head-'+size,selector+'00'.repeat(size-4));
append('nonzero-empty','',1n);append('nonzero-valid',selector+word(64n)+word(0n)+word(1n)+'41',M-1n);
append('oversized-offset',selector+word(U64+1n)+word(0n)+word(0n));
append('missing-length',selector+word(64n)+word(0n));
append('short-length',selector+word(64n)+word(0n)+'00'.repeat(31));
append('oversized-length',selector+word(64n)+word(0n)+word(U64+1n));
append('short-payload',selector+word(64n)+word(0n)+word(2n)+'41');
append('zero-offset-empty',selector+word(0n)+word(0n));
append('alias-index-length',selector+word(32n)+word(1n)+'41');
append('unaligned-one',selector+word(65n)+word(0n)+'ff'+word(1n)+'41');
append('gapped-one',selector+word(96n)+word(0n)+'ff'.repeat(32)+word(1n)+'41');
if(unitFixtures)for(const x of JSON.parse(readFileSync(resolve(unitFixtures))))for(const [j,prefix] of ['','41c280'].entries()){const payload=prefix+x.sample;append('unit-profile-'+x.name+'-prefix'+j,selector+word(64n)+word(j?H:0n)+word(BigInt(payload.length/2))+payload+'a5ff');}
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x00000000000000000000000000000000000024a1';
const accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});
function badUtf8(bytes){
 for(let i=0;i<bytes.length;){const lead=bytes[i];if(lead<128){i++;continue;}let width,secondLow=128,secondHigh=191;
  if(194<=lead&&lead<=223)width=2;
  else if(224<=lead&&lead<=239){width=3;if(lead===224)secondLow=160;if(lead===237)secondHigh=159;}
  else if(240<=lead&&lead<=244){width=4;if(lead===240)secondLow=144;if(lead===244)secondHigh=143;}
  else return i;
  if(i+width>bytes.length)return i;
  if(bytes[i+1]<secondLow||bytes[i+1]>secondHigh)return i+1;
  for(let j=2;j<width;j++)if(bytes[i+j]<128||bytes[i+j]>191)return i+j;
  i+=width;
 }return null;
}
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
 const payload=bs.subarray(Number(lengthAt+32n),Number(lengthAt+32n+length)),bad=badUtf8(payload);
 if(bad!==null)return {reason:'InvalidUtf8',utfPosition:bad,expected:utfSelector+word(BigInt(bad))};
 if(index>=length||index< -length)return {reason:'InvalidByteIndex',expected:errorSelector+word(indexWord)+word(length),index:index.toString(),length:length.toString()};
 const position=index<0n?length+index:index,byte=bs[Number(lengthAt+32n+position)].toString(16).padStart(2,'0');
 if(parseInt(byte,16)>=128)return {reason:'InvalidUtf8',utfPosition:Number(position),expected:utfSelector+word(position)};
 return {reason:'Success',offset:offset.toString(),length:length.toString(),index:index.toString(),position:position.toString(),byte,expected:word(32n)+word(1n)+byte+'00'.repeat(31)};
}
const results=[];
for(const [ordinal,x] of examples.entries()){
 const model=intended(x.data,x.value),trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:x.data,value:'0x'+x.value.toString(16),gas:'0x989680'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
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
const wrong=results.filter(x=>!x.passed);if(!candidate&&wrong.length||candidate&&(!wrong.length||wrong.some(x=>x.reason!=='Success')))throw new Error('Independent stringAt model differs from complete physical outcome');console.log('PASS '+results.length+' complete UTF8/index/byte RETURN receipts; '+wrong.length+' semantic faults; native pending');
