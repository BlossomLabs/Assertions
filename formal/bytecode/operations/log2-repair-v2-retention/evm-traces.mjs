// Complete development receipts only; native compiler-bound correspondence remains open.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {keccak256} from 'viem';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const candidate=process.argv[3]??null,art=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json'));
const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):art.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url))),selector='5456bf13';
if(!candidate&&digest!==inventory.runtimeSha256||inventory.compilerIdentity.methodIdentifiers['log2(uint256)']!==selector)throw new Error('Compiler/runtime/selector drift');
const M=1n<<256n,H=M/2n,word=x=>x.toString(16).padStart(64,'0');
const inputs=[0n,1n,2n,3n,4n,7n,8n,15n,16n,17n,(1n<<32n)-1n,1n<<32n,(1n<<64n)-1n,1n<<64n,(1n<<64n)+1n,(1n<<128n)-1n,1n<<128n,(1n<<128n)+1n,H-1n,H,H+1n,M-1n];
const errorSelector=keccak256('0x'+Buffer.from('LogarithmUndefined(int256)').toString('hex')).slice(2,10);
const fixtures=inputs.map((x,i)=>({name:x===0n?'Zero':'Positive',data:'0x'+selector+word(x)+(i%3===0?'a5'.repeat(111):''),value:'0x0',ordinal:i,input:x.toString()}));
for(const [i,size] of [0,1,2,3,4,5,35].entries())fixtures.push({name:size<4?'Short':'Args',data:'0x'+selector.slice(0,Math.min(size,4)*2)+'ff'.repeat(Math.max(0,size-4)),value:'0x0',ordinal:inputs.length+i});
for(const [i,data] of ['',selector+word(4n)].entries())fixtures.push({name:'Nonzero',data:'0x'+data,value:'0x1',ordinal:inputs.length+7+i});
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x00000000000000000000000000000000000022b1',accounts=await p.request({method:'eth_accounts'});
await p.request({method:'hardhat_setCode',params:[target,runtime]});const results=[];let failures=0;
for(const f of fixtures){
 const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:f.data,value:f.value,gas:'0x186a0'},'latest',{enableMemory:true,disableStack:false,disableStorage:true}]});
 const expected=f.name==='Positive'?word(BigInt(BigInt(f.input).toString(2).length-1)):f.name==='Zero'?errorSelector+word(0n):'';
 const actual=trace.returnValue.replace(/^0x/,''),passed=actual===expected&&trace.failed===(f.name!=='Positive'),file=f.name+'-'+f.ordinal+'.json';
 writeFileSync(resolve(out,file),JSON.stringify({...f,expected,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');results.push({...f,expected,actual,passed,trace:file,instructions:trace.structLogs.length});if(!passed)failures++;
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');if(failures)throw new Error('Wrong physical logarithm/custom-error/raw receipt: '+failures);console.log('PASS development only: '+results.length+' exact log2 physical receipts; native/public coverage remains open');
