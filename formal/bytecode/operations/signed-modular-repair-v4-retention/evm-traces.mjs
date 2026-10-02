// Full physical development fixtures only; no universal or public proof credit.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { network } from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const candidate=process.argv[3]??null;
const art=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json'));
const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):art.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const inv=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
if(!candidate&&digest!==inv.runtimeSha256)throw new Error('Runtime drift');
const M=1n<<256n,H=M/2n,word=x=>((x%M+M)%M).toString(16).padStart(64,'0');
const families=[['AddModS','289b860c','addMod(int256,int256,int256)',false],['MulModS','3daa08a5','mulMod(int256,int256,int256)',true]];
const values=[-H,-H+1n,-456n,-123n,-1n,0n,1n,123n,456n,H-2n,H-1n];
const triples=[];
for(const a of values)for(const b of values)for(const m of [-H,-7n,0n,1n,7n,H-1n])triples.push([a,b,m]);
const panic='4e487b71'+word(18n),fixtures=[];
for(const [name,selector,signature,product] of families){
 if(inv.compilerIdentity.methodIdentifiers[signature]!==selector)throw new Error('Selector drift');
 for(const [ordinal,[a,b,m]] of triples.entries()){
  const raw=product?a*b:a+b,error=m===0n;
  const result=error?null:raw%(m<0n?-m:m);
  fixtures.push({name,ordinal,a:a.toString(),b:b.toString(),modulus:m.toString(),data:'0x'+selector+word(a)+word(b)+word(m)+(ordinal%7===0?'a5'.repeat(111):''),value:'0x0',expected:error?panic:word(result),failed:error});
 }
 for(const [ordinal,size] of [0,1,2,3,4,35,36,67,68,99].entries())fixtures.push({name:name+(size<4?'Short':'Args'),ordinal,data:'0x'+selector.slice(0,Math.min(size,4)*2)+'ff'.repeat(Math.max(0,size-4)),value:'0x0',expected:'',failed:true});
 for(const [ordinal,data] of ['',selector+word(123n)+word(456n)+word(7n)].entries())fixtures.push({name:name+'Nonzero',ordinal,data:'0x'+data,value:'0x1',expected:'',failed:true});
}
const c=await network.connect('hardhatMainnet'),p=c.provider,target='0x00000000000000000000000000000000000022b2',accounts=await p.request({method:'eth_accounts'});
await p.request({method:'hardhat_setCode',params:[target,runtime]});
const results=[];let failures=0;
for(const f of fixtures){
 const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:f.data,value:f.value,gas:'0x186a0'},'latest',{enableMemory:true,disableStack:false,disableStorage:true}]});
 const actual=trace.returnValue.replace(/^0x/,''),passed=actual===f.expected&&trace.failed===f.failed,file=f.name+'-'+f.ordinal+'.json';
 writeFileSync(resolve(out,file),JSON.stringify({...f,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');results.push({...f,actual,passed,trace:file,instructions:trace.structLogs.length});if(!passed)failures++;
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
if(failures)throw new Error('Wrong physical signed modular receipt: '+failures);
console.log('PASS development only: '+results.length+' full physical signed modular receipts; no native/public credit');
