#!/usr/bin/env python3
"""Gate complete encoding wrappers, tuple callee targets and complete production codec AST."""
import argparse,copy,gzip,importlib.util,json,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('muldiv',HERE.parent/'full-mul-div/generate.py');dep=importlib.util.module_from_spec(spec);spec.loader.exec_module(dep);SOURCES=dep.SOURCES
spec=importlib.util.spec_from_file_location('codec',ROOT/'formal/abi/construction/generate.py');codec=importlib.util.module_from_spec(spec);spec.loader.exec_module(codec)
def form(node):
    node=dep.form(node)
    def clean(n):
        if isinstance(n,list):return [clean(x) for x in n]
        if not isinstance(n,dict):return n
        return {k:clean(v) for k,v in n.items() if k not in {'overloadedDeclarations','linearizedBaseContracts','usedErrors','contractDependencies'}}
    return clean(node)
def descriptor(node):
    if node.get('nodeType')=='IndexRangeAccess' and node.get('startExpression') is None and dep.literal(node['endExpression'])==0:
        if descriptor(node['baseExpression'])!='t':raise ValueError('Unsupported descriptor slice')
        return 't[..0]'
    if node.get('nodeType')!='FunctionCall' or node['expression'].get('nodeType')!='ElementaryTypeNameExpression' or node['expression']['typeName']['name']!='bytes' or len(node['arguments'])!=1:raise ValueError('Unsupported descriptor cast')
    arg=node['arguments'][0]
    if arg.get('nodeType')=='Identifier' and arg.get('name')=='types':return 't'
    raise ValueError('Unsupported descriptor source')

def generate(solc,root,out,bootstrap=False):
    out.mkdir(parents=True,exist_ok=True);dep.generate(solc,root,out/'compiler')
    data=json.loads(gzip.decompress((out/'compiler/solc-output.json.gz').read_bytes()));ops=next(n for n in data['sources']['contracts/Operations.sol']['ast']['nodes'] if n.get('name')=='Operations');library=next(n for n in data['sources']['contracts/lib/AbiCodec.sol']['ast']['nodes'] if n.get('name')=='AbiCodec')
    fs={n['name']:copy.deepcopy(n) for n in ops['nodes'] if n.get('nodeType')=='FunctionDefinition' and n.get('name') in ['encode','encodeBytes']};entries=[];bindings=[];slots={}
    if set(fs)!={'encode','encodeBytes'}:raise ValueError('Encoding inventory')
    for name,f in fs.items():
        sig=name+'(string,bytes[])';selector=data['contracts']['contracts/Operations.sol']['Operations']['evm']['methodIdentifiers'][sig]
        if f['functionSelector']!=selector:raise ValueError('Selector mismatch')
        entries.append({'signature':sig,'selector':selector,'symbol':'Raw' if name=='encode' else 'Bytes'})
        call=f['body']['statements'][0]['initialValue'] if name=='encode' else f['body']['statements'][0]['expression'];target=call['expression'].get('referencedDeclaration');callee=next(n for n in library['nodes'] if n.get('id')==target)
        if callee.get('name')!='tuple' or call['expression'].get('memberName')!='tuple' or len(call['arguments'])!=2 :raise ValueError('Unbound reached tuple call')
        bindings.append({'caller':name,'callee':'AbiCodec.tuple','compilerDeclaration':target})
        if name=='encode':
            if descriptor(call['arguments'][0])!='t' or call['arguments'][1].get('name')!='values':raise ValueError('Raw arguments changed')
            asm=f['body']['statements'][1]['AST']['statements'][0]['expression'];offset=asm['arguments'][0]
            if asm['functionName']['name']!='return' or offset['functionName']['name']!='add' or offset['arguments'][0].get('name')!='out' or asm['arguments'][1]['functionName']['name']!='mload' or asm['arguments'][1]['arguments'][0].get('name')!='out':raise ValueError('Raw RETURN footprint')
            slots['RAW_OFFSET']=dep.yul(offset['arguments'][1]);offset['arguments'][1]={'translated-slot':'RAW_OFFSET'}
        else:
            slots['BYTES_DESCRIPTOR']=descriptor(call['arguments'][0])
            if call['arguments'][1].get('name')!='values':raise ValueError('Bytes component source changed')
            call['arguments'][0]={'translated-slot':'BYTES_DESCRIPTOR'}
    tree={'wrappers':{name:form(f) for name,f in fs.items()},'completeCodec':form(library)}
    if bootstrap:(HERE/'structure.json').write_text(json.dumps(tree,indent=2)+'\n');(HERE/'entries.json').write_text(json.dumps(entries,indent=2)+'\n');return
    if tree!=json.loads((HERE/'structure.json').read_text()) or entries!=json.loads((HERE/'entries.json').read_text()):raise ValueError('Complete wrapper/codec AST drift')
    # Re-run the complete construction and inherited AST/SMT gates; emitted existing helper controls must remain byte-identical.
    texts,mapping,_,_=codec.generate((root/'contracts/lib/AbiCodec.sol').read_text(),str(solc))
    for name,text in texts.items():
        if text!=(ROOT/'formal/abi/construction'/name).read_text():raise ValueError('Codec generation drift '+name)
    code=(HERE/'Control.template.dfy').read_text()
    for name,value in slots.items():code=code.replace('$'+name+'$',value)
    if '$' in code:raise ValueError('Unexpanded slot')
    lines=code.splitlines();headers=[x for x in lines if x.startswith('include ')];body='\n'.join(x for x in lines if not x.startswith('include '))+'\n'
    formatted=subprocess.run(['/tmp/assertions-dafny-4.11.0/dafny/dafny','format','--stdin','--print'],input=body,text=True,check=True,capture_output=True).stdout
    (out/'Control.generated.dfy').write_text('\n'.join(headers)+'\n'+formatted); (out/'mapping.json').write_text(json.dumps({'entries':entries,'slots':slots,'helperBindings':bindings,'codecMapping':mapping,'compilerBookkeeping':'AST declaration-ID lists normalized; complete executable nodes retained, wrapper tuple target bound by actual referencedDeclaration and inherited codec gates freshly run.'},indent=2)+'\n')
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--solc',type=Path,required=True);p.add_argument('--root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);p.add_argument('--bootstrap',action='store_true');a=p.parse_args();generate(a.solc,a.root,a.output,a.bootstrap)
