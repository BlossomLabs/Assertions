// Fixed independent expected receipts for full sum entry geometries and faults.
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
const call=(head,payload,tail='')=>'0x1787098b'+word(head)+'00'.repeat(Math.max(0,Number(head)-32))+word(payload.length/2)+payload+tail;
const cases=[
 {name:'empty',data:call(32,''),head:32n,length:0n,result:word(0)},
 {name:'zero-offset-empty',data:'0x1787098b'+word(0),head:0n,length:0n,result:word(0)},
 {name:'one',data:call(32,word(19)),head:32n,length:32n,result:word(19)},
 {name:'three',data:call(32,[3,7,13].map(word).join('')),head:32n,length:96n,result:word(23)},
 {name:'loose-offset',data:call(47,word(11),'abcd'),head:47n,length:32n,result:word(11)},
 {name:'no-payload-padding',data:call(32,'ff'),head:32n,length:1n,error:'a949d285'+word(1)},
 {name:'overflow',data:call(32,word((1n<<256n)-1n)+word(1)),head:32n,length:64n,error:'4e487b71'+word(17)},
 {name:'many',data:call(32,Array.from({length:65},(_,i)=>word(i)).join(''),'ff'),head:32n,length:2080n,result:word(2080)},
 {name:'selector-only',kind:'HeadShort',data:'0x1787098b',error:''},
 {name:'short-head-last-byte',kind:'HeadShort',data:'0x1787098b'+'ff'.repeat(31),error:''},
 {name:'offset-64-bit-overflow',kind:'OffsetLarge',data:'0x1787098b'+word(1n<<64n),error:''},
 {name:'offset-full-word',kind:'OffsetLarge',data:'0x1787098b'+word((1n<<256n)-1n)+word(0),error:''},
 {name:'missing-length',kind:'HeaderShort',data:'0x1787098b'+word(32),error:''},
 {name:'length-one-byte-short',kind:'HeaderShort',data:'0x1787098b'+word(32)+'00'.repeat(31),error:''},
 {name:'length-64-bit-overflow',kind:'LengthLarge',data:'0x1787098b'+word(32)+word(1n<<64n),error:''},
 {name:'length-full-word',kind:'LengthLarge',data:'0x1787098b'+word(32)+word((1n<<256n)-1n),error:''},
 {name:'missing-one-byte-tail',kind:'TailShort',data:'0x1787098b'+word(32)+word(1),error:''},
 {name:'partial-tail',kind:'TailShort',data:'0x1787098b'+word(32)+word(64)+'ff'.repeat(31),error:''},
 {name:'nonzero-value',kind:'Nonzero',data:call(32,word(19)),value:'0x1',error:''},
 {name:'full-width-value',kind:'Nonzero',data:'0x1787098b',value:'0x'+word((1n<<256n)-1n),error:''},
 ...[0,1,2,3].map(n=>({name:'short-'+n,kind:'Short',data:'0x'+'ff'.repeat(n),error:''}))
];
const selected=options['--case']?cases.filter(x=>x.name===options['--case']):cases;if(selected.length!==(options['--case']?1:24))throw Error('Wrong fixture inventory');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003600';await provider.request({method:'hardhat_setCode',params:[target,code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>x.memory.map(w=>w.replace(/^0x/,'')).join(''),results=[];
for(const item of selected){
 const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data:item.data,value:item.value??'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,runtimeSha256:digest,candidate:Boolean(candidate),trace},(_,v)=>typeof v==='bigint'?v.toString():v,2)+'\n');
 const logs=trace.structLogs,returned=trace.returnValue.replace(/^0x/,''),expectedFailed=item.error!==undefined,expectedBytes=item.error??item.result,receiptPassed=trace.failed===expectedFailed&&returned===expectedBytes;
 const errors=[];if(!receiptPassed)errors.push('Complete receipt contradicts fixed expected outcome');if(logs.some(x=>x.depth!==1))errors.push('Unexpected call depth');
 const stores=logs.filter(x=>x.op==='MSTORE');if(!stores.length||nat(stores[0].stack.at(-1))!==64n||nat(stores[0].stack.at(-2))!==128n)errors.push('Initial physical memory store differs');
 const mapping=(name,raw=false)=>JSON.parse(readFileSync(resolve(root,'formal/bytecode/'+(raw?'scans/raw-decoder/':'scans/')+name+'.mapping.json')));
 if(['Nonzero','Short'].includes(item.kind)){
  const m=JSON.parse(readFileSync(resolve(root,'formal/bytecode/rejections/Collections'+item.kind+'.mapping.json'))),last=logs.at(-1);
  if(JSON.stringify(logs.map(x=>x.pc))!==JSON.stringify(m.states.map(x=>x.pc))||stores.length!==1||last.op!=='REVERT'||memory(last)!=='00'.repeat(64)+word(128))errors.push('Physical pre-ABI rejection trace differs');
 }else{
  const start=logs.findIndex(x=>x.pc===585),prefix=mapping('Prefix');if(start<0||JSON.stringify(logs.slice(0,start).map(x=>x.pc))!==JSON.stringify(prefix.states.map(x=>x.pc)))errors.push('Complete PC-zero route differs');
  if(item.kind){
   const m=mapping('Raw'+item.kind,true),last=logs.at(-1);if(start<0||JSON.stringify(logs.slice(start).map(x=>x.pc))!==JSON.stringify(m.states.map(x=>x.pc))||stores.length!==1||last.op!=='REVERT'||nat(last.stack.at(-1))!==0n||nat(last.stack.at(-2))!==0n||memory(last)!=='00'.repeat(64)+word(128))errors.push('Physical raw bytes decoder rejection differs');
  }else{
   const end=logs.findIndex((x,i)=>i>start&&x.pc===2767),m=mapping('SumDecoder');if(start<0||end<0||JSON.stringify(logs.slice(start,end).map(x=>x.pc))!==JSON.stringify(m.states.map(x=>x.pc)))errors.push('Actual accepted decoder path differs');
   if(end>=0){const entry=logs[end],stack=[0x1787098bn,604n,item.head+36n,item.length];if(entry.stack.length!==4||entry.stack.some((v,i)=>nat(v)!==stack[i])||memory(entry)!=='00'.repeat(64)+word(128))errors.push('Actual decoded stack/memory differs');}
  }
 }
 const last=logs.at(-1);if(last.op!==(expectedFailed?'REVERT':'RETURN'))errors.push('Final status opcode differs');
 if(receiptPassed){const off=Number(nat(last.stack.at(-1))),size=Number(nat(last.stack.at(-2)));if(memory(last).slice(off*2,(off+size)*2)!==expectedBytes||size!==expectedBytes.length/2)errors.push('Physical return/error slice differs');}
 results.push({name:item.name,kind:item.kind??'Body',trace:item.name+'.json',receiptPassed,expectedFailed,expectedBytes,actualFailed:trace.failed,actualBytes:returned,passed:errors.length===0,errors});
}
await connection.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete physical EVM receipts');process.exitCode=results.every(x=>x.passed)?0:1;
