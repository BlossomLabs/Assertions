// Complete PC-zero receipts and reached observations for development foldRange/foldBytes/foldWords evidence.
// Exact compiler identity and native/semantic/dependency checks are enforced by verify.py.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {encodeErrorResult,toFunctionSelector} from 'viem';
const options={};
for(let i=2;i<process.argv.length;i+=2){if(!['--root','--output','--case','--runtime','--inventory'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad arguments');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Collections.sol/Collections.json'))),inventory=JSON.parse(readFileSync(resolve(root,'formal/bytecode/dispatch/inventory.json'))).Collections;
const sha=x=>createHash('sha256').update(x).digest('hex'),runtimeHash=sha(Buffer.from(artifact.deployedBytecode.slice(2),'hex'));
if(runtimeHash!==inventory.runtimeSha256)throw Error('Canonical runtime drift');
const runtime=options['--runtime']?'0x'+readFileSync(resolve(options['--runtime'])).toString('hex'):artifact.deployedBytecode;
const executedRuntimeHash=sha(Buffer.from(runtime.slice(2),'hex'));
const word=n=>BigInt(n).toString(16).padStart(64,'0'),bytes=n=>Buffer.from(word(n),'hex'),max=(1n<<256n)-1n;
const self='0x0000000000000000000000000000000000004800',targetBase=0x4900n;
const addr=n=>'0x'+n.toString(16).padStart(40,'0'),signal=toFunctionSelector('SubcallOutOfGas()').slice(2);
const fixedCode=(payload,revert=false)=>{
 let code='';for(let i=0;i<payload.length;i+=64){const part=payload.slice(i,i+64).padEnd(64,'0');code+='7f'+part+'60'+(i/2).toString(16).padStart(2,'0')+'52';}
 return code+'60'+(payload.length/2).toString(16).padStart(2,'0')+'5f'+(revert?'fd':'f3');
};

const sumCode='6020355f35015f5260205ff3',elemCode='6020355f5260205ff3';
const lateGood='5f355f5260205ff3',latePrefix='60203560021460',lateJump=(latePrefix.length/2+2+lateGood.length/2).toString(16).padStart(2,'0');
const defs={sum:{code:sumCode},elem:{code:elemCode},odd:{code:'6020356001165f5260205ff3'},acc:{code:'5f355f5260205ff3'},
 caller:{code:'335f5260205ff3'},zero:{code:fixedCode(word(0))},one:{code:fixedCode(word(1))},
 short:{code:fixedCode('ab'.repeat(31))},long:{code:fixedCode('cd'.repeat(33))},empty:{code:'5f5ff3'},
 fail:{code:fixedCode('deadbeef1234',true)},signal:{code:fixedCode(signal,true)},longSignal:{code:fixedCode(signal+'11'.repeat(32),true)},
 lateShort:{code:latePrefix+lateJump+'57'+lateGood+'5b5f355f52601f5ff3'},noCode:{code:''},precompile:{code:'',address:'0x0000000000000000000000000000000000000005'}};
