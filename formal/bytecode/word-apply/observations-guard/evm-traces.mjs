// Development observations of the complete compiled mapWords/filterWords frames.
// These receipts guide extraction; they are not retained public proof evidence.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeErrorResult,toFunctionSelector} from 'viem';
const options={};
for(let i=2;i<process.argv.length;i+=2){if(!['--root','--output','--case','--suite'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad arguments');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Collections.sol/Collections.json'))),inventory=JSON.parse(readFileSync(resolve(root,'formal/bytecode/dispatch/inventory.json'))).Collections;
const sha=x=>createHash('sha256').update(x).digest('hex'),runtimeHash=sha(Buffer.from(artifact.deployedBytecode.slice(2),'hex'));
if(runtimeHash!==inventory.runtimeSha256)throw Error('Canonical runtime drift');
const word=n=>BigInt(n).toString(16).padStart(64,'0'),bytes=n=>Buffer.from(word(n),'hex'),max=(1n<<256n)-1n;
const self='0x0000000000000000000000000000000000004600',targetBase=0x4700n;
const addr=n=>'0x'+n.toString(16).padStart(40,'0'),signal=toFunctionSelector('SubcallOutOfGas()').slice(2);
const fixedCode=(payload,revert=false)=>{
 let code='';for(let i=0;i<payload.length;i+=64){const part=payload.slice(i,i+64).padEnd(64,'0');code+='7f'+part+'60'+(i/2).toString(16).padStart(2,'0')+'52';}
 return code+'60'+(payload.length/2).toString(16).padStart(2,'0')+'5f'+(revert?'fd':'f3');
};
const lateShortGood='5f355f5260205ff3',lateShortPrefix='5f3560021460',lateShortJump=(lateShortPrefix.length/2+2+lateShortGood.length/2).toString(16).padStart(2,'0');
const defs={
 xor:{code:'5f356001185f5260205ff3'},odd:{code:'5f356001165f5260205ff3'},echo:{code:'5f355f5260205ff3'},
 caller:{code:'335f5260205ff3'},zero:{code:fixedCode(word(0))},one:{code:fixedCode(word(1))},two:{code:fixedCode(word(2))},
 short:{code:fixedCode('ab'.repeat(31))},long:{code:fixedCode('cd'.repeat(33))},empty:{code:'5f5ff3'},
 fail:{code:fixedCode('deadbeef1234',true)},failEmpty:{code:'5f5ffd'},ordinary4:{code:fixedCode('deadbeef',true)},burn:{code:'fe'},nearBurn:{code:''},signalParentPadding:{code:fixedCode(signal,true)},signalPadding:{code:'7f'+signal+'a7'.repeat(28)+'5f5260045ffd'},signal:{code:fixedCode(signal,true)},longSignal:{code:fixedCode(signal+'11'.repeat(32),true)},
 lateShort:{code:lateShortPrefix+lateShortJump+'57'+lateShortGood+'5b5f355f52601f5ff3'},
 noCode:{code:''},precompile:{code:'',address:'0x0000000000000000000000000000000000000005'}
};
Object.entries(defs).forEach(([name,v],i)=>{v.address??=addr(targetBase+BigInt(i));});
const nestedBurn='5f5f5f5f73'+defs.burn.address.slice(2)+'5afa50';
defs.nearBurn.code=nestedBurn.repeat(2)+fixedCode('deadbeef',true);
const selectorFor=mode=>'0x'+inventory.methodIdentifiers[mode+'Words(bytes,address,bytes,uint256[])'];
if(selectorFor('map')!=='0xed6dc3be'||selectorFor('filter')!=='0x7787eb48')throw Error('Selector drift');
const pad=b=>Buffer.concat([b,Buffer.alloc((32-b.length%32)%32)]);
const canonical=(selector,payload,target,template,offsets)=>{
 const tails=[Buffer.concat([bytes(payload.length),pad(payload)]),Buffer.concat([bytes(template.length),pad(template)]),Buffer.concat([bytes(offsets.length),...offsets.map(bytes)])];
 const positions=[];let cursor=128;for(const tail of tails){positions.push(cursor);cursor+=tail.length;}
 return selector+word(positions[0])+word(BigInt(target))+word(positions[1])+word(positions[2])+Buffer.concat(tails).toString('hex');
};
const error=(name,args=[])=>encodeErrorResult({abi:artifact.abi,errorName:name,args}).slice(2);
const answer=(target,payload)=>{
 const n=BigInt('0x'+payload.subarray(0,32).toString('hex'));
 if(target==='xor')return {ok:true,returned:bytes(n^1n)};
 if(target==='odd')return {ok:true,returned:bytes(n&1n)};
 if(target==='echo')return {ok:true,returned:Buffer.from(payload.subarray(0,32))};
 if(target==='caller')return {ok:true,returned:bytes(BigInt(self))};
 if(['zero','one','two'].includes(target))return {ok:true,returned:bytes({zero:0,one:1,two:2}[target])};
 if(target==='lateShort')return {ok:true,returned:Buffer.from(payload.subarray(0,n===2n?31:32))};
 if(target==='short'||target==='long')return {ok:true,returned:Buffer.from((target==='short'?'ab'.repeat(31):'cd'.repeat(33)),'hex')};
 if(target==='empty')return {ok:true,returned:Buffer.alloc(0)};
 if(target==='burn'||target==='failEmpty')return {ok:false,returned:Buffer.alloc(0)};
 if(target==='ordinary4'||target==='nearBurn')return {ok:false,returned:Buffer.from('deadbeef','hex')};
 if(target==='signalPadding'||target==='signalParentPadding')return {ok:false,returned:Buffer.from(signal,'hex')};
 if(target==='fail')return {ok:false,returned:Buffer.from('deadbeef1234','hex')};
 if(target==='signal'||target==='longSignal')return {ok:false,returned:Buffer.from(signal+(target==='longSignal'?'11'.repeat(32):''),'hex')};
 throw Error('No admitted callback oracle for '+target);
};
const defaults={xs:[0n,1n,2n,3n,max,1n<<255n],template:'a5'.repeat(32),offsets:[0n]};
const fixtures=[];
for(const mode of ['map','filter']){
 const add=(name,patch={})=>fixtures.push({...defaults,mode,target:mode==='map'?'xor':'odd',...patch,name:mode+'-'+name});
 for(const n of [0,1,2,3,5,9,17])add('count-'+n,{xs:Array.from({length:n},(_,i)=>BigInt(i)*13n)});
 add('full-domain');add('duplicates',{xs:[1n,0n,1n,2n,3n,3n]});
 add('no-windows',{offsets:[],target:mode==='map'?'echo':'one',template:word(mode==='map'?23n:1n)});
 add('duplicate-windows',{template:'a5'.repeat(64),offsets:[0n,32n,0n]});
 add('overlapping-windows',{template:'a5'.repeat(64),offsets:[0n,7n,32n,3n]});
 add('misaligned-window',{template:'a5'.repeat(65),offsets:[1n]});
 add('last-window-boundary',{template:'a5'.repeat(65),offsets:[33n]});
 for(const target of ['noCode','precompile','signal'])add('empty-skips-'+target,{xs:[],target});
 for(const size of [0,1,31])add('empty-short-template-'+size,{xs:[],template:'ab'.repeat(size),offsets:[]});
 add('empty-invalid-window',{xs:[],offsets:[1n]});add('first-invalid-window',{template:'ab'.repeat(64),offsets:[0n,33n,max]});
 add('maximum-window',{offsets:[max]});add('nonempty-no-code',{target:'noCode'});add('nonempty-precompile',{target:'precompile'});
 for(const n of [1,31,33,63])add('unaligned-'+n,{payload:'ab'.repeat(n),template:'',offsets:[max],target:'noCode'});
 for(const target of ['empty','short','long','lateShort','fail','signal','longSignal','failEmpty','ordinary4','burn','signalPadding','nearBurn','signalParentPadding'])add('callback-'+target,{target,xs:[1n,2n,3n],...(target==='signalParentPadding'?{template:'a5'.repeat(64)}:{})});
 if(mode==='map')add('actual-caller',{target:'caller'});
 else{add('all-drop',{target:'zero'});add('all-keep',{target:'one'});add('noncanonical-predicate',{target:'two'});}
 add('trailing-calldata',{trailing:'deadbeef'});
}
// Raw ABI admission: four full heads, canonical address, fitting dynamic tails.
// Each injected class expects the compiler's empty REVERT, before body checks.
for(const mode of ['map','filter']){
 const base=fixtures.find(x=>x.name===mode+'-count-1'),selector=selectorFor(mode);
 const encode=x=>canonical(selector,Buffer.concat(x.xs.map(bytes)),defs[x.target].address,Buffer.from(x.template,'hex'),x.offsets);
 for(const n of [0,1,31,32,63,95,96,127])fixtures.push({...base,name:mode+'-raw-short-head-'+n,raw:selector+'ff'.repeat(n),rawRejected:true});
 const mutate=(name,index,value,cut=null)=>{
  const b=Buffer.from(encode(base).slice(10),'hex');bytes(value).copy(b,index*32);fixtures.push({...base,name:mode+'-raw-'+name,raw:selector+(cut===null?b:b.subarray(0,cut)).toString('hex'),rawRejected:true});
 };
 for(const index of [0,2,3]){
  mutate('offset-large-'+index,index,1n<<64n);mutate('offset-maximum-'+index,index,max);mutate('missing-length-'+index,index,4096n);
 }
 mutate('noncanonical-address',1,(1n<<160n)+BigInt(defs[base.target].address));
 // Existing tail header positions in the canonical one-word fixture.
 for(const [name,pos] of [['source',128],['template',192],['offsets',256]]){
  const b=Buffer.from(encode(base).slice(10),'hex');bytes(1n<<64n).copy(b,pos);fixtures.push({...base,name:mode+'-raw-'+name+'-large-length',raw:selector+b.toString('hex'),rawRejected:true});
  const c=Buffer.from(encode(base).slice(10),'hex');bytes(4096).copy(c,pos);fixtures.push({...base,name:mode+'-raw-'+name+'-short-tail',raw:selector+c.toString('hex'),rawRejected:true});
 }
 for(const value of [1n,max])fixtures.push({...base,name:mode+'-nonzero-value-'+value,value:'0x'+value.toString(16),rawRejected:true});
}
// Reposition dynamic tails independently: the compiler permits misaligned,
// dirty-gap and overlapping tails. Preserve these classes in the future proof.
for(const mode of ['map','filter']){
 const base=fixtures.find(x=>x.name===mode+'-count-1'),selector=selectorFor(mode);
 const payload=Buffer.concat(base.xs.map(bytes)),template=Buffer.from(base.template,'hex'),array=Buffer.concat([bytes(base.offsets.length),...base.offsets.map(bytes)]);
 const loose=(name,spos,tpos,apos,shared=false)=>{
  const tails=[[spos,Buffer.concat([bytes(payload.length),payload])],[tpos,Buffer.concat([bytes(template.length),shared?payload:template])],[apos,array]];
  const b=Buffer.alloc(Math.max(128,...tails.map(([p,t])=>p+t.length)),0xa7);
  for(const [p,t] of tails)t.copy(b,p);
  bytes(spos).copy(b,0);bytes(BigInt(defs[base.target].address)).copy(b,32);bytes(tpos).copy(b,64);bytes(apos).copy(b,96);
  fixtures.push({...base,name:mode+'-'+name,template:shared?payload.toString('hex'):base.template,raw:selector+b.toString('hex')});
 };
 loose('loose-misaligned-tails',129,201,281);loose('loose-dirty-gaps',192,320,448);loose('shared-source-template',128,128,224,true);
 // Source length zero stored in the address head, and empty offsets stored
 // in the source header: raw acceptance is not canonical ABI acceptance.
 const b=Buffer.alloc(224);bytes(32).copy(b,0);bytes(0).copy(b,32);bytes(128).copy(b,64);bytes(192).copy(b,96);bytes(32).copy(b,128);bytes(0).copy(b,192);
 fixtures.push({...base,name:mode+'-empty-overlapping-heads',xs:[],target:'noCode',targetAddress:addr(0n),template:'00'.repeat(32),offsets:[],raw:selector+b.toString('hex')});
}
const guardCases=new Set(['failEmpty','ordinary4','burn','signalPadding','nearBurn','signalParentPadding']);
if(options['--suite']&&options['--suite']!=='guard')throw Error('Unknown suite');
const selected=options['--case']?fixtures.filter(x=>x.name===options['--case']):options['--suite']==='guard'?fixtures.filter(x=>guardCases.has(x.target)&&x.name===x.mode+'-callback-'+x.target):fixtures;if(!selected.length)throw Error('Missing case');
const c=await network.connect('hardhatMainnet'),p=c.provider,[from]=await p.request({method:'eth_accounts'});
await p.request({method:'hardhat_setCode',params:[self,artifact.deployedBytecode]});
for(const [name,t] of Object.entries(defs))if(name!=='precompile')await p.request({method:'hardhat_setCode',params:[t.address,'0x'+t.code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>Buffer.from(x.memory.map(w=>w.replace(/^0x/,'')).join(''),'hex');
const results=[],pathInventory={};
for(const f of selected){
 const selector=selectorFor(f.mode),target={...defs[f.target],address:f.targetAddress??defs[f.target].address},source=f.payload===undefined?Buffer.concat(f.xs.map(bytes)):Buffer.from(f.payload,'hex'),template=Buffer.from(f.template,'hex');
 const data=f.raw??canonical(selector,source,target.address,template,f.offsets)+(f.trailing??'');
 const calls=[],output=[];let expected='',failed=true;
 if(f.rawRejected)expected='';
 else if(source.length%32!==0)expected=error('UnalignedWords',[BigInt(source.length)]);
 else if(template.length<32)expected=error('LambdaOffsetOutOfBounds',[0n,BigInt(template.length)]);
 else if(f.offsets.some(o=>o>BigInt(template.length-32)))expected=error('LambdaOffsetOutOfBounds',[f.offsets.find(o=>o>BigInt(template.length-32)),BigInt(template.length)]);
 else if(source.length>0&&['noCode','precompile'].includes(f.target))expected=error('InvalidCallbackTarget',[target.address]);
 else{
  failed=false;
  for(let i=0;i<source.length/32;i++){
   const elem=source.subarray(i*32,(i+1)*32),stamped=Buffer.from(template);for(const offset of f.offsets)elem.copy(stamped,Number(offset));
   const a=answer(f.target,stamped);calls.push({index:i,input:stamped.toString('hex'),ok:a.ok,returned:a.returned.toString('hex')});
   if(!a.ok){failed=true;expected=['signal','signalPadding','signalParentPadding','burn','nearBurn'].includes(f.target)?signal:error('CallbackFailed',[selector,BigInt(i),0n,target.address,'0x'+stamped.toString('hex'),'0x'+a.returned.toString('hex')]);break;}
   if(a.returned.length!==32||(f.mode==='filter'&&BigInt('0x'+a.returned.toString('hex'))>1n)){failed=true;expected=error('InvalidCallbackResult',[selector,BigInt(i),0n,target.address]);break;}
   if(f.mode==='map')output.push(a.returned);else if(BigInt('0x'+a.returned.toString('hex'))===1n)output.push(elem);
  }
  if(!failed){const payload=Buffer.concat(output);expected=word(32)+word(payload.length)+pad(payload).toString('hex');}
 }
 const trace=await p.request({method:'debug_traceCall',params:[{from,to:self,gas:'0x989680',data,value:f.value??'0x0'},'latest',{enableMemory:true,disableStack:false,disableStorage:true}]});
 const logs=trace.structLogs,parent=logs.filter(x=>x.depth===1),physicalCalls=parent.filter(x=>x.op==='STATICCALL'),errors=[],observations=[];
 const actual=trace.returnValue.replace(/^0x/,'');if(trace.failed!==failed||actual!==expected)errors.push('Complete return/revert receipt differs');
 if(!parent.length||parent[0].pc!==0)errors.push('Missing PC-zero frame');
 const terminal=parent.at(-1),offset=Number(nat(terminal.stack.at(-1))),size=Number(nat(terminal.stack.at(-2)));
 if(terminal.op!==(failed?'REVERT':'RETURN')||size!==expected.length/2||memory(terminal).subarray(offset,offset+size).toString('hex')!==expected)errors.push('Physical final memory slice differs');
 if(physicalCalls.length!==calls.length)errors.push('Actual callback count differs');
 for(let i=0;i<physicalCalls.length;i++){
  const call=physicalCalls[i],oracle=calls[i];if(!oracle)continue;
  const inputOffset=Number(nat(call.stack.at(-3))),inputSize=Number(nat(call.stack.at(-4))),input=memory(call).subarray(inputOffset,inputOffset+inputSize).toString('hex');
  const at=parent.indexOf(call),after=parent[at+1],begin=logs.indexOf(call),end=logs.indexOf(after),child=logs.slice(begin+1,end).filter(x=>x.depth===2),last=child.at(-1);
  const sizeAt=parent.findIndex((x,j)=>j>at&&x.op==='RETURNDATASIZE');
  if(sizeAt<0||nat(parent[sizeAt+1].stack.at(-1))!==BigInt(oracle.returned.length/2))errors.push('Actual full child returndata size differs');
  if(f.target==='signalParentPadding'){const loadAt=parent.findIndex(x=>x.pc===16123);if(loadAt<0||(nat(parent[loadAt+1].stack.at(-1))&((1n<<224n)-1n))===0n)errors.push('Exact signal fixture lacked actual nonzero parent receipt padding');}
  const burned=f.target==='burn';
  const returned=burned?'':memory(last).subarray(Number(nat(last.stack.at(-1))),Number(nat(last.stack.at(-1)))+Number(nat(last.stack.at(-2)))).toString('hex');
  if(nat(call.stack.at(-2))!==BigInt(target.address)||input!==oracle.input||nat(after.stack.at(-1))!==BigInt(oracle.ok?1:0)||last.op!==(burned?'INVALID':oracle.ok?'RETURN':'REVERT')||returned!==oracle.returned)errors.push('Physical callback '+i+' input/status/full returndata differs');
  if(['burn','nearBurn'].includes(f.target)){const beforeGas=parent.findIndex(x=>x.pc===16107),afterGas=parent.findIndex(x=>x.pc===16136);if(beforeGas<0||afterGas<0||nat(parent[afterGas+1].stack.at(-1))>nat(parent[beforeGas].stack.at(-2))/63n)errors.push('Burn fixture did not reach the exhaustion comparison');}
  observations.push({kind:'StaticCall',pc:call.pc,caller:self,target:target.address,requestedGas:nat(call.stack.at(-1)).toString(),inputOffset,inputSize,input,success:oracle.ok,returned});
 }
 for(let i=0;i<parent.length-1;i++)if(parent[i].op==='GAS')observations.push({kind:'Gas',pc:parent[i].pc,available:nat(parent[i+1].stack.at(-1)).toString()});else if(parent[i].op==='EXTCODESIZE')observations.push({kind:'CodeSize',pc:parent[i].pc,account:addr(nat(parent[i].stack.at(-1))&((1n<<160n)-1n)),size:nat(parent[i+1].stack.at(-1)).toString()});
 const decoder=parent.findIndex(x=>x.pc===22579),body=parent.findIndex(x=>x.pc===(f.mode==='map'?8729:5507));
 const rawPath=decoder>=0?parent.slice(decoder,body<0?parent.length:body).map(x=>x.pc):[];
 pathInventory[f.name]=rawPath;
 writeFileSync(resolve(out,f.name+'.json'),JSON.stringify({fixture:f,runtimeSha256:runtimeHash,data,expected,expectedFailed:failed,calls,observations,decoderPath:rawPath,trace},(_,v)=>typeof v==='bigint'?v.toString():v,2)+'\n');
 results.push({name:f.name,passed:errors.length===0,errors,expectedBytes:expected,expectedFailed:failed,actualBytes:actual,actualFailed:trace.failed,callbacks:calls.length,trace:f.name+'.json'});
}
await c.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'decoder-paths.json'),JSON.stringify(pathInventory,null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete compiled map/filter development receipts');process.exitCode=results.every(x=>x.passed)?0:1;
