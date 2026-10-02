// Independent original-byte interleaving oracle and complete physical two-input entry observations.
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
const selector='0x1008e959',bytesOutput=payload=>word(32)+word(payload.length/2)+payload;
const canonical=(a,b)=>selector+word(64)+word(96+a.length/2)+word(a.length/2)+a+word(b.length/2)+b;
const custom=(a,b,ha,hb,gap='aa',tail='')=>{
 const raw=Buffer.alloc(Math.max(64,ha+32+a.length/2,hb+32+b.length/2),parseInt(gap,16));
 raw.set(Buffer.from(word(ha),'hex'),0);raw.set(Buffer.from(word(hb),'hex'),32);
 raw.set(Buffer.from(word(a.length/2)+a,'hex'),ha);raw.set(Buffer.from(word(b.length/2)+b,'hex'),hb);
 return selector+raw.toString('hex')+tail;
};
const body=(name,xs,ys,ha=64,hb=96+xs.length*32,gap='aa',tail='')=>{
 const originalA=xs.map(word),originalB=ys.map(word),selected=originalA.flatMap((w,i)=>[w,originalB[i]]);
 return {name,originalA,originalB,selected,startA:ha+36,startB:hb+36,data:custom(originalA.join(''),originalB.join(''),ha,hb,gap,tail),expected:bytesOutput(selected.join('')),failed:false,kind:'Body'};
};
const bodyCases=[
 ...[0,1,2,3,17,65].map(n=>body('n'+n,Array.from({length:n},(_,i)=>3n+BigInt(i)*7n),Array.from({length:n},(_,i)=>11n+BigInt(i)*13n))),
 body('full-word-domain',[0n,(1n<<256n)-1n,1n<<255n,0x123456789abcdefn],[(1n<<256n)-1n,0n,0x76543210n,1n]),
 ...[1,3].map(n=>body('overlap-n'+n,Array.from({length:n},(_,i)=>BigInt(i)*17n+3n),Array.from({length:n},(_,i)=>BigInt(i)*17n+3n),64,64)),
 body('loose-first-head',[3n,7n],[11n,17n],65,192),
 body('reverse-head-order',[3n,7n],[11n,17n],160,64),
 body('trailing-bytes',[3n,7n],[11n,17n],64,160,'aa','ffabcd'),
 {name:'overlapping-empty-head',originalA:[],originalB:[],selected:[],startA:36,startB:36,data:selector+word(0)+word(0)+'ff',expected:bytesOutput(''),failed:false,kind:'Body'},
 body('loose-second-head',[3n,7n],[11n,17n],64,161),
 body('dirty-both-gaps',[3n],[11n],96,256,'cd'),
 body('misaligned-overlap',[3n],[3n],65,65)
];
const cases=[...bodyCases,
 ...['A','B'].flatMap(side=>[1,31,33,63,65,127].map(n=>({name:'unaligned-'+side+'-'+n,data:canonical(side==='A'?'ab'.repeat(n):'',side==='B'?'cd'.repeat(n):''),expected:'a949d285'+word(n),failed:true,kind:side==='A'?'FirstUnaligned':'SecondUnaligned'}))),
 ...[1,33].map(n=>({name:'both-unaligned-priority-'+n,data:canonical('ab'.repeat(n),'cd'.repeat(7)),expected:'a949d285'+word(n),failed:true,kind:'FirstUnaligned'})),
 ...[[0,1],[1,0],[2,1],[1,2]].map(([na,nb])=>({name:'count-mismatch-'+na+'-'+nb,data:canonical(Array.from({length:na},(_,i)=>word(3+i)).join(''),Array.from({length:nb},(_,i)=>word(11+i)).join('')),expected:toFunctionSelector('WordCountMismatch(uint256,uint256)').slice(2)+word(na)+word(nb),failed:true,kind:'CountMismatch'})),
 ...Array.from({length:64},(_,n)=>({name:'short-bytes-head-'+n,kind:'HeadShort',data:selector+'ff'.repeat(n),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((head,i)=>({name:'first-large-offset-'+i,kind:'FirstOffsetLarge',data:selector+word(head)+word(64)+word(0),expected:'',failed:true})),
 ...[96n,(1n<<64n)-1n].map((head,i)=>({name:'first-short-header-'+i,kind:'FirstHeaderShort',data:selector+word(head)+word(64)+word(0),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((len,i)=>({name:'first-large-length-'+i,kind:'FirstLengthLarge',data:selector+word(64)+word(96)+word(len),expected:'',failed:true})),
 ...[1,96].map((len,i)=>({name:'first-short-tail-'+i,kind:'FirstTailShort',data:selector+word(64)+word(96)+word(len),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((head,i)=>({name:'second-large-offset-'+i,kind:'SecondOffsetLarge',data:selector+word(64)+word(head)+word(0),expected:'',failed:true})),
 ...[96n,(1n<<64n)-1n].map((head,i)=>({name:'second-short-header-'+i,kind:'SecondHeaderShort',data:selector+word(64)+word(head)+word(0),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((len,i)=>({name:'second-large-length-'+i,kind:'SecondLengthLarge',data:selector+word(64)+word(128)+word(32)+word(3)+word(len),expected:'',failed:true})),
 ...[1,96].map((len,i)=>({name:'second-short-tail-'+i,kind:'SecondTailShort',data:selector+word(64)+word(128)+word(32)+word(3)+word(len),expected:'',failed:true})),
 ...[1n,(1n<<256n)-1n].map((value,i)=>({name:'nonzero-value-'+i,kind:'Nonzero',value:'0x'+word(value),data:canonical('',''),expected:'',failed:true})),
 ...[0,1,2,3].map(n=>({name:'short-calldata-'+n,kind:'Short',data:'0x'+'ff'.repeat(n),expected:'',failed:true}))
];
const c=await network.connect('hardhatMainnet'),p=c.provider,a=await p.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003800';await p.request({method:'hardhat_setCode',params:[target,code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>x.memory.map(w=>w.replace(/^0x/,'')).join(''),results=[];
const selected=options['--case']?cases.filter(x=>x.name===options['--case']):cases;if(selected.length!==(options['--case']?1:120))throw Error('Wrong fixture inventory '+selected.length);
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
  pcs=path('word-zip','Prefix');
  if(['HeadShort','FirstOffsetLarge','FirstHeaderShort','FirstLengthLarge','FirstTailShort','SecondOffsetLarge','SecondHeaderShort','SecondLengthLarge','SecondTailShort'].includes(item.kind))pcs=pcs.concat(path('word-zip/raw-decoder','Raw'+item.kind));
  else {
   pcs=pcs.concat(path('word-zip/decoder','Decoder'),path('word-zip/entry','BodyStart'),path('word-zip/loop','Mod'));
   if(item.kind==='FirstUnaligned')pcs=pcs.concat(path('word-zip/entry','FirstUnaligned'));
   else {
    pcs=pcs.concat(path('word-zip/entry','FirstAligned'),path('word-zip/loop','Mod'));
    if(item.kind==='SecondUnaligned')pcs=pcs.concat(path('word-zip/entry','SecondUnaligned'));
    else if(item.kind==='CountMismatch')pcs=pcs.concat(path('word-zip/alignment-b','SecondAligned'),path('word-zip/entry','MismatchFirstDivide'),path('word-zip/loop','Div32'),path('word-zip/entry','MismatchSecondDivide'),path('word-zip/loop','Div32'),path('word-zip/entry','CountMismatch'));
    else {
     pcs=pcs.concat(path('word-zip/entry','BothAlignedEqual'),path('word-zip/entry','DivideCount'),path('word-zip/loop','Div32'),path('word-zip/entry','Multiply'),path('word-zip/loop','Mul2'),path('word-zip/entry','AllocationGuard'),path('word-zip/allocation',item.originalA.length===0?'AllocateEmpty':'AllocateNonempty'));
     if(item.originalA.length!==0)pcs=pcs.concat([2085],path('word-zip/allocation','AfterCopy'));
     for(let i=0;i<item.originalA.length;i++)for(const name of ['Guard','Mul32','AfterPositionAStart','Mul32','AfterPositionAEnd','Add','AfterEndA','Slice','AfterSliceA','Read32','AfterReadA','Mul32','AfterPositionBStart','Mul32','AfterPositionBEnd','Add','AfterEndB','Slice','AfterSliceB','Read32','Tail'])pcs=pcs.concat(path('word-zip/loop',name));
     pcs=pcs.concat(path('word-zip/loop','Exit'),path('bytes-return','Control'));
    }
   }
  }
 }
 if(JSON.stringify(logs.map(x=>x.pc))!==JSON.stringify(pcs))errors.push('Complete actual instruction path differs');
 if(!item.failed){
  const n=BigInt(item.selected.length),writes=logs.filter(x=>x.pc===2237||x.pc===2253);
  if(writes.length!==Number(n)||writes.some((x,i)=>nat(x.stack.at(-1))!==160n+BigInt(i)*32n||nat(x.stack.at(-2))!==BigInt('0x'+item.selected[i])))errors.push('Original selected-word physical stores differ');
  const begin=logs.find(x=>x.pc===2094),heap='00'.repeat(64)+word(160n+n*32n)+'00'.repeat(32)+word(n*32n)+'00'.repeat(Number(n)*32);
  if(!begin||memory(begin)!==heap||JSON.stringify(begin.stack.map(x=>nat(x).toString()))!==JSON.stringify([0x1008e959n,518n,BigInt(item.startA),BigInt(item.originalA.length)*32n,BigInt(item.startB),BigInt(item.originalB.length)*32n,128n,BigInt(item.originalA.length),0n].map(String)))errors.push('Exact initial loop frame/heap differs');
  const copies=logs.filter(x=>x.op==='MCOPY');
  if(copies.length!==1||nat(copies[0].stack.at(-1))!==224n+n*32n||nat(copies[0].stack.at(-2))!==160n||nat(copies[0].stack.at(-3))!==n*32n)errors.push('Physical serializer copy operands differ');
 }
 results.push({name:item.name,kind:item.kind,passed:errors.length===0,receiptPassed:trace.failed===item.failed&&actual===item.expected,errors,expectedBytes:item.expected,actualBytes:actual,expectedFailed:item.failed,actualFailed:trace.failed,trace:item.name+'.json'});
}
await c.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete physical EVM receipts');process.exitCode=results.every(x=>x.passed)?0:1;
