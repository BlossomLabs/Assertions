import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {network} from 'hardhat';
const options={};for(let i=2;i<process.argv.length;i+=2){if(!['--root','--output','--runtime','--contract','--case'].includes(process.argv[i])||!process.argv[i+1])throw Error('Bad arguments');options[process.argv[i]]=process.argv[i+1];}
const root=resolve(options['--root']??'.'),out=resolve(options['--output']);mkdirSync(out,{recursive:true});
const sha=x=>createHash('sha256').update(x).digest('hex');
const inv=JSON.parse(readFileSync(resolve(root,'formal/bytecode/dispatch/inventory.json'))),connection=await network.connect('hardhatMainnet'),provider=connection.provider,accounts=await provider.request({method:'eth_accounts'}),results=[];
const candidate=options['--runtime']??null;
for(const contract of options['--contract']?[options['--contract']]:['Assertions','Expressions','Collections']){
 if(!['Assertions','Expressions','Collections'].includes(contract))throw Error('Unknown contract');
 const baseline=JSON.parse(readFileSync(resolve(root,'artifacts/contracts/'+contract+'.sol/'+contract+'.json'))).deployedBytecode,baselineDigest=sha(Buffer.from(baseline.slice(2),'hex'));if(baselineDigest!==inv[contract].runtimeSha256)throw Error('Runtime drift');
 const code=candidate?'0x'+readFileSync(candidate).toString('hex'):baseline,digest=sha(Buffer.from(code.slice(2),'hex'));
 const known=Object.values(inv[contract].methodIdentifiers).map(x=>parseInt(x,16)).sort((a,b)=>a-b),selectors=[0,0xffffffff,known[0]-1];
 for(let i=0;i+1<known.length&&selectors.length<5;i++)if(known[i+1]-known[i]>1)selectors.push(known[i]+1);
 if(selectors.length!==5||selectors.some(x=>known.includes(x)))throw Error('Invalid unknown selector inventory');
 const target='0x0000000000000000000000000000000000003602';await provider.request({method:'hardhat_setCode',params:[target,code]});
 for(let i=0;i<selectors.length;i++){
  if(options['--case']!==undefined&&String(i)!==options['--case'])continue;
  const data='0x'+selectors[i].toString(16).padStart(8,'0')+(i%2?'ff'.repeat(28)+'ab'.repeat(i*7):''),trace=await provider.request({method:'debug_traceCall',params:[{from:accounts[0],to:target,gas:'0x989680',data,value:'0x0'},'latest',{enableMemory:true,disableStorage:true,disableStack:false}]});
  const logs=trace.structLogs,last=logs.at(-1),mem=last.memory.map(x=>x.replace(/^0x/,'')).join(''),stores=logs.filter(x=>x.op==='MSTORE'),receiptPassed=trace.failed&&trace.returnValue.replace(/^0x/,'')==='',passed=trace.failed&&trace.returnValue.replace(/^0x/,'')===''&&last.op==='REVERT'&&logs.every(x=>x.depth===1)&&Math.max(...logs.map(x=>x.stack.length))<=3&&mem==='00'.repeat(64)+'00'.repeat(31)+'80'&&BigInt('0x'+last.stack.at(-1).replace(/^0x/,''))===0n&&BigInt('0x'+last.stack.at(-2).replace(/^0x/,''))===0n&&stores.length===1&&BigInt('0x'+stores[0].stack.at(-1).replace(/^0x/,''))===64n&&BigInt('0x'+stores[0].stack.at(-2).replace(/^0x/,''))===128n;
  const name=contract+'-'+i;writeFileSync(resolve(out,name+'.json'),JSON.stringify({contract,selector:selectors[i],data,runtimeSha256:digest,candidate:Boolean(candidate),trace},null,2)+'\n');results.push({contract,index:i,selector:selectors[i],trace:name+'.json',receiptPassed,expectedFailed:true,expectedBytes:'',actualFailed:trace.failed,actualBytes:trace.returnValue.replace(/^0x/,''),passed});
 }
}
await connection.close();
const hh=fileURLToPath(import.meta.resolve('hardhat')),edr=createRequire(hh).resolve('@nomicfoundation/edr'),binding=createRequire(edr).resolve('@nomicfoundation/edr-linux-x64-gnu');
writeFileSync(resolve(out,'toolchain.json'),JSON.stringify({nodeVersion:process.version,nodeExecutable:process.execPath,nodeSha256:sha(readFileSync(process.execPath)),hardhatEntry:hh,hardhatEntrySha256:sha(readFileSync(hh)),edrEntry:edr,edrEntrySha256:sha(readFileSync(edr)),edrVersion:JSON.parse(readFileSync(resolve(dirname(edr),'package.json'))).version,nativeBinding:binding,nativeBindingSha256:sha(readFileSync(binding)),lockfileSha256:sha(readFileSync(resolve(root,'pnpm-lock.yaml')))},null,2)+'\n');
if(results.length!==(options['--case']!==undefined?1:options['--contract']?5:15))throw Error('Wrong fixture inventory');
writeFileSync(resolve(out,'results.json'),JSON.stringify(results,null,2)+'\n');console.log((results.every(x=>x.passed)?'PASS':'FAIL')+': '+results.length+' full physical unknown-selector rejections');process.exitCode=results.every(x=>x.passed)?0:1;