Object.entries(defs).forEach(([name,v],i)=>{v.address??=addr(targetBase+BigInt(i));});
const signature=mode=>'fold'+mode+'('+(mode==='Range'?'uint256':'bytes')+',address,bytes,uint256,uint256[],bytes32,uint8)';
const selectorFor=mode=>'0x'+inventory.methodIdentifiers[signature(mode)];
for(const [mode,selector] of [['Range','f1d88dc8'],['Bytes','6d24e79c'],['Words','6de60cb0']])if(selectorFor(mode)!=='0x'+selector)throw Error('Selector drift '+mode);
const pad=b=>Buffer.concat([b,Buffer.alloc((32-b.length%32)%32)]);
const canonical=(selector,mode,n,payload,target,template,accOffset,offsets,init,exit)=>{
 const tail=(b)=>Buffer.concat([bytes(b.length),pad(b)]),tails=[];
 if(mode!=='Range')tails.push(tail(payload));
 tails.push(tail(template),Buffer.concat([bytes(offsets.length),...offsets.map(bytes)]));
 const positions=[];let cursor=224;for(const t of tails){positions.push(cursor);cursor+=t.length;}
 const source=mode==='Range'?word(n):word(positions.shift()),tpos=positions.shift(),apos=positions.shift();
 return selector+source+word(BigInt(target))+word(tpos)+word(accOffset)+word(apos)+word(init)+word(exit)+Buffer.concat(tails).toString('hex');
};
const error=(name,args=[])=>encodeErrorResult({abi:artifact.abi,errorName:name,args}).slice(2);
const loaded=(payload,offset)=>BigInt('0x'+Buffer.concat([payload.subarray(offset,offset+32),Buffer.alloc(Math.max(0,32-payload.subarray(offset,offset+32).length))]).toString('hex'));
const answer=(target,payload)=>{
 const acc=loaded(payload,0),elem=loaded(payload,32);
 if(target==='sum')return {ok:true,returned:bytes((acc+elem)&max)};
 if(target==='elem')return {ok:true,returned:bytes(elem)};
 if(target==='odd')return {ok:true,returned:bytes(elem&1n)};
 if(target==='acc')return {ok:true,returned:bytes(acc)};
 if(target==='caller')return {ok:true,returned:bytes(BigInt(self))};
 if(['zero','one'].includes(target))return {ok:true,returned:bytes(target==='zero'?0n:1n)};
 if(target==='lateShort')return {ok:true,returned:bytes(acc).subarray(0,elem===2n?31:32)};
 if(target==='short'||target==='long')return {ok:true,returned:Buffer.from(target==='short'?'ab'.repeat(31):'cd'.repeat(33),'hex')};
 if(target==='empty')return {ok:true,returned:Buffer.alloc(0)};
 if(target==='fail')return {ok:false,returned:Buffer.from('deadbeef1234','hex')};
 if(target==='signal'||target==='longSignal')return {ok:false,returned:Buffer.from(signal+(target==='longSignal'?'11'.repeat(32):''),'hex')};
 throw Error('No admitted callback oracle for '+target);
};
const defaults={xs:[0n,1n,2n,3n,255n],n:5n,target:'sum',template:'a5'.repeat(64),accOffset:0n,offsets:[32n],init:17n,exit:0n};
const fixtures=[];
const subject=f=>f.payload===undefined?Buffer.concat(f.xs.map(f.mode==='Bytes'?x=>Buffer.from([Number(x)]):bytes)):Buffer.from(f.payload,'hex');
const domain=f=>f.mode==='Range'?Array.from({length:Number(f.n)},(_,i)=>BigInt(i)):f.mode==='Bytes'?Array.from(subject(f),x=>BigInt(x)):Array.from({length:subject(f).length/32},(_,i)=>loaded(subject(f),32*i));
const encode=f=>canonical(selectorFor(f.mode),f.mode,f.n,subject(f),f.targetAddress??defs[f.target].address,Buffer.from(f.template,'hex'),f.accOffset,f.offsets,f.init,f.exit)+(f.trailing??'');
for(const mode of ['Range','Bytes','Words']){
 const add=(name,patch={})=>fixtures.push({...defaults,mode,...patch,name:mode.toLowerCase()+'-'+name});
 for(const n of [0,1,2,3,5,9,17])add('count-'+n,{n:BigInt(n),xs:Array.from({length:n},(_,i)=>BigInt(i))});
 if(mode==='Bytes')add('all-byte-values',{xs:[0n,1n,127n,128n,254n,255n]});
 if(mode==='Words')add('full-word-domain',{xs:[0n,1n,max,1n<<255n],init:max});
 add('no-element-windows',{offsets:[],target:'acc'});
 add('duplicate-element-windows',{template:'a5'.repeat(96),offsets:[32n,64n,32n]});
 add('element-overwrites-accumulator',{offsets:[0n,32n]});
 add('overlapping-windows',{template:'a5'.repeat(96),accOffset:7n,offsets:[1n,32n,3n,64n]});
 add('misaligned-accumulator',{template:'a5'.repeat(65),accOffset:1n});
 add('last-element-window',{template:'a5'.repeat(65),offsets:[33n]});
 add('last-accumulator-window',{template:'a5'.repeat(65),accOffset:33n});
 for(const exit of [1n,2n]){
  add('exit-'+exit+'-zero',{target:'zero',exit});add('exit-'+exit+'-one',{target:'one',exit});
  add('exit-'+exit+'-odd',{target:'odd',exit});add('exit-'+exit+'-initial-extreme',{target:'odd',exit,init:max});
 }
 for(const target of ['noCode','precompile','signal'])add('empty-skips-'+target,{xs:[],n:0n,target});
 for(const size of [0,1,31])add('empty-short-template-'+size,{xs:[],n:0n,template:'ab'.repeat(size),offsets:[],accOffset:9n});
 add('empty-invalid-accumulator',{xs:[],n:0n,accOffset:33n,offsets:[max]});
 add('empty-invalid-element',{xs:[],n:0n,offsets:[33n,max]});
 add('invalid-accumulator-first',{accOffset:max,offsets:[max]});
 add('first-invalid-element',{offsets:[0n,33n,max]});
 add('nonempty-no-code',{target:'noCode'});add('nonempty-precompile',{target:'precompile'});
 for(const target of ['empty','short','long','lateShort','fail','signal','longSignal'])add('callback-'+target,{target,xs:[1n,2n,3n],n:3n});
 add('actual-caller',{target:'caller'});add('trailing-calldata',{trailing:'deadbeef'});
 if(mode==='Words')for(const n of [1,31,33,63])add('unaligned-'+n,{payload:'ab'.repeat(n),template:'',offsets:[max],accOffset:max,target:'noCode'});
}
for(const mode of ['Range','Bytes','Words']){
 const base=fixtures.find(f=>f.name===mode.toLowerCase()+'-count-1'),selector=selectorFor(mode);
 for(const n of [0,1,31,63,95,127,159,191,223])fixtures.push({...base,name:mode.toLowerCase()+'-raw-short-head-'+n,raw:selector+'ff'.repeat(n),rawRejected:true});
 const mutate=(name,index,value)=>{const b=Buffer.from(encode(base).slice(10),'hex');bytes(value).copy(b,index*32);fixtures.push({...base,name:mode.toLowerCase()+'-raw-'+name,raw:selector+b.toString('hex'),rawRejected:true});};
 for(const index of mode==='Range'?[2,4]:[0,2,4])for(const [name,value] of [['large',1n<<64n],['maximum',max],['missing',4096n]])mutate('offset-'+name+'-'+index,index,value);
 mutate('noncanonical-address',1,(1n<<160n)+BigInt(defs[base.target].address));
 for(const exit of [3n,255n,256n,max])mutate('invalid-exit-'+exit,6,exit);
 const encoded=Buffer.from(encode(base).slice(10),'hex');
 for(const index of mode==='Range'?[2,4]:[0,2,4])for(const value of [1n<<64n,4096n]){
  const b=Buffer.from(encoded),pos=Number(loaded(b,index*32));bytes(value).copy(b,pos);fixtures.push({...base,name:mode.toLowerCase()+'-raw-tail-'+index+'-length-'+value,raw:selector+b.toString('hex'),rawRejected:true});
 }
 for(const value of [1n,max])fixtures.push({...base,name:mode.toLowerCase()+'-nonzero-value-'+value,value:'0x'+value.toString(16),rawRejected:true});
 // Preserve the compiler's loose dynamic-tail admission independently of canonical ABI.
 for(const [name,start,gap] of [['loose-misaligned-tails',225,7],['loose-dirty-gaps',288,64]]){
  const b=Buffer.alloc(700,0xa7),payload=subject(base),template=Buffer.from(base.template,'hex');let cursor=start;
  bytes(base.n).copy(b,0);bytes(BigInt(defs[base.target].address)).copy(b,32);bytes(base.accOffset).copy(b,96);bytes(base.init).copy(b,160);bytes(base.exit).copy(b,192);
  if(mode!=='Range'){bytes(cursor).copy(b,0);Buffer.concat([bytes(payload.length),payload]).copy(b,cursor);cursor+=32+payload.length+gap;}
  bytes(cursor).copy(b,64);Buffer.concat([bytes(template.length),template]).copy(b,cursor);cursor+=32+template.length+gap;
  bytes(cursor).copy(b,128);Buffer.concat([bytes(base.offsets.length),...base.offsets.map(bytes)]).copy(b,cursor);cursor+=32+32*base.offsets.length;
  fixtures.push({...base,name:mode.toLowerCase()+'-'+name,raw:selector+b.subarray(0,cursor).toString('hex')});
 }
}
if(options['--inventory']){writeFileSync(resolve(options['--inventory']),JSON.stringify(fixtures,(_,v)=>typeof v==='bigint'?v.toString():v,2)+'\n');console.log('Inventoried '+fixtures.length+' fold fixtures');process.exit(0);}
const selected=options['--case']?fixtures.filter(x=>x.name===options['--case']):fixtures;if(!selected.length)throw Error('Missing case');
const c=await network.connect('hardhatMainnet'),p=c.provider,[from]=await p.request({method:'eth_accounts'});
await p.request({method:'hardhat_setCode',params:[self,runtime]});
for(const [name,t] of Object.entries(defs))if(name!=='precompile')await p.request({method:'hardhat_setCode',params:[t.address,'0x'+t.code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>Buffer.from(x.memory.map(w=>w.replace(/^0x/,'')).join(''),'hex');
const results=[],pathInventory={};

for(const f of selected){
 const selector=selectorFor(f.mode),target={...defs[f.target],address:f.targetAddress??defs[f.target].address},source=subject(f),template=Buffer.from(f.template,'hex'),data=f.raw??encode(f);
 const calls=[];let expected='',failed=true;
 if(f.rawRejected)expected='';
 else if(f.mode==='Words'&&source.length%32!==0)expected=error('UnalignedWords',[BigInt(source.length)]);
 else if(template.length<32||f.accOffset>BigInt(template.length-32))expected=error('LambdaOffsetOutOfBounds',[f.accOffset,BigInt(template.length)]);
 else if(f.offsets.some(o=>o>BigInt(template.length-32)))expected=error('LambdaOffsetOutOfBounds',[f.offsets.find(o=>o>BigInt(template.length-32)),BigInt(template.length)]);
 else{
  const elements=domain(f);let accumulator=bytes(f.init);failed=false;
  if(elements.length>0&&['noCode','precompile'].includes(f.target)){failed=true;expected=error('InvalidCallbackTarget',[target.address]);}
  else{
   for(let i=0;i<elements.length;i++){
    const elem=bytes(elements[i]),stamped=Buffer.from(template);accumulator.copy(stamped,Number(f.accOffset));for(const offset of f.offsets)elem.copy(stamped,Number(offset));
    const a=answer(f.target,stamped);calls.push({index:i,accumulator:accumulator.toString('hex'),element:elem.toString('hex'),input:stamped.toString('hex'),ok:a.ok,returned:a.returned.toString('hex')});
    if(!a.ok){failed=true;expected=f.target==='signal'?signal:error('CallbackFailed',[selector,BigInt(i),0n,target.address,'0x'+stamped.toString('hex'),'0x'+a.returned.toString('hex')]);break;}
    if(a.returned.length!==32){failed=true;expected=error('InvalidCallbackResult',[selector,BigInt(i),0n,target.address]);break;}
    accumulator=a.returned;const next=loaded(accumulator,0);if((f.exit===1n&&next!==0n)||(f.exit===2n&&next===0n))break;
   }
   if(!failed)expected=accumulator.toString('hex');
  }
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
  const retOffset=Number(nat(last.stack.at(-1))),retSize=Number(nat(last.stack.at(-2))),returned=memory(last).subarray(retOffset,retOffset+retSize).toString('hex');
  if(nat(call.stack.at(-2))!==BigInt(target.address)||input!==oracle.input||nat(after.stack.at(-1))!==BigInt(oracle.ok?1:0)||last.op!==(oracle.ok?'RETURN':'REVERT')||returned!==oracle.returned)errors.push('Physical callback '+i+' input/status/full returndata differs');
  observations.push({kind:'StaticCall',pc:call.pc,caller:self,target:target.address,requestedGas:nat(call.stack.at(-1)).toString(),inputOffset,inputSize,input,success:oracle.ok,returned});
 }
 for(let i=0;i<parent.length-1;i++)if(parent[i].op==='GAS')observations.push({kind:'Gas',pc:parent[i].pc,available:nat(parent[i+1].stack.at(-1)).toString()});else if(parent[i].op==='EXTCODESIZE')observations.push({kind:'CodeSize',pc:parent[i].pc,account:addr(nat(parent[i].stack.at(-1))&((1n<<160n)-1n)),size:nat(parent[i+1].stack.at(-1)).toString()});
 const rawPath=parent.map(x=>x.pc);
 pathInventory[f.name]=rawPath;
 writeFileSync(resolve(out,f.name+'.json'),JSON.stringify({fixture:f,runtimeSha256:executedRuntimeHash,baselineRuntimeSha256:runtimeHash,data,expected,expectedFailed:failed,calls,observations,decoderPath:rawPath,trace},(_,v)=>typeof v==='bigint'?v.toString():v,2)+'\n');
 results.push({name:f.name,passed:errors.length===0,receiptPassed:trace.failed===failed&&actual===expected,runtimeSha256:executedRuntimeHash,errors,expectedBytes:expected,expectedFailed:failed,actualBytes:actual,actualFailed:trace.failed,callbacks:calls.length,trace:f.name+'.json'});
}
await c.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'decoder-paths.json'),JSON.stringify(pathInventory,null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' complete compiled fold development receipts');process.exitCode=results.every(x=>x.passed)?0:1;
