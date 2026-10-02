#!/usr/bin/env python3
"""Complete compiler/source binding for the reached modular-inverse library dependency closure."""
import argparse,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
EXPECTED={'Math.invMod(uint256,uint256)': {'sourceKey': 'npm/@openzeppelin/contracts@5.6.1/utils/math/Math.sol', 'library': 'Math', 'name': 'invMod', 'parameterTypes': ['uint256', 'uint256'], 'completeFunctionAstSha256': 'e1d2c11534c9b71a314b76b73773275b4370c8266d3ca5bda6eb8646b6a041f2'}, 'Math.ternary(bool,uint256,uint256)': {'sourceKey': 'npm/@openzeppelin/contracts@5.6.1/utils/math/Math.sol', 'library': 'Math', 'name': 'ternary', 'parameterTypes': ['bool', 'uint256', 'uint256'], 'completeFunctionAstSha256': '6ff651a98cc8b3f5e8691f1f8aa3d2bdde373a869db7c0fb17611597c754948a'}, 'SafeCast.toUint(bool)': {'sourceKey': 'npm/@openzeppelin/contracts@5.6.1/utils/math/SafeCast.sol', 'library': 'SafeCast', 'name': 'toUint', 'parameterTypes': ['bool'], 'completeFunctionAstSha256': '3e3facfab98339571fd2497c6d17773286deab462064b5f0268bfa403c40b2c1'}}
def normalize(n):
 if isinstance(n,dict):return {k:normalize(v) for k,v in n.items() if k not in ['id','src','referencedDeclaration','scope','typeDescriptions']}
 if isinstance(n,list):return [normalize(v) for v in n]
 return n
def generate(out):
 spec=importlib.util.spec_from_file_location('identity',HERE.parent/'identity.py');identity=importlib.util.module_from_spec(spec);spec.loader.exec_module(identity)
 artifact=json.loads((ROOT/'artifacts/contracts/Operations.sol/Operations.json').read_text());job=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.json')).read_text());compiled=json.loads((ROOT/'artifacts/build-info'/(artifact['buildInfoId']+'.output.json')).read_text());entries=[]
 for signature,pinned in EXPECTED.items():
  key=pinned['sourceKey'];source=identity.source_path(key);assert source.read_bytes()==job['input']['sources'][key]['content'].encode()
  lib=next(n for n in compiled['output']['sources'][key]['ast']['nodes'] if n.get('nodeType')=='ContractDefinition' and n.get('name')==pinned['library']);fns=[n for n in lib['nodes'] if n.get('nodeType')=='FunctionDefinition' and n.get('name')==pinned['name'] and [p['typeDescriptions']['typeString'] for p in n['parameters']['parameters']]==pinned['parameterTypes']];assert len(fns)==1
  ast=normalize(fns[0]);h=hashlib.sha256(json.dumps(ast,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert h==pinned['completeFunctionAstSha256'],signature
  entries.append({'signature':signature,**pinned,'sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),'completeNormalizedFunction':ast})
 out.mkdir(parents=True,exist_ok=True);(out/'dependencies.mapping.json').write_text(json.dumps({'status':'complete-source-dependency-preparation-not-proof','buildInfoId':artifact['buildInfoId'],'runtimeSha256':hashlib.sha256(bytes.fromhex(artifact['deployedBytecode'][2:])).hexdigest(),'entries':entries,'scope':'Complete reached Math.invMod, Math.ternary and SafeCast.toUint(bool) source ASTs bound to current compiler input. Exact compiled algorithm/finite-word loop correspondence and public retention remain open; no bytecode credit.'},indent=2)+'\n');print('Bound complete three-function imported inverse dependency AST closure')
if __name__=='__main__':
 a=argparse.ArgumentParser();a.add_argument('--output',type=Path,required=True);generate(a.parse_args().output)
