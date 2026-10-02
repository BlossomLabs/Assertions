// Independent complete public receipts and exact physical element-helper traces.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {network} from 'hardhat';
import {encodeFunctionData,encodeAbiParameters} from 'viem';
import {createHash} from 'node:crypto';
const options={};for(let i=2;i<process.argv.length;i+=2){if(!['--output','--root','--runtime','--case'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad args');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']),here=dirname(fileURLToPath(import.meta.url));mkdirSync(out,{recursive:true});
const artifact=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/Assertions.sol/Assertions.json'))),candidate=options['--runtime']??null,runtime=candidate?'0x'+readFileSync(candidate).toString('hex'):artifact.deployedBytecode,sha=x=>createHash('sha256').update(x).digest('hex'),digest=sha(Buffer.from(runtime.slice(2),'hex'));
const raw=bytes=>({paramType:2,fetcherType:0,paramData:bytes,constraints:[]}),encoded=bytes=>encodeAbiParameters([{type:'bytes[]'}],[[bytes]]).slice(2),selector=encodeFunctionData({abi:artifact.abi,functionName:'gather',args:[[]]}).slice(2,10),put=(buf,offset,value)=>Buffer.from(BigInt.asUintN(256,value).toString(16).padStart(64,'0'),'hex').copy(buf,offset);
const fixtures=[];
for(const n of [0,1,33,257]){const bytes='0x'+'a7'.repeat(n);fixtures.push({name:'element-'+n,data:encodeFunctionData({abi:artifact.abi,functionName:'gather',args:[[raw(bytes)]]}),expected:encoded(bytes),failed:false,path:'ElementSuccess'});}
const tight=Buffer.alloc(228);Buffer.from(selector,'hex').copy(tight);for(const [off,val] of [[4,32n],[36,1n],[68,32n],[100,2n],[132,0n],[164,0n],[196,32n]])put(tight,off,val);
fixtures.push({name:'element-tight128',data:'0x'+tight.toString('hex'),expected:encoded('0x0000'),failed:false,path:'ElementSuccess'});
const alias=Buffer.alloc(324);Buffer.from(selector,'hex').copy(alias);for(const [off,val] of [[4,196n],[36,2n],[68,0n],[100,128n],[132,256n],[164,1n],[200,1n],[232,-196n],[292,0n]])put(alias,off,val);alias[196]=0xaa;
fixtures.push({name:'element-negative-alias',data:'0x'+alias.toString('hex'),expected:encoded('0xaa'),failed:false,path:'ElementSuccess',expectedPointer:36});
const boundary=Buffer.from(fixtures[1].data.slice(2),'hex');put(boundary,68,BigInt(boundary.length-68-127));fixtures.push({name:'element-budget-equality',data:'0x'+boundary.toString('hex'),expected:'',failed:true,path:'ElementFailure'});
const connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),address='0x0000000000000000000000000000000000005800';await provider.request({method:'hardhat_setCode',params:[address,runtime]});
const results=[];
for(const f of fixtures){if(options['--case']&&options['--case']!==f.name)continue;
 const trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:address,gas:'0x989680',data:f.data,value:'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]}),logs=trace.structLogs.filter(x=>x.depth===1),mapping=JSON.parse(readFileSync(resolve(here,f.path+'.mapping.json'))),pcs=mapping.states.map(s=>s.pc),at=logs.findIndex((x,i)=>x.pc===17803&&JSON.stringify(logs.slice(i,i+pcs.length).map(s=>s.pc))===JSON.stringify(pcs)),actual=trace.returnValue.replace(/^0x/,''),receiptPassed=trace.failed===f.failed&&actual===f.expected,helperPassed=at>=0,pointer=f.failed||at<0?null:Number(BigInt('0x'+logs[at+pcs.length].stack.at(-1).replace(/^0x/,''))),pointerPassed=f.expectedPointer===undefined||f.expectedPointer===pointer,passed=receiptPassed&&helperPassed&&pointerPassed;
 writeFileSync(resolve(out,f.name+'.json'),JSON.stringify({name:f.name,runtimeSha256:digest,data:f.data,expectedBytes:f.expected,expectedFailed:f.failed,trace},null,2)+'\n');results.push({name:f.name,expectedBytes:f.expected,actualBytes:actual,expectedFailed:f.failed,actualFailed:trace.failed,receiptPassed,helperPassed,pointer,pointerPassed,passed});
}
await connection.close();writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log(results.every(x=>x.passed)?'PASS':'FAIL',results.length,'complete gather receipts and element traces');process.exitCode=results.every(x=>x.passed)?0:1;
