// Independent stable original-occurrence oracle and complete physical sort entry observations.
import {readFileSync,writeFileSync,mkdirSync,readdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const options={};
for(let i=2;i<process.argv.length;i+=2){if(!['--output','--root','--runtime','--case'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad harness arguments');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']);mkdirSync(out,{recursive:true});
const baseline=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Collections.sol/Collections.json'))).deployedBytecode;
const candidate=options['--runtime']??null,code=candidate?'0x'+readFileSync(candidate).toString('hex'):baseline;
const word=n=>BigInt(n).toString(16).padStart(64,'0'),sha=x=>createHash('sha256').update(x).digest('hex');
const frozen=JSON.parse(readFileSync(resolve(root,'formal/bytecode/dispatch/inventory.json'))).Collections;
if(sha(Buffer.from(baseline.slice(2),'hex'))!==frozen.runtimeSha256||frozen.methodIdentifiers['sortWords(bytes)']!=='2ed74f49')throw Error('Canonical runtime/selector drift');
const digest=sha(Buffer.from(code.slice(2),'hex')),selector='0x2ed74f49';
const call=payload=>selector+word(32)+word(payload.length/2)+payload;
const custom=(payload,head,gap='aa',tail='')=>{
 const bytes=Buffer.alloc(head+32+payload.length/2,parseInt(gap,16));
 bytes.set(Buffer.from(word(head),'hex'),0);bytes.set(Buffer.from(word(payload.length/2)+payload,'hex'),head);
 return selector+bytes.toString('hex')+tail;
};
const body=(name,xs,head=32,gap='aa',tail='')=>{
 const original=xs.map(word),indices=xs.map((_,i)=>i).sort((a,b)=>xs[a]<xs[b]?-1:xs[a]>xs[b]?1:a-b),selected=indices.map(i=>original[i]);
 return {name,original,indices,selected,start:head+36,data:custom(original.join(''),head,gap,tail),expected:word(32)+word(selected.length*32)+selected.join(''),failed:false,kind:'Body'};
};
const cases=[
 ...[0,1,2,3,4,5,9,17].map(n=>body('descending-n'+n,Array.from({length:n},(_,i)=>BigInt(n-i)*7n))),
 ...[0,1,2,3,4,5,9,17].map(n=>body('ascending-n'+n,Array.from({length:n},(_,i)=>BigInt(i)*7n))),
 ...[2,3,5,9,17].map(n=>body('duplicates-n'+n,Array.from({length:n},(_,i)=>BigInt(i%3)))),
 body('full-domain',[0n,(1n<<256n)-1n,1n<<255n,0n,(1n<<256n)-1n,1n]),
 ...[31,33].map(n=>body('descending-n'+n,Array.from({length:n},(_,i)=>BigInt(n-i)*7n))),
 body('loose-misaligned-offset',[11n,3n,7n],33),
 body('dirty-unused-gap',[11n,3n,7n],96,'cd'),
 body('trailing-bytes',[11n,3n,7n],32,'aa','ffabcd'),
 {name:'overlapping-empty-head',original:[],indices:[],selected:[],start:36,data:selector+word(0)+'ff',expected:word(32)+word(0),failed:false,kind:'Body'},
 ...[1,31,33,63,65,127].map(n=>({name:'unaligned-'+n,data:call('ab'.repeat(n)),expected:'a949d285'+word(n),failed:true,kind:'Unaligned'})),
 ...Array.from({length:32},(_,n)=>({name:'short-bytes-head-'+n,kind:'HeadShort',data:selector+'ff'.repeat(n),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((head,i)=>({name:'large-offset-'+i,kind:'OffsetLarge',data:selector+word(head)+word(0),expected:'',failed:true})),
 ...[64n,(1n<<64n)-1n].map((head,i)=>({name:'short-length-header-'+i,kind:'HeaderShort',data:selector+word(head)+word(0),expected:'',failed:true})),
 ...[1n<<64n,(1n<<256n)-1n].map((len,i)=>({name:'large-length-'+i,kind:'LengthLarge',data:selector+word(32)+word(len),expected:'',failed:true})),
 ...[1,32].map(len=>({name:'short-payload-'+len,kind:'TailShort',data:selector+word(32)+word(len),expected:'',failed:true})),
 ...[1n,(1n<<256n)-1n].map((value,i)=>({name:'nonzero-value-'+i,kind:'Nonzero',value:'0x'+word(value),data:call(''),expected:'',failed:true})),
 ...[0,1,2,3].map(n=>({name:'short-calldata-'+n,kind:'Short',data:'0x'+'ff'.repeat(n),expected:'',failed:true}))
];
// Segment certificates cover every observed opcode. COPY instructions between
// generated segment boundaries have separate native memory/step connections.
const folders=['prefix','decoder','raw-decoder','entry','kernels','copy-allocation','scratch-allocation-repair','segments','word-at','set-word','mul2-swap','serializer'];
const paths=folders.flatMap(folder=>readdirSync(resolve(root,'formal/bytecode/word-sort',folder)).filter(n=>n.endsWith('.mapping.json')).map(name=>JSON.parse(readFileSync(resolve(root,'formal/bytecode/word-sort',folder,name))).states.map(x=>x.pc)));
paths.push([3510],[3602]);
for(const kind of ['Nonzero','Short'])paths.push(JSON.parse(readFileSync(resolve(root,'formal/bytecode/rejections/Collections'+kind+'.mapping.json'))).states.map(x=>x.pc));
const byStart=new Map();for(const path of paths){if(!byStart.has(path[0]))byStart.set(path[0],[]);byStart.get(path[0]).push(path);}
const covered=pcs=>{
 const good=new Uint8Array(pcs.length+1);good[pcs.length]=1;
 for(let i=pcs.length-1;i>=0;i--)for(const path of byStart.get(pcs[i])??[])if(i+path.length<=pcs.length&&good[i+path.length]&&path.every((pc,j)=>pcs[i+j]===pc)){good[i]=1;break;}
 return good[0]===1;
};
// Independently simulate stable merge decisions over occurrence IDs; compare
// every real scratch MSTORE address/value, rather than only the final answer.
const writesFor=item=>{
 const n=item.original.length,writes=[];let source=Array.from({length:n},(_,i)=>i),scratch=Array(n).fill(null),right=false;
 for(let width=1;width<n;width*=2){
  const base=right?128:160+n*32;
  for(let start=0;start<n;start+=2*width){
   const mid=Math.min(start+width,n),end=Math.min(start+2*width,n);let a=start,b=mid;
   for(let dest=start;dest<end;dest++){
    const left=a<mid&&(b===end||BigInt('0x'+item.original[source[a]])<=BigInt('0x'+item.original[source[b]]));
    const id=source[left?a++:b++];scratch[dest]=id;writes.push({address:BigInt(base+32+dest*32),value:BigInt('0x'+item.original[id])});
   }
  }
  [source,scratch]=[scratch,source];right=!right;
 }
 return {writes,out:right?160+n*32:128,indices:source};
};
const c=await network.connect('hardhatMainnet'),p=c.provider,a=await p.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003800';await p.request({method:'hardhat_setCode',params:[target,code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>x.memory.map(w=>w.replace(/^0x/,'')).join(''),results=[];
const selected=options['--case']?cases.filter(x=>x.name===options['--case']):cases;if(selected.length!==(options['--case']?1:80))throw Error('Wrong fixture inventory '+selected.length);
for(const item of selected){
 const trace=await p.request({method:'debug_traceCall',params:[{from:a[0],to:target,gas:'0x989680',data:item.data,value:item.value??'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');
 const logs=trace.structLogs,actual=trace.returnValue.replace(/^0x/,''),errors=[];
 if(trace.failed!==item.failed||actual!==item.expected)errors.push('Complete status/byte receipt differs');
 if(!logs.length||logs[0].pc!==0||logs.some(x=>x.depth!==1))errors.push('Incomplete physical frame');
 const last=logs.at(-1),off=Number(nat(last.stack.at(-1))),size=Number(nat(last.stack.at(-2)));
 if(last.op!==(item.failed?'REVERT':'RETURN')||size!==item.expected.length/2||memory(last).slice(off*2,(off+size)*2)!==item.expected)errors.push('Physical terminal memory slice differs');
 if(!covered(logs.map(x=>x.pc)))errors.push('Complete actual opcode path is not covered by certified segments');
 if(item.kind==='Body'){
  const n=item.original.length,extent=192+2*n*32,expected=writesFor(item),writes=logs.filter(x=>x.pc===3858);
  if(JSON.stringify(expected.indices)!==JSON.stringify(item.indices))throw Error('Independent sort/merge occurrence oracles disagree');
  if(writes.length!==expected.writes.length||writes.some((x,i)=>nat(x.stack.at(-1))!==expected.writes[i].address||nat(x.stack.at(-2))!==expected.writes[i].value))errors.push('Physical merge stores differ from independent stable decisions');
  const begin=logs.find(x=>x.pc===3612),heap='00'.repeat(64)+word(extent)+'00'.repeat(32)+word(n*32)+item.original.join('')+word(n*32)+'00'.repeat(n*32);
  if(!begin||memory(begin)!==heap||JSON.stringify(begin.stack.map(x=>nat(x).toString()))!==JSON.stringify([0x2ed74f49n,518n,BigInt(item.start),BigInt(n*32),128n,BigInt(n),BigInt(160+n*32),1n].map(String)))errors.push('Exact initial two-buffer frame/heap differs');
  const ret=logs.find(x=>x.pc===518),copies=logs.filter(x=>x.op==='MCOPY');
  if(!ret||nat(ret.stack.at(-1))!==BigInt(expected.out)||copies.length!==1||nat(copies[0].stack.at(-1))!==BigInt(extent+64)||nat(copies[0].stack.at(-2))!==BigInt(expected.out+32)||nat(copies[0].stack.at(-3))!==BigInt(n*32))errors.push('Actual output buffer/MCOPY operands differ');
 }
 results.push({name:item.name,kind:item.kind,passed:errors.length===0,receiptPassed:trace.failed===item.failed&&actual===item.expected,errors,expectedBytes:item.expected,actualBytes:actual,expectedFailed:item.failed,actualFailed:trace.failed,trace:item.name+'.json'});
}
await c.close();const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete physical EVM receipts');process.exitCode=results.every(x=>x.passed)?0:1;
