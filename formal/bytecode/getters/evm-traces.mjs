// Execute complete constant getter calls in the local in-process EDR.
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import { network } from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const candidate=process.argv[3]??null;
const artifact=JSON.parse(readFileSync('artifacts/contracts/Assertions.sol/Assertions.json'));
const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode;
const sha=bytes=>createHash('sha256').update(bytes).digest('hex');
const digest=sha(Buffer.from(runtime.slice(2),'hex'));
const frozen=JSON.parse(readFileSync(new URL('../dispatch/inventory.json',import.meta.url))).Assertions;
if (!candidate && digest!==frozen.runtimeSha256) throw new Error('Runtime drift');
const connection=await network.connect('hardhatMainnet');const provider=connection.provider;
const target='0x0000000000000000000000000000000000002200';
await provider.request({method:'hardhat_setCode',params:[target,runtime]});
const accounts=await provider.request({method:'eth_accounts'});const results=[];
for (const [name,selector,last] of [['LEN','694464da',0],['PAYLOAD','268e878d',1]]) {
 const expected='80'+'00'.repeat(30)+last.toString(16).padStart(2,'0');
 const mapping=JSON.parse(readFileSync(new URL('./'+name+'.mapping.json',import.meta.url)));
 if (mapping.runtimeSha256!==frozen.runtimeSha256 || mapping.selector!==selector) throw new Error('Certificate drift');
 const tails=['','ff'.repeat(28),'00'.repeat(28),'123456','a5'.repeat(511),'00'.repeat(32)+'ff'.repeat(96)];
 for (const [ordinal,tail] of tails.entries()) {
  const data='0x'+selector+tail;
  const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data,value:'0x0',gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
  const filename=name+'-'+ordinal+'.json';
  writeFileSync(resolve(out,filename),JSON.stringify({name,data,runtimeSha256:digest,candidate:Boolean(candidate),expected,trace},null,2)+'\n');
  if (trace.failed || trace.returnValue.replace(/^0x/,'')!==expected) throw new Error('Wrong EVM getter return '+name+'/'+ordinal);
  if (JSON.stringify(trace.structLogs.map(r=>r.pc))!==JSON.stringify(mapping.states.map(s=>s.pc))) throw new Error('Reached complete PC path differs');
  if (trace.structLogs.some(r=>r.depth!==1)) throw new Error('Unexpected external observation');
  const stores=trace.structLogs.filter(r=>r.op==='MSTORE');const nat=v=>BigInt('0x'+v.replace(/^0x/,''));
  if (stores.length!==2 || nat(stores[0].stack.at(-1))!==64n || nat(stores[0].stack.at(-2))!==128n || nat(stores[1].stack.at(-1))!==128n || nat(stores[1].stack.at(-2))!==BigInt('0x'+expected)) throw new Error('Physical memory store trace differs');
  const ret=trace.structLogs.at(-1);const bytes=ret.memory.map(w=>w.replace(/^0x/,'')).join('');
  if (ret.op!=='RETURN' || nat(ret.stack.at(-1))!==128n || nat(ret.stack.at(-2))!==32n || bytes.slice(256,320)!==expected) throw new Error('Physical RETURN frame differs');
  results.push({name,ordinal,data,trace:filename,instructions:trace.structLogs.length,passed:true});
 }
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat'));const edr=createRequire(hh).resolve('@nomicfoundation/edr');const binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log('PASS: '+results.length+' complete exact-runtime getter return/memory fixtures');
