// Development receipts for actual accepted decoder frames and sum result/errors.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Collections.sol/Collections.json'));
const code=artifact.deployedBytecode,sha=x=>createHash('sha256').update(x).digest('hex');
const digest=sha(Buffer.from(code.slice(2),'hex'));
if(digest!==JSON.parse(readFileSync(new URL('../dispatch/inventory.json',import.meta.url))).Collections.runtimeSha256)throw Error('Runtime drift');
const mapping=JSON.parse(readFileSync(new URL('./SumDecoder.mapping.json',import.meta.url)));
const word=n=>BigInt(n).toString(16).padStart(64,'0');
const call=(head,payload,tail='')=>'0x1787098b'+word(head)+'00'.repeat(Math.max(0,Number(head)-32))+word(payload.length/2)+payload+tail;
const cases=[
 {name:'empty',data:call(32,''),head:32n,length:0n,result:word(0)},
 {name:'zero-offset-empty',data:'0x1787098b'+word(0),head:0n,length:0n,result:word(0)},
 {name:'one',data:call(32,word(19)),head:32n,length:32n,result:word(19)},
 {name:'three',data:call(32,[3,7,13].map(word).join('')),head:32n,length:96n,result:word(23)},
 {name:'loose-offset',data:call(47,word(11),'abcd'),head:47n,length:32n,result:word(11)},
 {name:'no-payload-padding',data:call(32,'ff'),head:32n,length:1n,error:'a949d285'+word(1)},
 {name:'overflow',data:call(32,word((1n<<256n)-1n)+word(1)),head:32n,length:64n,error:'4e487b71'+word(17)},
 {name:'many',data:call(32,Array.from({length:65},(_,i)=>word(i)).join(''),'ff'),head:32n,length:2080n,result:word(2080)}
];
const connection=await network.connect('hardhatMainnet'),provider=connection.provider;
const accounts=await provider.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003400';
await provider.request({method:'hardhat_setCode',params:[target,code]});
const results=[];
for(const item of cases){
 const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data:item.data,value:'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,runtimeSha256:digest,trace},(_,v)=>typeof v==='bigint'?v.toString():v,2)+'\n');
 const logs=trace.structLogs,start=logs.findIndex(x=>x.pc===585),end=logs.findIndex((x,i)=>i>start&&x.pc===2767);
 if(start<0||end<0||JSON.stringify(logs.slice(start,end).map(x=>x.pc))!==JSON.stringify(mapping.states.map(x=>x.pc)))throw Error('Actual decoder path differs: '+item.name);
 const entry=logs[end],nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x);
 const expected=[0x1787098bn,604n,item.head+36n,item.length];
 if(entry.stack.length!==4||entry.stack.some((v,i)=>nat(v)!==expected[i]))throw Error('Actual decoded stack differs: '+item.name);
 const mem=entry.memory.map(x=>x.replace(/^0x/,'')).join('');
 if(mem.length!==192||mem!=='00'.repeat(64)+word(128))throw Error('Decoder changed actual memory: '+item.name);
 const returned=trace.returnValue.replace(/^0x/,'');
 if(trace.failed!==Boolean(item.error)||returned!==(item.error??item.result))throw Error('Wrong full EVM result: '+item.name);
 results.push({name:item.name,passed:true,trace:item.name+'.json',decoderSteps:end-start,bodyEntry:2767,scope:'development concrete receipt, not unbounded native body evidence'});
}
await connection.close();
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');
console.log('PASS: '+results.length+' development decoder/body receipts');
