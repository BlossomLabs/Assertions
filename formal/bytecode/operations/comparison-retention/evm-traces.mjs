// Concrete physical receipts for exact Operations comparison entry paths.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { network } from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const candidate=process.argv[3]??null;
const artifact=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json'));
const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode;
const sha=bytes=>createHash('sha256').update(bytes).digest('hex');
const digest=sha(Buffer.from(runtime.slice(2),'hex'));
const frozen=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));
if (!candidate && digest!==frozen.runtimeSha256) throw new Error('Runtime drift');
const connection=await network.connect('hardhatMainnet');const provider=connection.provider;
const target='0x0000000000000000000000000000000000002292';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const accounts=await provider.request({method:'eth_accounts'});const results=[];
const MAX=(1n<<256n)-1n;
const H=1n<<255n;const signed=x=>x<H?x:x-(1n<<256n);
const words=[[0n,0n],[0n,MAX],[MAX,0n],[MAX,MAX],[1n,2n],[2n,1n],[H-1n,H],[H,H-1n],[H,MAX],[MAX,H],[H,H],[MAX,1n],[1n,MAX],[123n,456n]];
let failures=0;
for (const [name,selector,operation] of [['Eq','32148d73',(a,b)=>BigInt(a===b)],['Ne','33151e4c',(a,b)=>BigInt(a!==b)],['LtU','118fc88c',(a,b)=>BigInt(a<b)],['GtU','21e5749b',(a,b)=>BigInt(a>b)],['LeU','d3662cfd',(a,b)=>BigInt(a<=b)],['GeU','85e1f66c',(a,b)=>BigInt(a>=b)],['LtS','30880038',(a,b)=>BigInt(signed(a)<signed(b))],['GtS','ac08973d',(a,b)=>BigInt(signed(a)>signed(b))],['LeS','00136bb8',(a,b)=>BigInt(signed(a)<=signed(b))],['GeS','6552f187',(a,b)=>BigInt(signed(a)>=signed(b))]]) {
 const mapping=JSON.parse(readFileSync(new URL('../comparison/'+name+'.mapping.json',import.meta.url)));
 if (mapping.runtimeSha256!==frozen.runtimeSha256 || mapping.selector!==selector) throw new Error('Certificate drift');
 for (const [ordinal,[a,b]] of words.entries()) {
  const expected=operation(a,b).toString(16).padStart(64,'0');
  const data='0x'+selector+a.toString(16).padStart(64,'0')+b.toString(16).padStart(64,'0')+(ordinal%3===0?'a5'.repeat(111):'');
  const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data,value:'0x0',gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
  const filename=name+'-'+ordinal+'.json';
  writeFileSync(resolve(out,filename),JSON.stringify({name,data,runtimeSha256:digest,candidate:Boolean(candidate),expected,trace},null,2)+'\n');
  const actual=trace.returnValue.replace(/^0x/,'');
  if (trace.failed || actual!==expected) { failures++;results.push({name,ordinal,passed:false,expected,actual,trace:filename});continue; }
  if (JSON.stringify(trace.structLogs.map(r=>r.pc))!==JSON.stringify(mapping.states.map(s=>s.pc))) throw new Error('Reached complete PC path differs');
  if (trace.structLogs.some(r=>r.depth!==1)) throw new Error('Unexpected external observation');
  const stores=trace.structLogs.filter(r=>r.op==='MSTORE');const nat=v=>BigInt('0x'+v.replace(/^0x/,''));
  if (stores.length!==2 || nat(stores[0].stack.at(-1))!==64n || nat(stores[0].stack.at(-2))!==128n || nat(stores[1].stack.at(-1))!==128n || nat(stores[1].stack.at(-2))!==operation(a,b)) throw new Error('Physical memory store trace differs');
  const ret=trace.structLogs.at(-1);const bytes=ret.memory.map(w=>w.replace(/^0x/,'')).join('');
  if (ret.op!=='RETURN' || nat(ret.stack.at(-1))!==128n || nat(ret.stack.at(-2))!==32n || bytes.slice(256,320)!==expected) throw new Error('Physical RETURN frame differs');
  results.push({name,ordinal,data,trace:filename,instructions:trace.structLogs.length,passed:true});
 }
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat'));const edr=createRequire(hh).resolve('@nomicfoundation/edr');const binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
if(failures) throw new Error('Wrong EVM comparison return: '+failures+' semantic failures');
console.log('PASS: '+results.length+' complete exact-runtime comparison return/memory fixtures');
