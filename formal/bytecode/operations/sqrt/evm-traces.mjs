// Development raw ABI decoder receipts. Native universal correspondence remains open.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const candidate=process.argv[3]??null;
const art=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json')),runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):art.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
if(!candidate&&digest!==inventory.runtimeSha256||inventory.compilerIdentity.methodIdentifiers['sqrt(uint256)']!=='677342ce')throw new Error('Compiler/runtime/selector drift');
const M=1n<<256n,U64=(1n<<64n)-1n,selector='677342ce',word=x=>x.toString(16).padStart(64,'0');
const examples=[];
const append=(name,hex,value=0n)=>examples.push({name,data:'0x'+hex,value});
const inputs=new Set([0n,1n,2n,3n,4n,8n,9n,15n,16n,17n,123n,456n,M-1n]);
for(const bit of [4,7,8,15,16,31,32,63,64,127,128,191,192,223,224,254,255])for(const delta of [-1n,0n,1n])inputs.add((1n<<BigInt(bit))+delta);
for(const root of [15n,16n,17n,123n,456n,(1n<<64n)-1n,1n<<64n,(1n<<128n)-1n])for(const delta of [-1n,0n,1n]){const n=root*root+delta;if(0n<=n&&n<M)inputs.add(n);}
for(const n of inputs)for(const trailing of [0,7])append('valid-'+n+'-tail'+trailing,selector+word(n)+'a5'.repeat(trailing));
for(const size of [0,1,2,3])append('short-selector-'+size,selector.slice(0,size*2));
for(const size of [4,5,35])append('short-head-'+size,selector+'00'.repeat(size-4));
append('nonzero-empty','',1n);append('nonzero-valid',selector+word(123n),M-1n);
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x00000000000000000000000000000000000022a3';
const accounts=await p.request({method:'eth_accounts'});await p.request({method:'hardhat_setCode',params:[target,runtime]});
function rootFloor(n){let lo=0n,hi=1n<<128n;while(lo<hi){const mid=(lo+hi+1n)>>1n;if(mid*mid<=n)lo=mid;else hi=mid-1n;}return lo;}
function intended(hex,value){
 const bs=Buffer.from(hex.slice(2),'hex'),size=BigInt(bs.length);
 if(value!==0n)return {reason:'Nonzero',expected:''};
 if(size<4n)return {reason:'Short',expected:''};
 if(bs.subarray(0,4).toString('hex')!==selector)throw new Error('Unknown fixture selector');
 if(size<36n)return {reason:'Args',expected:''};
 const input=BigInt('0x'+bs.subarray(4,36).toString('hex'));
 return {reason:'Success',expected:word(rootFloor(input)),input:input.toString()};
}
const results=[];
for(const [ordinal,x] of examples.entries()){
 const model=intended(x.data,x.value),trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:x.data,value:'0x'+x.value.toString(16),gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const name=x.name+'.json',actual=trace.returnValue.replace(/^0x/,'');
 const expectedFailure=model.reason!=='Success',last=trace.structLogs.at(-1),nat=x=>BigInt('0x'+x.replace(/^0x/,''));
 const memory=last.memory.map(x=>x.replace(/^0x/,'')).join('');
 const returnOffset=nat(last.stack.at(-1)),returnLength=nat(last.stack.at(-2));
 const passed=trace.failed===expectedFailure&&actual===model.expected&&last.op===(expectedFailure?'REVERT':'RETURN')&&returnLength===(expectedFailure?0n:32n)&&(expectedFailure?returnOffset===0n:memory.slice(Number(returnOffset*2n),Number((returnOffset+32n)*2n))===model.expected);
 writeFileSync(resolve(out,name),JSON.stringify({ordinal,name:x.name,data:x.data,value:x.value.toString(),runtimeSha256:digest,candidate:Boolean(candidate),model,trace},null,2)+'\n');results.push({ordinal,name:x.name,reason:model.reason,trace:name,expected:model.expected,actual,passed,instructions:trace.structLogs.length});
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu'),viem=fileURLToPath(import.meta.resolve('viem'));
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),viemEntry:viem,viemEntrySha256:sha(readFileSync(viem)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
if(results.some(x=>!x.passed))throw new Error('Wrong physical sqrt receipt');console.log('PASS: '+results.length+' complete physical sqrt raw admission/integer-root receipts; native universal correspondence remains open');
