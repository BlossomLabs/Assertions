// Development observations only; no retained public-entry evidence.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const root=resolve('.'),out=resolve(process.argv[2]);mkdirSync(out,{recursive:true});
const code=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Collections.sol/Collections.json'))).deployedBytecode;
const frozen=JSON.parse(readFileSync(resolve(root,'formal/bytecode/dispatch/inventory.json'))).Collections;
if(createHash('sha256').update(Buffer.from(code.slice(2),'hex')).digest('hex')!==frozen.runtimeSha256||frozen.methodIdentifiers['uniqueWords(bytes,bool)']!=='b58889b6')throw Error('Runtime identity drift');
const word=n=>BigInt(n).toString(16).padStart(64,'0');
const shapes=[['empty',[]],['single',[3n]],['same',[7n,7n,7n]],['grouped',[3n,3n,11n,11n,2n]],['separated',[3n,11n,3n,2n,11n]],['domain',[0n,2n**256n-1n,0n,2n**255n,2n**256n-1n]]];
const cases=shapes.flatMap(([name,values])=>[false,true].map(ordered=>({name:name+'-'+ordered,ordered,values,payload:values.map(word).join('')})));
cases.push({name:'unaligned',ordered:false,values:[],payload:'ff'},{name:'invalid-bool',ordered:2,values:[],payload:''});
const c=await network.connect('hardhatMainnet'),p=c.provider,accounts=await p.request({method:'eth_accounts'}),target='0x0000000000000000000000000000000000003900';await p.request({method:'hardhat_setCode',params:[target,code]});const results=[];
for(const item of cases){
 const data='0xb58889b6'+word(64)+word(item.ordered===true?1:item.ordered===false?0:item.ordered)+word(item.payload.length/2)+item.payload;
 const trace=await p.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
 let expected='',failed=false;
 if(item.name==='unaligned'){expected='a949d285'+word(1);failed=true;}
 else if(item.name==='invalid-bool'){failed=true;}
 else {const values=item.values.filter((v,i,vs)=>item.ordered?i===0||v!==vs[i-1]:vs.indexOf(v)===i);expected=word(32)+word(values.length*32)+values.map(word).join('');}
 const passed=trace.failed===failed&&trace.returnValue.replace(/^0x/,'')===expected;
 writeFileSync(resolve(out,item.name+'.json'),JSON.stringify({case:{...item,values:item.values.map(String)},data,trace},null,2)+'\n');
 results.push({name:item.name,passed,expectedFailed:failed,actualFailed:trace.failed,expectedBytes:expected,actualBytes:trace.returnValue.replace(/^0x/,''),trace:item.name+'.json'});
 console.log(item.name,passed?'PASS':'FAIL',trace.structLogs.length,'instructions');
}
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');await c.close();if(!results.every(r=>r.passed))process.exitCode=1;
