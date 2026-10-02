// Independent exact iota receipts and complete physical runtime traces.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createHash} from 'node:crypto';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
const options={};for(let i=2;i<process.argv.length;i+=2){if(!['--output','--root','--runtime','--case'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad harness arguments');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']);mkdirSync(out,{recursive:true});
const sha=x=>createHash('sha256').update(x).digest('hex'),word=n=>BigInt(n).toString(16).padStart(64,'0');
const baseline=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Collections.sol/Collections.json'))).deployedBytecode;
const frozen=JSON.parse(readFileSync(resolve(root,'formal/bytecode/dispatch/inventory.json'))).Collections;
if(sha(Buffer.from(baseline.slice(2),'hex'))!==frozen.runtimeSha256)throw Error('Baseline runtime drift');
const candidate=options['--runtime']??null,code=candidate?'0x'+readFileSync(candidate).toString('hex'):baseline,digest=sha(Buffer.from(code.slice(2),'hex'));
const call=(n,tail='')=>'0x8d27f48d'+word(n)+tail;
const result=n=>word(32)+word(n*32)+Array.from({length:n},(_,i)=>word(i)).join('');
const cases=[
 ...[0,1,2,3,17,65].map(n=>({name:['empty','one','two','three','seventeen','sixty-five'][[0,1,2,3,17,65].indexOf(n)],n:BigInt(n),data:call(n),result:result(n)})),
 {name:'two-with-trailing-bytes',n:2n,data:call(2,'ffabcd'),result:result(2)},
 {name:'three-with-full-trailing-word',n:3n,data:call(3,'ff'.repeat(32)),result:result(3)},
 ...[
  ['allocation-first',1n<<59n,65],['allocation-next',(1n<<59n)+1n,65],['allocation-last',(1n<<251n)-1n,65],
  ['multiply-first',1n<<251n,17],['multiply-next',(1n<<251n)+1n,17],['word-maximum',(1n<<256n)-1n,17],
  ['large-allocation-word',(1n<<200n)+0x123456789abcdefn,65]
 ].map(([name,n,panic])=>({name,n,panic,data:call(n),error:'4e487b71'+word(panic)})),
 ...Array.from({length:32},(_,n)=>({name:'short-scalar-head-'+n,kind:'HeadShort',data:'0x8d27f48d'+'ff'.repeat(n),error:''})),
 {name:'nonzero-value',kind:'Nonzero',data:call(2),value:'0x1',error:''},
 {name:'maximum-value',kind:'Nonzero',data:call(0),value:'0x'+word((1n<<256n)-1n),error:''},
 ...[0,1,2,3].map(n=>({name:'short-calldata-'+n,kind:'Short',data:'0x'+'ff'.repeat(n),error:''}))
];
const selected=options['--case']?cases.filter(x=>x.name===options['--case']):cases;if(selected.length!==(options['--case']?1:53))throw Error('Wrong fixture inventory');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003700';await provider.request({method:'hardhat_setCode',params:[target,code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>x.memory.map(w=>w.replace(/^0x/,'')).join('');
const path=(folder,name)=>JSON.parse(readFileSync(resolve(root,'formal/bytecode/'+folder+'/'+name+'.mapping.json'))).states.map(x=>x.pc);
const results=[];
for(const item of selected){
 const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data:item.data,value:item.value??'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,runtimeSha256:digest,candidate:Boolean(candidate),trace},(_,v)=>typeof v==='bigint'?v.toString():v,2)+'\n');
 const logs=trace.structLogs,returned=trace.returnValue.replace(/^0x/,''),expectedFailed=item.error!==undefined,expectedBytes=item.error??item.result,receiptPassed=trace.failed===expectedFailed&&returned===expectedBytes;
 const errors=[];if(!receiptPassed)errors.push('Complete receipt contradicts fixed expected outcome');if(!logs.length||logs[0].pc!==0||logs.some(x=>x.depth!==1))errors.push('Incomplete physical frame');
 const stores=logs.filter(x=>x.op==='MSTORE');if(!stores.length||nat(stores[0].stack.at(-1))!==64n||nat(stores[0].stack.at(-2))!==128n)errors.push('Initial physical store differs');
 let pcs;
 if(['Nonzero','Short'].includes(item.kind))pcs=path('rejections','Collections'+item.kind);
 else{
  pcs=path('iota','Prefix');
  if(item.kind==='HeadShort')pcs=pcs.concat(path('iota','RawHead'));
  else{
   pcs=pcs.concat(path('iota','Decoder'));
   if(item.panic===17)pcs=pcs.concat(path('iota','MultiplyOverflow'),path('iota','Panic17'));
   else{
    pcs=pcs.concat(path('iota','Multiply'));
    if(item.panic===65)pcs=pcs.concat(path('iota','AllocationLimit'),path('iota','Panic41'));
    else{
     pcs=pcs.concat(path('iota','AllocationGuard'),path('iota',item.n===0n?'AllocateEmpty':'AllocateNonempty'));
     if(item.n!==0n)pcs=pcs.concat([5614],path('iota-allocation','AfterCopy'));
     for(let i=0n;i<item.n;i++)pcs=pcs.concat(path('iota-loop','Body'));
     pcs=pcs.concat(path('iota-loop','Exit'),path('iota-return','Control'));
     const start=logs.find(x=>x.pc===5623),heap='00'.repeat(64)+word(160n+item.n*32n)+'00'.repeat(32)+word(item.n*32n)+'00'.repeat(Number(item.n)*32);
     if(!start||memory(start)!==heap||JSON.stringify(start.stack.map(x=>nat(x).toString()))!==JSON.stringify([0x8d27f48dn,518n,item.n,128n,0n].map(String)))errors.push('Exact initial loop stack/heap differs');
     const writes=stores.filter(x=>x.pc===5642);if(writes.length!==Number(item.n)||writes.some((x,i)=>nat(x.stack.at(-1))!==160n+BigInt(i)*32n||nat(x.stack.at(-2))!==BigInt(i)))errors.push('Original-index word stores differ');
     const copies=logs.filter(x=>x.op==='MCOPY');if(copies.length!==1||nat(copies[0].stack.at(-1))!==224n+item.n*32n||nat(copies[0].stack.at(-2))!==160n||nat(copies[0].stack.at(-3))!==item.n*32n)errors.push('Actual serializer copy operands differ');
     const last=logs.at(-1);if(nat(last.stack.at(-1))!==160n+item.n*32n||nat(last.stack.at(-2))!==64n+item.n*32n)errors.push('Actual RETURN pointer/length differs');
    }
   }
  }
 }
 if(JSON.stringify(logs.map(x=>x.pc))!==JSON.stringify(pcs))errors.push('Complete actual instruction path differs');
 const last=logs.at(-1);if(last.op!==(expectedFailed?'REVERT':'RETURN'))errors.push('Final status opcode differs');
 if(receiptPassed){const off=Number(nat(last.stack.at(-1))),size=Number(nat(last.stack.at(-2)));if(memory(last).slice(off*2,(off+size)*2)!==expectedBytes||size!==expectedBytes.length/2)errors.push('Physical final return/error slice differs');}
 results.push({name:item.name,kind:item.kind??(item.panic?'Panic':'Body'),trace:item.name+'.json',receiptPassed,expectedFailed,expectedBytes,actualFailed:trace.failed,actualBytes:returned,passed:errors.length===0,errors});
}
await connection.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete physical EVM receipts');process.exitCode=results.every(x=>x.passed)?0:1;
