// Synthetic physical opcode fixtures; no public contract coverage is inferred.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const modulus=1n<<256n,mask=(1n<<160n)-1n,word=n=>BigInt(n).toString(16).padStart(64,'0'),sha=x=>createHash('sha256').update(x).digest('hex');
const self='0x0000000000000000000000000000000000004400',base=0x4500n;
const fixed='f1'.repeat(33),fixedCode='7f'+fixed.slice(0,64)+'5f5260f160205360216000f3';
const targets={echo:{address:base+1n,code:'365f5f37365ff3'},revert:{address:base+2n,code:'365f5f37365ffd'},empty:{address:base+3n,code:'5f5ff3'},fixed:{address:base+4n,code:fixedCode},caller:{address:base+5n,code:'335f5260205ff3'},noCode:{address:base+6n,code:''},write:{address:base+7n,code:'60015f555f5ff3'}};
const defaults={target:'echo',inputOffset:0,inputSize:32,outputOffset:96,outputSize:32,gas:100000,copy:null};
const fixtures=[
 {name:'full-echo'},
 {name:'short-result-preserves-output-tail',inputSize:7,outputSize:32},
 {name:'long-result-truncated-output',target:'fixed',outputSize:16},
 {name:'overlapping-input-output-snapshot',inputSize:64,outputOffset:16,outputSize:64},
 {name:'input-expansion-zero-bytes',inputOffset:300,inputSize:17},
 {name:'output-expansion',outputOffset:500,outputSize:64},
 {name:'zero-input-arbitrary-offset',inputOffset:modulus-1n,inputSize:0},
 {name:'zero-output-arbitrary-offset',outputOffset:modulus-1n,outputSize:0},
 {name:'full-revert-data',target:'revert',inputSize:33,outputSize:16},
 {name:'empty-call-clears-buffer',second:'empty'},
 {name:'codeless-call-clears-buffer',second:'noCode'},
 {name:'static-write-failure-clears-buffer',second:'write'},
 {name:'callee-sees-current-caller',target:'caller'},
 {name:'masked-high-target-bits',highTarget:true},
 {name:'copy-complete-returndata',target:'fixed',copy:{source:0,size:33,destination:352}},
 {name:'copy-returndata-suffix',target:'fixed',copy:{source:7,size:17,destination:352}},
 {name:'zero-copy-at-end',copy:{source:32,size:0,destination:modulus-1n}},
 {name:'zero-copy-one-past-end',copy:{source:33,size:0,destination:modulus-1n},exception:true},
 {name:'copy-past-end',copy:{source:31,size:2,destination:352},exception:true},
 {name:'callee-out-of-gas-empty-result',gas:1}
].map(x=>({...defaults,...x}));
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,[from]=await provider.request({method:'eth_accounts'});
for(const t of Object.values(targets))await provider.request({method:'hardhat_setCode',params:['0x'+t.address.toString(16).padStart(40,'0'),'0x'+t.code]});
const nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),memory=x=>Buffer.from(x.memory.map(w=>w.replace(/^0x/,'')).join(''),'hex');
const grow=(bytes,size)=>size<=bytes.length?bytes:Buffer.concat([bytes,Buffer.alloc(Math.ceil(size/32)*32-bytes.length)]);
const put=(bytes,offset,payload)=>{if(payload.length===0)return bytes;const result=Buffer.from(grow(bytes,offset+payload.length));payload.copy(result,offset);return result;};
const input=(bytes,offset,size)=>size===0?Buffer.alloc(0):grow(bytes,offset+size).subarray(offset,offset+size);
const response=(spec,bytes)=>{
 if(spec.target==='echo'||spec.target==='revert')return {success:spec.target==='echo'&&spec.gas>1,returned:spec.gas>1?bytes:Buffer.alloc(0)};
 if(spec.target==='fixed')return {success:true,returned:Buffer.from(fixed,'hex')};
 if(spec.target==='caller')return {success:true,returned:Buffer.from(word(BigInt(self)),'hex')};
 return {success:spec.target!=='write',returned:Buffer.alloc(0)};
};
const results=[];
for(const fixture of fixtures){
 let code='',expected=Buffer.alloc(0);const calls=[],ops=[];
 const push=n=>{n=BigInt(n);if(n===0n){code+='5f';return;}const hex=n.toString(16).padStart(Math.ceil(n.toString(16).length/2)*2,'0');code+=(0x5f+hex.length/2).toString(16)+hex;};
 const op=(hex,label=null)=>{const pc=code.length/2;code+=hex;if(label)ops.push({pc,label});return pc;};
 const store=(offset,bytes)=>{push(BigInt('0x'+bytes));push(offset);op('52');expected=put(expected,offset,Buffer.from(bytes,'hex'));};
 store(0,'ab'.repeat(32));store(32,'cd'.repeat(32));store(96,'ef'.repeat(32));
 op('30','ADDRESS');push(192);op('52');expected=put(expected,192,Buffer.from(word(BigInt(self)),'hex'));
 const targetWord=targets[fixture.target].address+(fixture.highTarget?1n<<255n:0n);
 push(targetWord);op('3b','EXTCODESIZE');push(224);op('52');expected=put(expected,224,Buffer.from(word(targets[fixture.target].code.length/2),'hex'));
 op('5a','GAS');op('50');
 const call=spec=>{
  const target=targets[spec.target],rawTarget=target.address+(spec.highTarget?1n<<255n:0n);
  const payload=input(expected,Number(spec.inputOffset),spec.inputSize),answer=response(spec,payload);
  const extent=Math.max(spec.inputSize===0?0:Number(spec.inputOffset)+spec.inputSize,spec.outputSize===0?0:Number(spec.outputOffset)+spec.outputSize);
  const before=Buffer.from(expected);expected=grow(expected,extent);expected=put(expected,Number(spec.outputOffset),answer.returned.subarray(0,spec.outputSize));
  for(const value of [spec.outputSize,spec.outputOffset,spec.inputSize,spec.inputOffset,rawTarget,spec.gas])push(value);
  const pc=op('fa','STATICCALL');calls.push({pc,target:target.address.toString(),requestedGas:String(spec.gas),caller:self,input:payload.toString('hex'),success:answer.success,returned:answer.returned.toString('hex'),beforeMemory:before.toString('hex'),afterMemory:expected.toString('hex')});
  push(128);op('52');expected=put(expected,128,Buffer.from(word(answer.success?1:0),'hex'));
  op('5a','GAS');op('50');return answer.returned;
 };
 let returned=call(fixture);
 if(fixture.second)returned=call({...defaults,target:fixture.second,inputSize:0,outputSize:0});
 op('3d','RETURNDATASIZE');push(160);op('52');expected=put(expected,160,Buffer.from(word(returned.length),'hex'));
 let copyExpected=null;
 if(fixture.copy){
  const c=fixture.copy;for(const value of [c.size,c.source,c.destination])push(value);
  const pc=op('3e','RETURNDATACOPY');
  if(c.source+c.size<=returned.length){expected=put(expected,Number(c.destination),returned.subarray(c.source,c.source+c.size));copyExpected={pc,memory:expected.toString('hex')};}
 }
 // Allocate beyond the returned slice so the final physical trace includes all bytes.
 store(416,'00'.repeat(32));push(416);push(0);op('f3');
 await provider.request({method:'hardhat_setCode',params:[self,'0x'+code]});
 const trace=await provider.request({method:'debug_traceCall',params:[{from,to:self,gas:'0x989680',data:'0x'},'latest',{enableMemory:true,disableStack:false,disableStorage:true}]});
 const parent=trace.structLogs.filter(x=>x.depth===1),errors=[],observations=[];
 if(trace.failed!==Boolean(fixture.exception)||(fixture.exception?trace.returnValue.replace(/^0x/,'')!=='':trace.returnValue.replace(/^0x/,'')!==expected.subarray(0,416).toString('hex')))errors.push('Final physical receipt differs');
 for(const entry of ops){
  const i=parent.findIndex(x=>x.pc===entry.pc);if(i<0){if(fixture.exception&&entry.pc>parent.at(-1).pc)continue;errors.push('Missing '+entry.label);continue;}
  const before=parent[i],after=parent[i+1];
  if(entry.label==='GAS'){
   const available=nat(after.stack.at(-1));if(available!==BigInt(before.gas)-2n)errors.push('GAS execution observation differs');observations.push({kind:'Gas',pc:entry.pc,available:available.toString()});
  }else if(entry.label==='ADDRESS'){
   if(nat(after.stack.at(-1))!==BigInt(self))errors.push('Current ADDRESS differs');
  }else if(entry.label==='EXTCODESIZE'){
   const account=nat(before.stack.at(-1))&mask,size=nat(after.stack.at(-1));if(account!==targets[fixture.target].address||size!==BigInt(targets[fixture.target].code.length/2))errors.push('Masked account code size differs');observations.push({kind:'CodeSize',pc:entry.pc,account:account.toString(),size:size.toString()});
  }else if(entry.label==='STATICCALL'){
   const expectedCall=calls.find(x=>x.pc===entry.pc);
   if(nat(before.stack.at(-1)).toString()!==expectedCall.requestedGas||(nat(before.stack.at(-2))&mask).toString()!==expectedCall.target||memory(before).toString('hex')!==expectedCall.beforeMemory||memory(after).toString('hex')!==expectedCall.afterMemory||nat(after.stack.at(-1))!==BigInt(expectedCall.success?1:0))errors.push('Actual STATICCALL stack/memory/result differs');
   const start=trace.structLogs.indexOf(before),finish=trace.structLogs.indexOf(after),child=trace.structLogs.slice(start+1,finish).filter(x=>x.depth===2),lastChild=child.at(-1);
   if(lastChild&&['RETURN','REVERT'].includes(lastChild.op)){
    const offset=Number(nat(lastChild.stack.at(-1))),size=Number(nat(lastChild.stack.at(-2))),bytes=grow(memory(lastChild),offset+size).subarray(offset,offset+size).toString('hex');
    if(bytes!==expectedCall.returned||lastChild.op!==(expectedCall.success?'RETURN':'REVERT'))errors.push('Complete actual child return/revert buffer differs');
   }else if(expectedCall.returned!=='')errors.push('Missing physical child return buffer');
   observations.push({kind:'StaticCall',...expectedCall});
  }else if(entry.label==='RETURNDATASIZE'){
   if(nat(after.stack.at(-1))!==BigInt(returned.length))errors.push('Fresh returndata size differs');
  }else if(entry.label==='RETURNDATACOPY'){
   if(fixture.exception){if(parent.at(-1).pc!==entry.pc||parent.at(-1).op!=='RETURNDATACOPY'||!trace.failed)errors.push('Out-of-bounds copy did not exceptionally halt');}
   else if(!copyExpected||memory(after).toString('hex')!==copyExpected.memory)errors.push('Returndata copy physical frame differs');
  }
 }
 writeFileSync(resolve(out,fixture.name+'.json'),JSON.stringify({fixture,program:code,observations,trace},(_,v)=>typeof v==='bigint'?v.toString():v,2)+'\n');
 results.push({name:fixture.name,passed:errors.length===0,errors,exception:Boolean(fixture.exception),staticCalls:calls.length,trace:fixture.name+'.json'});
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve('pnpm-lock.yaml')))},null,2)+'\n');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' physical external-opcode fixtures');process.exitCode=results.every(x=>x.passed)?0:1;
