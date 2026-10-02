// Complete exact-runtime physical direct environment getter receipts.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
import {createHash} from 'node:crypto';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});const candidate=process.argv[3]??null;
const art=JSON.parse(readFileSync('artifacts/contracts/Operations.sol/Operations.json'));const runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):art.deployedBytecode;
const digest=createHash('sha256').update(Buffer.from(runtime.slice(2),'hex')).digest('hex');
const inventory=JSON.parse(readFileSync(new URL('../inventory.json',import.meta.url)));if(!candidate&&digest!==inventory.runtimeSha256)throw new Error('Runtime drift');
const connection=await network.connect('hardhatMainnet');const p=connection.provider;const target='0x0000000000000000000000000000000000002294';
await p.request({method:'hardhat_setCode',params:[target,runtime]});const accounts=await p.request({method:'eth_accounts'});
const block=await p.request({method:'eth_getBlockByNumber',params:['latest',false]});const chainId=await p.request({method:'eth_chainId'});
// The local zero-excess-blob genesis fixture pins one concrete blob fee value.
// General blob fee calculation is outside the truthful World-observation premise.
if(BigInt(block.excessBlobGas??'0x0')!==0n)throw new Error('Expected zero-excess local genesis fixture');
const gasPrice=17_000_000_000n;
const values={BaseFee:0n,BlobBaseFee:1n,BlockNumber:BigInt(block.number),ChainId:BigInt(chainId),GasLimit:BigInt(block.gasLimit),GasPrice:gasPrice,PrevRandao:BigInt(block.mixHash),Timestamp:BigInt(block.timestamp)};
writeFileSync(resolve(out,'context.json'),JSON.stringify({block,chainId,baseFeeExecutionObservation:'Local Hardhat debug_traceCall BASEFEE is zero in these calls; RPC latest header base fee is separately recorded and is not assumed equal to execution observation.',gasPrice:gasPrice.toString(),worldValues:Object.fromEntries(Object.entries(values).map(([k,v])=>[k,v.toString()]))},null,2)+'\n');
const results=[];let failures=0;
for(const [name,value] of Object.entries(values)){
 const mapping=JSON.parse(readFileSync(new URL('../environment/'+name+'.mapping.json',import.meta.url)));const expected=value.toString(16).padStart(64,'0');
 for(const [ordinal,tail] of ['','ff'.repeat(28),'a5'.repeat(333)].entries()){
  const data='0x'+mapping.selector+tail;
  const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,data,value:'0x0',gas:'0x186a0',gasPrice:'0x'+gasPrice.toString(16)},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
  const file=name+'-'+ordinal+'.json';writeFileSync(resolve(out,file),JSON.stringify({name,ordinal,data,expected,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');
  const actual=trace.returnValue.replace(/^0x/,'');if(trace.failed||actual!==expected){failures++;results.push({name,ordinal,trace:file,expected,actual,passed:false});continue;}
  if(JSON.stringify(trace.structLogs.map(s=>s.pc))!==JSON.stringify(mapping.states.map(s=>s.pc))||trace.structLogs.some(s=>s.depth!==1))throw new Error('Full PC path differs');
  const ret=trace.structLogs.at(-1);if(ret.op!=='RETURN'||BigInt('0x'+ret.stack.at(-1).replace(/^0x/,''))!==128n||BigInt('0x'+ret.stack.at(-2).replace(/^0x/,''))!==32n||ret.memory.map(w=>w.replace(/^0x/,'')).join('').slice(256,320)!==expected)throw new Error('Physical RETURN differs');
  const stores=trace.structLogs.filter(s=>s.op==='MSTORE');if(stores.length!==2||BigInt('0x'+stores[1].stack.at(-1).replace(/^0x/,''))!==128n||BigInt('0x'+stores[1].stack.at(-2).replace(/^0x/,''))!==value)throw new Error('Physical output store differs');
  results.push({name,ordinal,trace:file,data,instructions:trace.structLogs.length,passed:true});
 }
}
const sha=bytes=>createHash('sha256').update(bytes).digest('hex');
const hh=fileURLToPath(import.meta.resolve('hardhat'));const edr=createRequire(hh).resolve('@nomicfoundation/edr');const binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync('pnpm-lock.yaml'))},null,2)+'\n');
await connection.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');if(failures)throw new Error('Wrong EVM environment output: '+failures+' semantic failures');console.log('PASS: '+results.length+' complete physical exact-runtime environment receipts');
