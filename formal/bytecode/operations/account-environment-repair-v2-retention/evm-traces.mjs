// Complete physical history-indexed getter fixtures. Truthful history is explicit.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});const candidate=process.argv[3]??null;
const art=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json'));const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):art.deployedBytecode;
const sha=x=>createHash('sha256').update(x).digest('hex');const digest=sha(Buffer.from(runtime.slice(2),'hex'));const inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));if(!candidate&&digest!==inventory.runtimeSha256)throw new Error('Runtime drift');
const c=await network.connect('hardhatMainnet');const p=c.provider;const target='0x0000000000000000000000000000000000002295';const accounts=await p.request({method:'eth_accounts'});
await p.request({method:'hardhat_setCode',params:[target,runtime]});
const profiles=[{account:123n,balance:1n,code:'0x'},{account:456n,balance:999n,code:'0x600160005260206000f3'},{account:(1n<<160n)-1n,balance:17n,code:'0xfe'},{account:789n,balance:1n<<255n,code:'0x00'}];
const observations={};
for(const f of profiles){
 const address='0x'+f.account.toString(16).padStart(40,'0');await p.request({method:'hardhat_setBalance',params:[address,'0x'+f.balance.toString(16)]});await p.request({method:'hardhat_setCode',params:[address,f.code]});
 const balance=await p.request({method:'eth_getBalance',params:[address,'latest']});const code=await p.request({method:'eth_getCode',params:[address,'latest']});const codeHash=await p.request({method:'web3_sha3',params:[code]});
 if(BigInt(balance)!==f.balance||code!==f.code)throw new Error('Wrong injected account observation');observations[f.account.toString()]={address,balance,code,codeHash,existenceNote:'Injected positive balance establishes an existing account; empty code has the empty-code hash, not the absent-account zero hash.'};
}
const indexes=profiles.map(f=>f.account);writeFileSync(resolve(out,'context.json'),JSON.stringify({observations,observationNote:'Faithful actual BALANCE and EXTCODEHASH observations remain theorem parameters. No consensus or cryptographic hash implementation/property theorem is inferred.'},null,2)+'\n');
const results=[];let failures=0;
for(const name of ['Balance','CodeHash']){
 const mapping=JSON.parse(readFileSync(new URL('../account-environment-repair-v2/'+name+'.mapping.json',import.meta.url)));
 for(const [ordinal,index] of indexes.entries())for(const [tailOrdinal,tail] of ['','ff'.repeat(17),'a5'.repeat(211)].entries()){
  const obs=observations[index.toString()];const expected=(name==='Balance'?BigInt(obs.balance).toString(16).padStart(64,'0'):obs.codeHash.slice(2));
  const data='0x'+mapping.selector+index.toString(16).padStart(64,'0')+tail;
  const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data,value:'0x0',gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
  const file=name+'-'+ordinal+'-'+tailOrdinal+'.json';writeFileSync(resolve(out,file),JSON.stringify({name,ordinal,tailOrdinal,index:index.toString(),data,expected,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');
  const actual=trace.returnValue.replace(/^0x/,'');if(trace.failed||actual!==expected){failures++;results.push({name,ordinal,tailOrdinal,trace:file,expected,actual,passed:false});continue;}
  if(JSON.stringify(trace.structLogs.map(s=>s.pc))!==JSON.stringify(mapping.states.map(s=>s.pc))||trace.structLogs.some(s=>s.depth!==1))throw new Error('Full PC path differs');
  const ret=trace.structLogs.at(-1),nat=x=>BigInt('0x'+x.replace(/^0x/,''));if(ret.op!=='RETURN'||nat(ret.stack.at(-1))!==128n||nat(ret.stack.at(-2))!==32n||ret.memory.map(w=>w.replace(/^0x/,'')).join('').slice(256,320)!==expected)throw new Error('Wrong physical return');
  const stores=trace.structLogs.filter(s=>s.op==='MSTORE');if(stores.length!==2||nat(stores[1].stack.at(-1))!==128n||nat(stores[1].stack.at(-2))!==BigInt('0x'+expected))throw new Error('Wrong physical output word');
  results.push({name,ordinal,tailOrdinal,index:index.toString(),data,trace:file,instructions:trace.structLogs.length,passed:true});
 }
}
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');if(failures)throw new Error('Wrong EVM account environment output: '+failures+' semantic failures');console.log('PASS: '+results.length+' complete physical account environment receipts');
