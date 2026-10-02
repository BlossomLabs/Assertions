// Independent exact reverseWords receipts and complete physical runtime traces.
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
const words=xs=>xs.map(word).join('');
const call=(payload,offset=32,tail='',gap='')=>'0xab590638'+word(offset)+gap+word(payload.length/2)+payload+tail;
const output=payload=>{const xs=payload.match(/.{64}/g)??[];return word(32)+word(payload.length/2)+xs.reverse().join('');};
const regular=[0,1,2,3,17,65].map(n=>{const xs=Array.from({length:n},(_,i)=>BigInt(i)*7n+3n),payload=words(xs);return {name:['empty','one','two','three','seventeen','sixty-five'][[0,1,2,3,17,65].indexOf(n)],n:BigInt(n),start:68n,payload,data:call(payload),result:output(payload)};});
const body=(name,xs,offset=32,tail='',gap='')=>{const payload=words(xs);return {name,n:BigInt(xs.length),start:BigInt(offset+36),payload,data:call(payload,offset,tail,gap),result:output(payload)};};
const cases=[
 ...regular,
 body('full-word-domain',[0n,(1n<<256n)-1n,1n<<255n,0x123456789abcdefn]),
 body('maximum-original-word',[(1n<<256n)-1n]),body('high-bit-original-word',[1n<<255n]),
 body('two-with-trailing-bytes',[3n,7n],32,'ffabcd'),body('three-with-full-trailing-word',[3n,7n,11n],32,'ff'.repeat(32)),
 body('misaligned-loose-offset',[3n,7n,11n],33,'','cd'),body('dirty-unused-gap',[3n,7n,11n],64,'','cd'.repeat(32)),
 {name:'empty-overlapping-head',n:0n,start:36n,payload:'',data:'0xab590638'+word(0)+'ff',result:word(32)+word(0)},
 ...[1,31,33,63,65,127].map(n=>({name:'unaligned-'+n,length:n,kind:'Unaligned',data:call('ab'.repeat(n)),error:'a949d285'+word(n)})),
 ...Array.from({length:32},(_,n)=>({name:'short-bytes-head-'+n,kind:'HeadShort',data:'0xab590638'+'ff'.repeat(n),error:''})),
 ...[1n<<64n,(1n<<256n)-1n].map((n,i)=>({name:'large-offset-'+i,kind:'OffsetLarge',data:'0xab590638'+word(n)+word(0),error:''})),
 ...[64n,(1n<<64n)-1n].map((n,i)=>({name:'short-length-header-'+i,kind:'HeaderShort',data:'0xab590638'+word(n)+word(0),error:''})),
 ...[1n<<64n,(1n<<256n)-1n].map((n,i)=>({name:'large-length-'+i,kind:'LengthLarge',data:'0xab590638'+word(32)+word(n),error:''})),
 {name:'short-payload-one',kind:'TailShort',data:'0xab590638'+word(32)+word(1),error:''},
 {name:'short-payload-word',kind:'TailShort',data:'0xab590638'+word(32)+word(96)+words([3n,7n]),error:''},
 {name:'nonzero-value',kind:'Nonzero',data:call(words([3n,7n])),value:'0x1',error:''},
 {name:'maximum-value',kind:'Nonzero',data:call(''),value:'0x'+word((1n<<256n)-1n),error:''},
 ...[0,1,2,3].map(n=>({name:'short-calldata-'+n,kind:'Short',data:'0x'+'ff'.repeat(n),error:''}))
];
const selected=options['--case']?cases.filter(x=>x.name===options['--case']):cases;if(selected.length!==(options['--case']?1:66))throw Error('Wrong fixture inventory');
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003800';await provider.request({method:'hardhat_setCode',params:[target,code]});
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
  pcs=path('word-reverse','Prefix');
  if(['HeadShort','OffsetLarge','HeaderShort','LengthLarge','TailShort'].includes(item.kind))pcs=pcs.concat(path('word-reverse/raw-decoder','Raw'+item.kind));
  else{
   pcs=pcs.concat(path('word-reverse','Decoder'),path('word-reverse/entry','BodyStart'),path('word-reverse/loop','Mod'));
   if(item.kind==='Unaligned')pcs=pcs.concat(path('word-reverse/entry','Unaligned'));
   else{
    pcs=pcs.concat(path('word-reverse/entry','Aligned'),path('word-reverse/loop','Div'),path('word-reverse/entry','Count'),path('word-reverse/allocation',item.n===0n?'AllocateEmpty':'AllocateNonempty'));
    if(item.n!==0n)pcs=pcs.concat([5837],path('word-reverse/allocation','AfterCopy'));
    for(let i=0n;i<item.n;i++)pcs=pcs.concat(path('word-reverse/loop','Guard'),path('word-reverse/loop','Mul32'),path('word-reverse/loop','AfterMulFirst'),path('word-reverse/loop','Mul32'),path('word-reverse/loop','AfterMulSecond'),path('word-reverse/loop','Add'),path('word-reverse/loop','AfterEnd'),path('word-reverse/loop','Slice'),path('word-reverse/loop','AfterSlice'),path('word-reverse/loop','Read32'),path('word-reverse/loop','Tail'));
    pcs=pcs.concat(path('word-reverse/loop','Exit'),path('bytes-return','Control'));
    const start=logs.find(x=>x.pc===5846),heap='00'.repeat(64)+word(160n+item.n*32n)+'00'.repeat(32)+word(item.n*32n)+'00'.repeat(Number(item.n)*32);
    if(!start||memory(start)!==heap||JSON.stringify(start.stack.map(x=>nat(x).toString()))!==JSON.stringify([0xab590638n,518n,item.start,item.n*32n,128n,item.n,0n].map(String)))errors.push('Exact initial loop stack/heap differs');
    const writes=stores.filter(x=>x.pc===5927),original=item.payload.match(/.{64}/g)??[];
    if(writes.length!==Number(item.n)||writes.some((x,i)=>nat(x.stack.at(-1))!==160n+(item.n-1n-BigInt(i))*32n||nat(x.stack.at(-2))!==BigInt('0x'+original[i])))errors.push('Original calldata word/reverse-index stores differ');
    const copies=logs.filter(x=>x.op==='MCOPY');if(copies.length!==1||nat(copies[0].stack.at(-1))!==224n+item.n*32n||nat(copies[0].stack.at(-2))!==160n||nat(copies[0].stack.at(-3))!==item.n*32n)errors.push('Actual serializer copy operands differ');
    const last=logs.at(-1);if(nat(last.stack.at(-1))!==160n+item.n*32n||nat(last.stack.at(-2))!==64n+item.n*32n)errors.push('Actual RETURN pointer/length differs');
    const calloc=logs.filter(x=>x.op==='CALLDATACOPY');if(calloc.length!==(item.n===0n?0:1)||calloc.some(x=>nat(x.stack.at(-1))!==160n||nat(x.stack.at(-2))!==BigInt(item.data.length/2-1)||nat(x.stack.at(-3))!==item.n*32n))errors.push('Actual zero calloc operands differ');
   }
  }
 }
 if(JSON.stringify(logs.map(x=>x.pc))!==JSON.stringify(pcs))errors.push('Complete actual instruction path differs');
 const last=logs.at(-1);if(last.op!==(expectedFailed?'REVERT':'RETURN'))errors.push('Final status opcode differs');
 if(receiptPassed){const off=Number(nat(last.stack.at(-1))),size=Number(nat(last.stack.at(-2)));if(memory(last).slice(off*2,(off+size)*2)!==expectedBytes||size!==expectedBytes.length/2)errors.push('Physical final return/error slice differs');}
 results.push({name:item.name,kind:item.kind??'Body',trace:item.name+'.json',receiptPassed,expectedFailed,expectedBytes,actualFailed:trace.failed,actualBytes:returned,passed:errors.length===0,errors});
}
await connection.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete physical EVM receipts');process.exitCode=results.every(x=>x.passed)?0:1;
