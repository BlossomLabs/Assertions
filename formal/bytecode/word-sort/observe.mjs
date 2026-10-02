// Development independent stable numeric-sort oracle and full physical observations; not proof evidence.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {toFunctionSelector} from 'viem';
const options={};for(let i=2;i<process.argv.length;i+=2){if(!['--output','--root','--runtime','--case'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad harness arguments');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']);mkdirSync(out,{recursive:true});
const baseline=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Collections.sol/Collections.json'))).deployedBytecode;
const candidate=options['--runtime']??null,code=candidate?'0x'+readFileSync(candidate).toString('hex'):baseline;
const word=n=>BigInt(n).toString(16).padStart(64,'0'),sha=x=>createHash('sha256').update(x).digest('hex');
const frozen=JSON.parse(readFileSync(resolve(root,'formal/bytecode/dispatch/inventory.json'))).Collections;
if(sha(Buffer.from(baseline.slice(2),'hex'))!==frozen.runtimeSha256)throw Error('Canonical runtime drift');
const digest=sha(Buffer.from(code.slice(2),'hex'));
const call=payload=>'0x2ed74f49'+word(32)+word(payload.length/2)+payload;
const body=(name,xs)=>{const original=xs.map(word),indices=xs.map((_,i)=>i).sort((a,b)=>xs[a]<xs[b]?-1:xs[a]>xs[b]?1:a-b),selected=indices.map(i=>original[i]);return {name,original,indices,selected,data:call(original.join('')),expected:word(32)+word(selected.length*32)+selected.join(''),failed:false,kind:'Body'};};
const cases=[
 ...[0,1,2,3,4,5,9,17].map(n=>body('descending-n'+n,Array.from({length:n},(_,i)=>BigInt(n-i)*7n))),
 ...[0,1,2,3,4,5,9,17].map(n=>body('ascending-n'+n,Array.from({length:n},(_,i)=>BigInt(i)*7n))),
 ...[2,3,5,9,17].map(n=>body('duplicates-n'+n,Array.from({length:n},(_,i)=>BigInt(i%3)))),
 body('full-domain',[0n,(1n<<256n)-1n,1n<<255n,0n,(1n<<256n)-1n,1n]),
 ...[1,31,33,63,65].map(n=>({name:'unaligned-'+n,data:call('ab'.repeat(n)),expected:'a949d285'+word(n),failed:true,kind:'Unaligned'}))
];
const c=await network.connect('hardhatMainnet'),p=c.provider,a=await p.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003800';await p.request({method:'hardhat_setCode',params:[target,code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>x.memory.map(w=>w.replace(/^0x/,'')).join(''),results=[];
const selected=options['--case']?cases.filter(x=>x.name===options['--case']):cases;if(selected.length!==(options['--case']?1:27))throw Error('Wrong fixture inventory '+selected.length);
const path=(folder,name)=>JSON.parse(readFileSync(resolve(root,'formal/bytecode/'+folder+'/'+name+'.mapping.json'))).states.map(x=>x.pc);
for(const item of selected){
 const trace=await p.request({method:'debug_traceCall',params:[{from:a[0],to:target,gas:'0x989680',data:item.data,value:item.value??'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');
 const logs=trace.structLogs,actual=trace.returnValue.replace(/^0x/,''),errors=[];
 if(trace.failed!==item.failed||actual!==item.expected)errors.push('Complete status/byte receipt differs');
 if(!logs.length||logs[0].pc!==0||logs.some(x=>x.depth!==1))errors.push('Incomplete physical frame');
 const last=logs.at(-1),off=Number(nat(last.stack.at(-1))),size=Number(nat(last.stack.at(-2)));
 if(last.op!==(item.failed?'REVERT':'RETURN')||size!==item.expected.length/2||memory(last).slice(off*2,(off+size)*2)!==item.expected)errors.push('Physical terminal memory slice differs');
 // Observation only: no extracted proof path is assumed or claimed here.
 if(!item.failed){
  const copies=logs.filter(x=>x.op==='MCOPY');
  if(!copies.length)errors.push('No physical serializer copy observed');
 }
 results.push({name:item.name,kind:item.kind,passed:errors.length===0,receiptPassed:trace.failed===item.failed&&actual===item.expected,errors,expectedBytes:item.expected,actualBytes:actual,expectedFailed:item.failed,actualFailed:trace.failed,trace:item.name+'.json'});
}
await c.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete physical EVM receipts');process.exitCode=results.every(x=>x.passed)?0:1;
