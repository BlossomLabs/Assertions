// Independent finite physical fixtures; full retained native entry evidence remains separate.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
import {toFunctionSelector} from 'viem';
const args=process.argv.slice(2),out=resolve(args[0]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Collections.sol/Collections.json'));
const code=artifact.deployedBytecode,selector=toFunctionSelector('zipWords(bytes,bytes)');
const word=n=>BigInt(n).toString(16).padStart(64,'0'),chunks=s=>Array.from({length:s.length/64},(_,i)=>s.slice(i*64,(i+1)*64));
const abi=s=>word(32)+word(s.length/2)+s;
const canonical=(a,b)=>selector+word(64)+word(96+a.length/2)+word(a.length/2)+a+word(b.length/2)+b;
const interleave=(a,b)=>chunks(a).flatMap((x,i)=>[x,chunks(b)[i]]).join('');
const cases=[];
for(const n of [0,1,2,3,17,65]){
 const a=Array.from({length:n},(_,i)=>word(3+4*i)).join(''),b=Array.from({length:n},(_,i)=>word(11+6*i)).join('');
 cases.push({name:'n'+n,data:canonical(a,b),a,b,expected:abi(interleave(a,b)),success:true});
}
const domain=[0n,1n,(1n<<255n),(1n<<256n)-1n,7n],a=domain.map(word).join(''),b=domain.slice().reverse().map(word).join('');
cases.push({name:'word-domain',data:canonical(a,b),a,b,expected:abi(interleave(a,b)),success:true});
const unaligned=(a,b,name,length)=>({name,data:canonical(a,b),a,b,expected:toFunctionSelector('UnalignedWords(uint256)').slice(2)+word(length),success:false});
cases.push(unaligned('ff','','a-unaligned',1),unaligned('','aa','b-unaligned',1),unaligned('ffff','aa','both-unaligned-priority-a',2));
for(const [a,b,name] of [[word(7),'','a-longer'],['',word(9),'b-longer'],[word(3)+word(5),word(7),'two-vs-one']])cases.push({name,data:canonical(a,b),a,b,expected:toFunctionSelector('WordCountMismatch(uint256,uint256)').slice(2)+word(a.length/64)+word(b.length/64),success:false});
const overlap=word(3)+word(7)+word(11);cases.push({name:'overlapping-inputs',data:selector+word(64)+word(64)+word(96)+overlap,a:overlap,b:overlap,expected:abi(interleave(overlap,overlap)),success:true});
const swappedA=word(3)+word(7),swappedB=word(11)+word(17);cases.push({name:'reverse-head-order',data:selector+word(160)+word(64)+word(64)+swappedB+word(64)+swappedA,a:swappedA,b:swappedB,expected:abi(interleave(swappedA,swappedB)),success:true});
const looseA=word(41),looseB=word(43);cases.push({name:'misaligned-first-head',data:selector+word(65)+word(160)+'aa'+word(32)+looseA+'bb'.repeat(31)+word(32)+looseB+'cc'.repeat(7),a:looseA,b:looseB,expected:abi(interleave(looseA,looseB)),success:true});
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),target='0x'+(0x3901).toString(16).padStart(40,'0');
await provider.request({method:'hardhat_setCode',params:[target,code]});
const bytesAt=(mem,offset,width)=>mem.map(w=>w.replace(/^0x/,'' )).join('').slice(offset*2,(offset+width)*2);
const valueAt=(mem,offset)=>BigInt('0x'+bytesAt(mem,offset,32));
const results=[];
for(const item of cases){
 const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data:item.data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 const logs=trace.structLogs,receipt=trace.returnValue.replace(/^0x/,'').toLowerCase();
 const terminal=logs.at(-1),stack=terminal.stack,offset=Number(BigInt(stack.at(-1))),size=Number(BigInt(stack.at(-2)));
 const terminalSlice=bytesAt(terminal.memory,offset,size),receiptPassed=receipt===item.expected && trace.failed===!item.success && terminalSlice===receipt && logs.every(x=>x.depth===1);
 let memoryPassed=true,storesPassed=true,copyPassed=true;
 if(item.success){
  const n=item.a.length/64,entry=logs.find(s=>s.pc===2094);memoryPassed=!!entry && valueAt(entry.memory,64)===BigInt(160+n*64) && valueAt(entry.memory,128)===BigInt(n*64) && bytesAt(entry.memory,160,n*64)==='00'.repeat(n*64);
  const stores=logs.filter(s=>s.pc===2237||s.pc===2253),expectedWords=chunks(interleave(item.a,item.b));
  storesPassed=stores.length===n*2 && stores.every((s,j)=>s.pc===(j%2===0?2237:2253) && Number(BigInt(s.stack.at(-1)))===160+j*32 && word(BigInt(s.stack.at(-2)))===expectedWords[j]);
  const calloc=logs.filter(s=>s.pc===2085);memoryPassed=memoryPassed && calloc.length===(n?1:0) && calloc.every(s=>Number(BigInt(s.stack.at(-1)))===160 && Number(BigInt(s.stack.at(-2)))===item.data.slice(2).length/2 && Number(BigInt(s.stack.at(-3)))===n*64);
  const copy=logs.filter(s=>s.pc===20967);copyPassed=copy.length===1 && Number(BigInt(copy[0].stack.at(-1)))===224+n*64 && Number(BigInt(copy[0].stack.at(-2)))===160 && Number(BigInt(copy[0].stack.at(-3)))===n*64;
 }
 const passed=receiptPassed&&memoryPassed&&storesPassed&&copyPassed;
 const row={name:item.name,passed,receiptPassed,memoryPassed,storesPassed,copyPassed,physicalSteps:logs.length,expected:item.expected,observed:receipt};results.push(row);
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({item,result:row,trace},null,2)+'\n');console.log(item.name,passed?'PASS':'FAIL');
}
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');writeFileSync(resolve(out,'identity.json'),JSON.stringify({runtimeSha256:createHash('sha256').update(Buffer.from(code.slice(2),'hex')).digest('hex'),runtimeBytes:(code.length-2)/2,selector,scope:'Finite development observations; no retained public evidence claim'},null,2)+'\n');
await connection.close();if(results.some(r=>!r.passed))process.exitCode=1;
