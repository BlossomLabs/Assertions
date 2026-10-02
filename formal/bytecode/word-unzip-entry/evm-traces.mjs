// Development independent lane byte oracle and complete physical output observations.
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
const call=(payload,lane,offset=64,gap='',tail='')=>'0xb2303db4'+word(offset)+word(lane)+gap+word(payload.length/2)+payload+tail;
const bytesOutput=payload=>word(32)+word(payload.length/2)+payload;
const body=(name,xs,lane,offset=64,gap='',tail='')=>{const original=xs.map(word),selected=original.filter((_,index)=>index%2===lane);return {name,lane,original,selected,start:offset+36,data:call(original.join(''),lane,offset,gap,tail),expected:bytesOutput(selected.join('')),failed:false,kind:'Body'};};
const cases=[
 ...[0,1].flatMap(lane=>[0,1,2,3,17,65].map(n=>body('n'+n+'-lane'+lane,Array.from({length:n},(_,i)=>3n+BigInt(i)*7n),lane))),
 ...[0,1].map(lane=>body('full-word-domain-lane'+lane,[0n,(1n<<256n)-1n,1n<<255n,0x123456789abcdefn],lane)),
 body('loose-misaligned-offset',[3n,7n,11n],0,65,'cd'),
 body('dirty-unused-gap',[3n,7n,11n],1,96,'cd'.repeat(32)),
 body('trailing-bytes',[3n,7n,11n],0,64,'','ffabcd'),
 ...[0,1].map(lane=>({name:'overlapping-empty-lane'+lane,lane,original:[],selected:[],start:36,data:'0xb2303db4'+word(0)+word(lane)+'ff',expected:bytesOutput(''),failed:false,kind:'Body'})),
 ...[1,31,33,63,65,127].map(n=>({name:'unaligned-'+n,data:call('ab'.repeat(n),0),expected:'a949d285'+word(n),failed:true,kind:'Unaligned'})),
 ...[2n,(1n<<256n)-1n].map((lane,i)=>({name:'invalid-lane-'+i,data:call('',lane),expected:toFunctionSelector('InvalidLane(uint256)').slice(2)+word(lane),failed:true,kind:'InvalidLane'})),
 ...Array.from({length:64},(_,n)=>({name:'short-bytes-head-'+n,kind:'HeadShort',data:'0xb2303db4'+'ff'.repeat(n),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((head,i)=>({name:'large-offset-'+i,kind:'OffsetLarge',data:'0xb2303db4'+word(head)+word(0)+word(0),expected:'',failed:true})),
 ...[96n,(1n<<64n)-1n].map((head,i)=>({name:'short-length-header-'+i,kind:'HeaderShort',data:'0xb2303db4'+word(head)+word(0)+word(0),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((len,i)=>({name:'large-length-'+i,kind:'LengthLarge',data:'0xb2303db4'+word(64)+word(0)+word(len),expected:'',failed:true})),
 {name:'short-payload-one',kind:'TailShort',data:'0xb2303db4'+word(64)+word(0)+word(1),expected:'',failed:true},
 {name:'short-payload-word',kind:'TailShort',data:'0xb2303db4'+word(64)+word(0)+word(96)+word(3)+word(7),expected:'',failed:true},
 ...[1n,(1n<<256n)-1n].map((value,i)=>({name:'nonzero-value-'+i,kind:'Nonzero',value:'0x'+word(value),data:call('',0),expected:'',failed:true})),
 ...[0,1,2,3].map(n=>({name:'short-calldata-'+n,kind:'Short',data:'0x'+'ff'.repeat(n),expected:'',failed:true}))
];
const c=await network.connect('hardhatMainnet'),p=c.provider,a=await p.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003800';await p.request({method:'hardhat_setCode',params:[target,code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>x.memory.map(w=>w.replace(/^0x/,'')).join(''),results=[];
const selected=options['--case']?cases.filter(x=>x.name===options['--case']):cases;if(selected.length!==(options['--case']?1:105))throw Error('Wrong fixture inventory '+selected.length);
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
 if(['Nonzero','Short'].includes(item.kind))pcs=path('rejections','Collections'+item.kind);
 else {
  pcs=path('word-unzip','Prefix');
  if(['HeadShort','OffsetLarge','HeaderShort','LengthLarge','TailShort'].includes(item.kind))pcs=pcs.concat(path('word-unzip/raw-decoder','Raw'+item.kind));
  else {
   pcs=pcs.concat(path('word-unzip/decoder','Decoder'),path('word-unzip/entry','BodyStart'),path('word-unzip/loop','Mod'));
   if(item.kind==='Unaligned')pcs=pcs.concat(path('word-unzip/entry','Unaligned'));
   else {
    pcs=pcs.concat(path('word-unzip/entry','Aligned'));
    if(item.kind==='InvalidLane')pcs=pcs.concat(path('word-unzip/entry','InvalidLane'));
    else {
     pcs=pcs.concat(path('word-unzip/entry','LaneChecked'),path('word-unzip/entry','Divide'),path('word-unzip/loop','Div32'));
     if(item.lane===0)pcs=pcs.concat(path('word-unzip/entry','WhichZero'),path('word-unzip/loop','Add'),path('word-unzip/entry','DivideZero'),path('word-unzip/loop','Div2'));
     else pcs=pcs.concat(path('word-unzip/entry','WhichOne'),path('word-unzip/loop','Div2'),path('word-unzip/entry','CountOne'));
     pcs=pcs.concat(path('word-unzip/entry','Multiply'),path('word-unzip/loop','Mul32'),path('word-unzip/entry','AllocationGuard'),path('word-unzip/allocation',item.selected.length===0?'AllocateEmpty':'AllocateNonempty'));
     if(item.selected.length!==0)pcs=pcs.concat([6153],path('word-unzip/allocation','AfterCopy'));
     for(let i=0;i<item.selected.length;i++)for(const name of ['Guard','Mul2','AfterMulTwiceA','Add','AfterLaneA','Mul32','AfterPositionA','Mul2','AfterMulTwiceB','Add','AfterLaneB','Mul32','AfterPositionB','Add','AfterEnd','Slice','AfterSlice','Read32','Tail'])pcs=pcs.concat(path('word-unzip/loop',name));
     pcs=pcs.concat(path('word-unzip/loop','Exit'),path('bytes-return','Control'));
    }
   }
  }
 }
 if(JSON.stringify(logs.map(x=>x.pc))!==JSON.stringify(pcs))errors.push('Complete actual instruction path differs');
 if(!item.failed){
  const n=BigInt(item.selected.length),writes=logs.filter(x=>x.pc===6282);
  if(writes.length!==Number(n)||writes.some((x,i)=>nat(x.stack.at(-1))!==160n+BigInt(i)*32n||nat(x.stack.at(-2))!==BigInt('0x'+item.selected[i])))errors.push('Original selected-word physical stores differ');
  const begin=logs.find(x=>x.pc===6162),heap='00'.repeat(64)+word(160n+n*32n)+'00'.repeat(32)+word(n*32n)+'00'.repeat(Number(n)*32);
  if(!begin||memory(begin)!==heap||JSON.stringify(begin.stack.map(x=>nat(x).toString()))!==JSON.stringify([0xb2303db4n,518n,BigInt(item.start),BigInt(item.original.length)*32n,BigInt(item.lane),128n,BigInt(item.original.length),n,0n].map(String)))errors.push('Exact initial loop frame/heap differs');
  const copies=logs.filter(x=>x.op==='MCOPY');
  if(copies.length!==1||nat(copies[0].stack.at(-1))!==224n+n*32n||nat(copies[0].stack.at(-2))!==160n||nat(copies[0].stack.at(-3))!==n*32n)errors.push('Physical serializer copy operands differ');
 }
 results.push({name:item.name,kind:item.kind,passed:errors.length===0,receiptPassed:trace.failed===item.failed&&actual===item.expected,errors,expectedBytes:item.expected,actualBytes:actual,expectedFailed:item.failed,actualFailed:trace.failed,trace:item.name+'.json'});
}
await c.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete physical EVM receipts');process.exitCode=results.every(x=>x.passed)?0:1;
