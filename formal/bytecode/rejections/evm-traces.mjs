// Full physical empty-rejection receipts in the local in-process EDR.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const candidate=process.argv[3]??null,only=process.argv[4]??null,onlyKind=process.argv[5]??null;
if(Boolean(candidate)!==Boolean(only)||Boolean(candidate)!==Boolean(onlyKind))throw new Error('Incomplete candidate arguments');
const sha=x=>createHash('sha256').update(x).digest('hex');const frozen=JSON.parse(readFileSync(new URL('../dispatch/inventory.json',import.meta.url)));
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),results=[];
for(const [ordinal,contract] of ['Assertions','Expressions','Collections'].entries()){
 if(only&&only!==contract)continue;
 const artifact=JSON.parse(readFileSync(`artifacts/contracts/${contract}.sol/${contract}.json`));const code=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode,digest=sha(Buffer.from(code.slice(2),'hex'));
 if(!candidate&&digest!==frozen[contract].runtimeSha256)throw new Error('Runtime drift');
 const target='0x'+(0x3300+ordinal).toString(16).padStart(40,'0');await provider.request({method:'hardhat_setCode',params:[target,code]});
 const selector=Object.values(frozen[contract].methodIdentifiers)[0];
 const cases=[{kind:'Nonzero',data:'0x',value:'0x1'},{kind:'Nonzero',data:'0xffffff',value:'0x101'},{kind:'Nonzero',data:'0x'+selector+'ab'.repeat(128),value:'0x10000000000000000'},...[0,1,2,3].map(n=>({kind:'Short',data:'0x'+'ff'.repeat(n),value:'0x0'}))];
 for(const [index,item] of cases.entries()){
  if(onlyKind&&onlyKind!==item.kind)continue;
  const mapping=JSON.parse(readFileSync(new URL('./'+contract+item.kind+'.mapping.json',import.meta.url)));
  const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x186a0',data:item.data,value:item.value},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
  const file=contract+'-'+index+'.json';writeFileSync(resolve(out,file),JSON.stringify({contract,case:item,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');
  if(!trace.failed||!['','0x'].includes(trace.returnValue)||trace.structLogs.at(-1).op!=='REVERT')throw new Error('Wrong EVM rejection '+contract+'/'+item.kind+'/'+index);
  const logs=trace.structLogs;const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x);
  if(JSON.stringify(logs.map(r=>r.pc))!==JSON.stringify(mapping.states.map(s=>s.pc))||logs.some(r=>r.depth!==1))throw new Error('Complete rejection PC trace differs');
  const stores=logs.filter(r=>r.op==='MSTORE');if(stores.length!==1||nat(stores[0].stack.at(-1))!==64n||nat(stores[0].stack.at(-2))!==128n)throw new Error('Physical initial store differs');
  const ret=logs.at(-1),mem=ret.memory.map(w=>w.replace(/^0x/,'')).join('');if(nat(ret.stack.at(-1))!==0n||nat(ret.stack.at(-2))!==0n||mem.length!==192||BigInt('0x'+mem.slice(128,192))!==128n||Math.max(...logs.map(r=>r.stack.length))!==3)throw new Error('Physical rejection frame differs');
  results.push({contract,kind:item.kind,index,trace:file,passed:true});
 }
}
await connection.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log('PASS: '+results.length+' complete physical empty rejection receipts');
