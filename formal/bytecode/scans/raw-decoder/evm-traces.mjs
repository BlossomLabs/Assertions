// Development physical empty-rejection receipts for every raw decoder geometry.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync('artifacts/contracts/Collections.sol/Collections.json'));
const code=artifact.deployedBytecode,sha=x=>createHash('sha256').update(x).digest('hex');
const digest=sha(Buffer.from(code.slice(2),'hex'));
if(digest!==JSON.parse(readFileSync(new URL('../../dispatch/inventory.json',import.meta.url))).Collections.runtimeSha256)throw Error('Runtime drift');
const word=n=>BigInt(n).toString(16).padStart(64,'0');
const cases=[
 {name:'selector-only',kind:'HeadShort',data:'0x1787098b'},
 {name:'short-head-last-byte',kind:'HeadShort',data:'0x1787098b'+'ff'.repeat(31)},
 {name:'offset-64-bit-overflow',kind:'OffsetLarge',data:'0x1787098b'+word(1n<<64n)},
 {name:'offset-full-word',kind:'OffsetLarge',data:'0x1787098b'+word((1n<<256n)-1n)+word(0)},
 {name:'missing-length',kind:'HeaderShort',data:'0x1787098b'+word(32)},
 {name:'length-one-byte-short',kind:'HeaderShort',data:'0x1787098b'+word(32)+'00'.repeat(31)},
 {name:'length-64-bit-overflow',kind:'LengthLarge',data:'0x1787098b'+word(32)+word(1n<<64n)},
 {name:'length-full-word',kind:'LengthLarge',data:'0x1787098b'+word(32)+word((1n<<256n)-1n)},
 {name:'missing-one-byte-tail',kind:'TailShort',data:'0x1787098b'+word(32)+word(1)},
 {name:'partial-tail',kind:'TailShort',data:'0x1787098b'+word(32)+word(64)+'ff'.repeat(31)}
];
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'});
const target='0x0000000000000000000000000000000000003500';await provider.request({method:'hardhat_setCode',params:[target,code]});const results=[];
for(const item of cases){
 const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x186a0',data:item.data,value:'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:item,runtimeSha256:digest,trace},null,2)+'\n');
 const logs=trace.structLogs,start=logs.findIndex(x=>x.pc===585),mapping=JSON.parse(readFileSync(new URL('./Raw'+item.kind+'.mapping.json',import.meta.url)));
 if(!trace.failed||!['','0x'].includes(trace.returnValue)||start<0||JSON.stringify(logs.slice(start).map(x=>x.pc))!==JSON.stringify(mapping.states.map(x=>x.pc)))throw Error('Wrong complete raw rejection '+item.name);
 const last=logs.at(-1),nat=x=>BigInt(x.startsWith('0x')?x:'0x'+x),mem=last.memory.map(x=>x.replace(/^0x/,'')).join('');
 if(logs.some(x=>x.depth!==1)||logs.filter(x=>x.op==='MSTORE').length!==1||last.op!=='REVERT'||nat(last.stack.at(-1))!==0n||nat(last.stack.at(-2))!==0n||mem!=='00'.repeat(64)+word(128))throw Error('Wrong physical raw rejection frame '+item.name);
 results.push({name:item.name,kind:item.kind,passed:true,trace:item.name+'.json',scope:'development concrete receipt, not native/public evidence'});
}
await connection.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log('PASS: '+results.length+' complete development raw decoder rejection receipts');
