#!/usr/bin/env python3
"""Independent complete symbolic UTF8 macro state comparison to actual EVM.

This checks every stack and expanded byte-memory state in all received validator
invocations. It is development evidence; finite receipts cannot replace the
universal native loop and coverage proofs.
"""
import argparse, hashlib, json
from pathlib import Path

MOD = 1 << 256
class Getter:
    @staticmethod
    def Modulus():return MOD
    @staticmethod
    def BitAnd(a,b):return a&b
    @staticmethod
    def Grow(mem,end):return mem+bytes(max(0,end-len(mem)))
class Scan:
    @staticmethod
    def Load(mem,at):return int.from_bytes(Getter.Grow(mem,at+32)[at:at+32],'big')
    @staticmethod
    def Store(mem,at,value):
        grown=Getter.Grow(mem,((at+32+31)//32)*32)
        return grown[:at]+value.to_bytes(32,'big')+grown[at+32:]
    @staticmethod
    def DataWord(data,at):return int.from_bytes(data[at:at+32].ljust(32,b'\0'),'big') if at<len(data) else 0
    @staticmethod
    def ShiftLeft(value,amount):return (value<<amount)%MOD
class Kernel:
    @staticmethod
    def Cell(data,offset,length,cursor,j):
        assert 0<=cursor+j<length and offset+length<=len(data)
        return data[offset+cursor+j]
    @staticmethod
    def Free(mem):return Scan.Load(mem,64)
    @staticmethod
    def Mask192(cell):return cell&192
class Inputs:
    @staticmethod
    def Continuation(cell):return 128<=cell<=191
def evaluate(expression,env):
    expression=expression.replace('&&',' and ').replace('||',' or ')
    return eval(expression,{'__builtins__':{}},dict(env,K=Kernel,I=Inputs,S=Scan,G=Getter))
def require(ok,message):
    if not ok:raise RuntimeError(message)
def main():
    p=argparse.ArgumentParser();p.add_argument('mapping',type=Path);p.add_argument('receipts',type=Path);p.add_argument('--report',type=Path,required=True);args=p.parse_args()
    mapping=json.loads(args.mapping.read_text());rows=json.loads((args.receipts/'results.json').read_text());hits={path['name']:0 for path in mapping['paths']};states=0;macros=0;invocations=0
    for row in rows:
        fixture=json.loads((args.receipts/row['trace']).read_text());require(fixture['runtimeSha256']==mapping['runtimeSha256'],'Original runtime mapping identity')
        logs=fixture['trace']['structLogs'];entry=next((i for i,s in enumerate(logs) if s['pc']==11583),None)
        if entry is None:continue
        invocations+=1;stack=[int(x,16) for x in logs[entry]['stack']];prefix=stack[:-3];ret,offset,length=stack[-3:];mem=bytes.fromhex(''.join(x.removeprefix('0x') for x in logs[entry]['memory']));data=bytes.fromhex(fixture['data'][2:]);index=entry
        while True:
            first=logs[index];current=[int(x,16) for x in first['stack']];cursor=0 if first['pc']==11583 else current[-1]
            env=dict(prefix=prefix,ret=ret,offset=offset,length=length,cursor=cursor,mem=mem,data=data,self=0,value=int(fixture['value']))
            candidates=[path for path in mapping['paths'] if path['start']==first['pc'] and evaluate(path['guard'],env)]
            require(len(candidates)==1,f'{fixture["name"]} {first["pc"]} has {len(candidates)} profile classes')
            path=candidates[0];hits[path['name']]+=1;macros+=1
            for node in path['nodes']:
                actual=logs[index];expected_stack=prefix+[evaluate(x['expression'],env) for x in node['stack']];expected_mem=evaluate(node['memory'],env)
                require(actual['pc']==node['pc'],f'{fixture["name"]} {path["name"]}: PC mismatch at {index}: {actual["pc"]}/{node["pc"]}')
                require([int(x,16) for x in actual['stack']]==expected_stack,f'{fixture["name"]} {path["name"]} PC{actual["pc"]}: whole stack mismatch')
                require(bytes.fromhex(''.join(x.removeprefix('0x') for x in actual['memory']))==expected_mem,f'{fixture["name"]} {path["name"]} PC{actual["pc"]}: whole expanded memory mismatch')
                states+=1;index+=1
            if path['kind']=='bad':
                packet=bytes.fromhex('41972036')+(cursor+path['error']).to_bytes(32,'big')
                require(logs[index-1]['op']=='REVERT' and index==len(logs) and fixture['trace']['failed'] and bytes.fromhex(fixture['trace']['returnValue'].removeprefix('0x'))==packet,'Exact InvalidUtf8 terminal packet')
                break
            actual=logs[index];expected_stack=prefix+[evaluate(x['expression'],env) for x in path['terminalStack']];expected_mem=evaluate(path['terminalMemory'],env)
            require(actual['pc']==(ret if path['terminalPc']=='ret' else path['terminalPc']) and [int(x,16) for x in actual['stack']]==expected_stack and bytes.fromhex(''.join(x.removeprefix('0x') for x in actual['memory']))==expected_mem,'Full macro terminal correspondence')
            if path['terminalPc']=='ret':break
    report=dict(status='prepared-physical-mapping-passed-native-pending',runtimeSha256=mapping['runtimeSha256'],mappingSha256=hashlib.sha256(args.mapping.read_bytes()).hexdigest(),receipts=len(rows),validatorInvocations=invocations,macros=macros,completeStackMemoryStates=states,profiles=hits,unobservedProfiles=[k for k,v in hits.items() if not v],nativeVerified=False,publicCredit=False)
    args.report.parent.mkdir(parents=True,exist_ok=True);args.report.write_text(json.dumps(report,indent=2)+'\n')
    print(f'PASS {invocations} validator invocations, {macros} whole macros, {states} complete stack/memory states; {sum(v>0 for v in hits.values())}/{len(hits)} profiles physically observed; native pending')
if __name__=='__main__':main()
