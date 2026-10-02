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
await p.request({method:'hardhat_setCode',params:[target,runtime]});await p.request({method:'hardhat_mine',params:['0x104']});
const head=await p.request({method:'eth_getBlockByNumber',params:['latest',false]});
const numberSelector=inventory.publicEntries.find(e=>e.signature==='blockNumber()').selector;
const numberTrace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data:'0x'+numberSelector,value:'0x0',gas:'0x186a0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
const numberAt=numberTrace.structLogs.map((s,i)=>[s,i]).filter(([s])=>s.op==='NUMBER');if(numberAt.length!==1||numberTrace.failed)throw new Error('Missing actual execution NUMBER observation');
const height=BigInt('0x'+numberTrace.structLogs[numberAt[0][1]+1].stack.at(-1).replace(/^0x/,''));
if(height!==BigInt(head.number)||height<258n||BigInt('0x'+numberTrace.returnValue.replace(/^0x/,''))!==height)throw new Error('Local header/NUMBER receipt differs');
writeFileSync(resolve(out,'execution-number.json'),JSON.stringify({runtimeSha256:digest,selector:numberSelector,number:height.toString(),trace:numberTrace},null,2)+'\n');
const indexes=[0n,1n,2n,height-257n,height-256n,height-1n,height,height+1n,(1n<<256n)-1n];const history={};
const recent=Array.from({length:256},(_,i)=>height-256n+BigInt(i));
await Promise.all(recent.map(async index=>{const b=await p.request({method:'eth_getBlockByNumber',params:['0x'+index.toString(16),false]});if(!b||BigInt(b.number)!==index)throw new Error('Missing exact recent history block');history[index.toString()]=b.hash;}));
writeFileSync(resolve(out,'context.json'),JSON.stringify({head,executionBlockNumber:height.toString(),history,blobHashes:[],blobObservationNote:'These debug_traceCall fixtures have no executed transaction blobs. A separate development capability probe returned zero despite supplied blobVersionedHashes; no positive blob receipt is claimed. Arbitrary truthful blob sequences are native theorem parameters.'},null,2)+'\n');
const results=[];let failures=0;
for(const name of ['BlockHash','BlobHash']){
 const mapping=JSON.parse(readFileSync(new URL('../indexed-environment/'+name+'.mapping.json',import.meta.url)));
 for(const [ordinal,index] of indexes.entries())for(const [tailOrdinal,tail] of ['','ff'.repeat(17),'a5'.repeat(211)].entries()){
  const expected=(name==='BlockHash'&&index<height&&height-index<=256n?history[index.toString()]: '0x'+'0'.repeat(64)).slice(2);
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
await c.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');if(failures)throw new Error('Wrong EVM indexed environment output: '+failures+' semantic failures');console.log('PASS: '+results.length+' complete physical indexed environment receipts');
