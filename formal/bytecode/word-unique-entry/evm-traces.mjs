// Development independent unique-word byte oracle and complete physical uniqueness observations.
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
const call=(payload,ordered,offset=64,gap='',tail='')=>'0xb58889b6'+word(offset)+word(ordered)+gap+word(payload.length/2)+payload+tail;
const bytesOutput=payload=>word(32)+word(payload.length/2)+payload;
const body=(name,xs,ordered,offset=64,gap='',tail='')=>{
 const original=xs.map(word),ids=original.map((_,i)=>i).filter(i=>ordered?i===0||original[i-1]!==original[i]:original.indexOf(original[i])===i),selected=ids.map(i=>original[i]);
 return {name,ordered,original,ids,selected,start:offset+36,data:call(original.join(''),ordered,offset,gap,tail),expected:bytesOutput(selected.join('')),failed:false,kind:'Body'};
};
const patterns=[Array(17).fill(7n),[3n,3n,7n,7n,11n,11n],[3n,7n,3n,11n,7n,3n],[11n,7n,3n,11n,3n],[0n,0n,(1n<<256n)-1n,0n,(1n<<256n)-1n],Array.from({length:65},(_,i)=>BigInt(i%3))];
const cases=[
 ...[0,1].flatMap(ordered=>[0,1,2,3,17,65].map(n=>body('n'+n+'-ordered'+ordered,Array.from({length:n},(_,i)=>3n+BigInt(i)*7n),ordered))),
 ...[0,1].map(ordered=>body('full-word-domain-ordered'+ordered,[0n,(1n<<256n)-1n,1n<<255n,0x123456789abcdefn],ordered)),
 ...[0,1].flatMap(ordered=>patterns.map((xs,i)=>body('pattern'+i+'-ordered'+ordered,xs,ordered))),
 ...[0,1].flatMap(ordered=>[
  body('loose-misaligned-offset-ordered'+ordered,[3n,7n,3n],ordered,65,'cd'),
  body('dirty-unused-gap-ordered'+ordered,[3n,7n,3n],ordered,96,'cd'.repeat(32)),
  body('trailing-bytes-ordered'+ordered,[3n,7n,3n],ordered,64,'','ffabcd')]),
 ...[0,1].map(ordered=>({name:'overlapping-empty-ordered'+ordered,ordered,original:[],ids:[],selected:[],start:36,data:'0xb58889b6'+word(0)+word(ordered)+'ff',expected:bytesOutput(''),failed:false,kind:'Body'})),
 ...[0,1].flatMap(ordered=>[1,31,33,63,65,127].map(n=>({name:'unaligned-'+n+'-ordered'+ordered,data:call('ab'.repeat(n),ordered),expected:'a949d285'+word(n),failed:true,kind:'Unaligned'}))),
 ...Array.from({length:64},(_,n)=>({name:'short-bytes-head-'+n,kind:'HeadShort',data:'0xb58889b6'+'ff'.repeat(n),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((head,i)=>({name:'large-offset-'+i,kind:'OffsetLarge',data:'0xb58889b6'+word(head)+word(0)+word(0),expected:'',failed:true})),
 ...[96n,(1n<<64n)-1n].map((head,i)=>({name:'short-length-header-'+i,kind:'HeaderShort',data:'0xb58889b6'+word(head)+word(0)+word(0),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((len,i)=>({name:'large-length-'+i,kind:'LengthLarge',data:'0xb58889b6'+word(64)+word(0)+word(len),expected:'',failed:true})),
 {name:'short-payload-one',kind:'TailShort',data:'0xb58889b6'+word(64)+word(0)+word(1),expected:'',failed:true},
 {name:'short-payload-word',kind:'TailShort',data:'0xb58889b6'+word(64)+word(0)+word(96)+word(3)+word(7),expected:'',failed:true},
 ...[2n,(1n<<256n)-1n].map((ordered,i)=>({name:'noncanonical-bool-'+i,kind:'BoolNoncanonical',data:call('ab'.repeat(33),ordered),expected:'',failed:true})),
 ...[
  ['HeadShort','0xb58889b6'+word(64)+word(2).slice(0,62)],
  ['OffsetLarge','0xb58889b6'+word(1n<<64n)+word(2)+word(0)],
  ['HeaderShort','0xb58889b6'+word(96)+word(2)+word(0)],
  ['LengthLarge','0xb58889b6'+word(64)+word(2)+word(1n<<64n)],
  ['TailShort','0xb58889b6'+word(64)+word(2)+word(96)+word(3)]
 ].map(([kind,data])=>({name:'malformed-before-bool-'+kind,kind,data,expected:'',failed:true})),
 ...[1n,(1n<<256n)-1n].map((value,i)=>({name:'nonzero-value-'+i,kind:'Nonzero',value:'0x'+word(value),data:call('',0),expected:'',failed:true})),
 ...[0,1,2,3].map(n=>({name:'short-calldata-'+n,kind:'Short',data:'0x'+'ff'.repeat(n),expected:'',failed:true}))
];
const c=await network.connect('hardhatMainnet'),p=c.provider,a=await p.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003800';await p.request({method:'hardhat_setCode',params:[target,code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>x.memory.map(w=>w.replace(/^0x/,'')).join(''),results=[];
const selected=options['--case']?cases.filter(x=>x.name===options['--case']):cases;if(selected.length!==(options['--case']?1:131))throw Error('Wrong fixture inventory '+selected.length);
const path=(folder,name)=>JSON.parse(readFileSync(resolve(root,'formal/bytecode/'+folder+'/'+name+'.mapping.json'))).states.map(x=>x.pc);
for(const item of selected){
 const trace=await p.request({method:'debug_traceCall',params:[{from:a[0],to:target,gas:'0x989680',data:item.data,value:item.value??'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');
 const logs=trace.structLogs,actual=trace.returnValue.replace(/^0x/,''),errors=[];
 if(trace.failed!==item.failed||actual!==item.expected)errors.push('Complete status/byte receipt differs');
 if(!logs.length||logs[0].pc!==0||logs.some(x=>x.depth!==1))errors.push('Incomplete physical frame');
 const last=logs.at(-1),off=Number(nat(last.stack.at(-1))),size=Number(nat(last.stack.at(-2)));
 if(last.op!==(item.failed?'REVERT':'RETURN')||size!==item.expected.length/2||memory(last).slice(off*2,(off+size)*2)!==item.expected)errors.push('Physical terminal memory slice differs');
 let pcs;
 const seg=name=>path('word-unique/segments',name),helper=name=>path('word-unique/kernels',name),entry=name=>path('word-unique/entry',name);
 if(['Nonzero','Short'].includes(item.kind))pcs=path('rejections','Collections'+item.kind);
 else {
  pcs=path('word-unique/prefix','Prefix');
  if(['HeadShort','OffsetLarge','HeaderShort','LengthLarge','TailShort','BoolNoncanonical'].includes(item.kind))pcs=pcs.concat(path('word-unique/raw-decoder','Raw'+item.kind));
  else {
   pcs=pcs.concat(path('word-unique/decoder','Decoder'),entry('BodyStart'),helper('Mod'));
   if(item.kind==='Unaligned')pcs=pcs.concat(entry('Unaligned'));
   else {
    pcs=pcs.concat(entry('Aligned'),entry('AllocationGuard'),path('word-unique/allocation',item.original.length===0?'AllocateEmpty':'AllocateNonempty'));
    if(item.original.length!==0)pcs=pcs.concat([6714],path('word-unique/allocation','AfterCopy'));
    let retained=[];
    for(let i=0;i<item.original.length;i++){
     pcs=pcs.concat(seg('Start'),helper('Div32'),seg('ReadPrepare'),helper('Mul32'),seg('AfterPosition'),helper('Mul32'),seg('AfterOtherPosition'),helper('Add'),seg('AfterEnd'),helper('Slice'),seg('AfterSlice'),helper('Read32'));
     const value=item.original[i];let seen;
     if(item.ordered){
      seen=retained.length!==0&&retained.at(-1)===value;
      if(!retained.length)pcs=pcs.concat(seg('OrderedEmpty'));
      else pcs=pcs.concat(seg('OrderedPrepare'),helper('Sub1'),path('word-unique/word-at','WordAt'),seg(seen?'OrderedEqual':'OrderedDifferent'));
     }else{
      seen=false;pcs=pcs.concat(seg('UnorderedStart'));
      for(const old of retained){pcs=pcs.concat(seg('UnorderedRead'));if(old===value){seen=true;pcs=pcs.concat(seg('UnorderedHit'));break;}pcs=pcs.concat(seg('UnorderedMiss'));}
      if(!seen)pcs=pcs.concat(seg('UnorderedDone'));
     }
     if(seen)pcs=pcs.concat(seg('Skip'));
     else{pcs=pcs.concat(seg('StorePrepare'),helper('Inc1'),seg('StoreTail'));retained.push(value);}
    }
    pcs=pcs.concat(seg('Start'),helper('Div32'),seg('Exit'),path('capacity-return','Control'));
   }
  }
 }
 if(JSON.stringify(logs.map(x=>x.pc))!==JSON.stringify(pcs))errors.push('Complete actual instruction path differs');
 if(!item.failed){
  const capacity=BigInt(item.original.length),kept=BigInt(item.selected.length),writes=logs.filter(x=>x.pc===6923);
  if(writes.length!==Number(kept)||writes.some((x,i)=>nat(x.stack.at(-1))!==160n+BigInt(i)*32n||nat(x.stack.at(-2))!==BigInt('0x'+item.selected[i])))errors.push('Original selected-word physical stores differ');
  const begin=logs.find(x=>x.pc===6724),heap='00'.repeat(64)+word(160n+capacity*32n)+'00'.repeat(32)+word(capacity*32n)+'00'.repeat(Number(capacity)*32);
  if(!begin||memory(begin)!==heap||JSON.stringify(begin.stack.map(x=>nat(x).toString()))!==JSON.stringify([0xb58889b6n,518n,BigInt(item.start),capacity*32n,BigInt(item.ordered),128n,0n,0n].map(String)))errors.push('Exact initial loop frame/heap differs');
  const shrinks=logs.filter(x=>x.pc===6941);
  if(shrinks.length!==1||nat(shrinks[0].stack.at(-1))!==128n||nat(shrinks[0].stack.at(-2))!==kept*32n)errors.push('Actual output-header shrink operands differ');
  const serializer=logs.find(x=>x.pc===518),finalHeap='00'.repeat(64)+word(160n+capacity*32n)+'00'.repeat(32)+word(kept*32n)+item.selected.join('')+'00'.repeat(Number(capacity-kept)*32);
  if(!serializer||memory(serializer)!==finalHeap)errors.push('Shrunk payload and preserved allocation capacity differ');
  const copies=logs.filter(x=>x.op==='MCOPY');
  if(copies.length!==1||nat(copies[0].stack.at(-1))!==224n+capacity*32n||nat(copies[0].stack.at(-2))!==160n||nat(copies[0].stack.at(-3))!==kept*32n)errors.push('Physical serializer copy operands differ');
 }
 results.push({name:item.name,kind:item.kind,passed:errors.length===0,receiptPassed:trace.failed===item.failed&&actual===item.expected,errors,expectedBytes:item.expected,actualBytes:actual,expectedFailed:item.failed,actualFailed:trace.failed,trace:item.name+'.json'});
}
await c.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete physical EVM receipts');process.exitCode=results.every(x=>x.passed)?0:1;
