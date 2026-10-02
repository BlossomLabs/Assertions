#!/usr/bin/env python3
"""Compiler-AST evidence for cached admission shapes, not a parse-count theorem.
Compilation is standard-json in memory; it never updates canonical artifacts.
"""
import copy,importlib.util,sys,unittest,json,re
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('claim_structure',HERE/'test-claim-structure.py');helper=importlib.util.module_from_spec(spec);spec.loader.exec_module(helper)
def walk(node):
 if isinstance(node,dict):
  yield node
  for value in node.values():yield from walk(value)
 elif isinstance(node,list):
  for value in node:yield from walk(value)
def codec_calls(node,name):
 return [n for n in walk(node) if n.get('nodeType')=='FunctionCall' and n.get('expression',{}).get('nodeType')=='MemberAccess' and n['expression'].get('memberName')==name and n['expression'].get('expression',{}).get('name')=='AbiCodec']
def expression_contract(output):
 return next(n for n in output['sources']['contracts/Expressions.sol']['ast']['nodes'] if n.get('nodeType')=='ContractDefinition' and n['name']=='Expressions')
def check_cache(contract):
 functions={n['name']:n for n in contract['nodes'] if n.get('nodeType')=='FunctionDefinition'}
 admission=functions['evaluate'];evaluate=functions['_evaluate'];shape=codec_calls(contract,'shape')
 assert len(shape)==1,'exactly one top-level shape call site'
 loops=[n for n in admission['body']['statements'] if n.get('nodeType')=='ForStatement'];assert len(loops)==1
 loop=loops[0];assignment=loop['body']['statements'][1];assert assignment['nodeType']=='ExpressionStatement'
 expression=assignment['expression'];assert expression['nodeType']=='Assignment'
 assert codec_calls(expression['rightHandSide'],'shape')==shape
 argument=shape[0]['arguments'][0]
 assert argument['nodeType']=='FunctionCall' and argument['expression']['typeName']['name']=='bytes'
 member=argument['arguments'][0]
 assert member['nodeType']=='MemberAccess' and member['memberName']=='valueType' and member['expression']['name']=='node'
 binding=loop['body']['statements'][0]
 assert binding['nodeType']=='VariableDeclarationStatement' and binding['declarations'][0]['name']=='node'
 source=binding['initialValue']
 assert source['nodeType']=='IndexAccess' and source['indexExpression']['name']=='i'
 assert source['baseExpression']['memberName']=='nodes' and source['baseExpression']['expression']['name']=='expression'
 left=expression['leftHandSide']['components'];assert len(left)==2
 assert [n['baseExpression']['memberName'] for n in left]==['dynamic','words']
 assert all(n['baseExpression']['expression']['name']=='cache' and n['indexExpression']['name']=='i' for n in left)
 initial=loop['initializationExpression']
 assert initial['nodeType']=='VariableDeclarationStatement' and len(initial['declarations'])==1
 assert initial['declarations'][0]['name']=='i'
 value=initial.get('initialValue')
 assert value is None or (value['nodeType']=='Literal' and value.get('value')=='0')
 increment=loop['loopExpression']['expression']
 assert increment['nodeType']=='UnaryOperation' and increment['operator']=='++' and increment['subExpression']['name']=='i'
 assert loop['condition']['operator']=='<' and loop['condition']['leftExpression']['name']=='i' and loop['condition']['rightExpression']['name']=='count'
 count=next(n for n in admission['body']['statements'] if n.get('nodeType')=='VariableDeclarationStatement' and n['declarations'][0]['name']=='count')
 assert count['initialValue']['memberName']=='length' and count['initialValue']['expression']['memberName']=='nodes'
 validations=codec_calls(evaluate,'validate');assert len(validations)==1
 args=validations[0]['arguments'];assert len(args)==4
 assert [n['baseExpression']['memberName'] for n in args[2:]]==['dynamic','words']
 assert all(n['baseExpression']['expression']['name']=='cache' and n['indexExpression']['name']=='index' for n in args[2:])
 assert not codec_calls(evaluate,'shape')
 # Admission loop must precede the evaluator call in the public body.
 pos=admission['body']['statements'].index(loop)
 evaluator=[i for i,n in enumerate(admission['body']['statements']) if any(x.get('nodeType')=='FunctionCall' and x.get('expression',{}).get('name')=='_evaluate' for x in walk(n))]
 assert evaluator and all(i>pos for i in evaluator)
class CoverageStructureTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.contract=expression_contract(helper.compile_sources(helper.source_closure()))
 def test_W30_inlined_runtime_matches_pinned_fixture_bytes_and_hash_field(self):
  fixture=json.loads((helper.ROOT/'test/fixtures/biconomy-erc8211.json').read_text())
  inline=(helper.ROOT/'contracts/tests/BiconomyERC8211Runtime.sol').read_text()
  runtime=re.search(r'BICONOMY_ERC8211_RUNTIME\s*=\s*hex"([0-9a-fA-F]+)"',inline)
  self.assertIsNotNone(runtime)
  self.assertEqual('0x'+runtime.group(1).lower(),fixture['bytecode'].lower())
  hash_field=re.search(r'BICONOMY_ERC8211_RUNTIME_HASH\s*=\s*(0x[0-9a-fA-F]+)',inline)
  self.assertIsNotNone(hash_field)
  self.assertEqual(hash_field.group(1).lower(),fixture['runtimeHash'].lower())
 def test_E42_admission_shape_metadata_reused_by_validation(self):check_cache(self.contract)
 def test_E42_checker_detects_missing_cached_words_argument(self):
  mutant=copy.deepcopy(self.contract)
  validate=codec_calls(next(n for n in mutant['nodes'] if n.get('name')=='_evaluate'),'validate')[0]
  validate['arguments'][3]['baseExpression']['memberName']='dynamic'
  with self.assertRaises(AssertionError):check_cache(mutant)
 def test_E42_checker_detects_wrong_descriptor_input(self):
  mutant=copy.deepcopy(self.contract)
  shape=codec_calls(mutant,'shape')[0]
  shape['arguments'][0]['arguments'][0]['memberName']='arguments'
  with self.assertRaises(AssertionError):check_cache(mutant)
 def test_E42_checker_detects_wrong_iterator_increment(self):
  mutant=copy.deepcopy(self.contract)
  admission=next(n for n in mutant['nodes'] if n.get('name')=='evaluate')
  loop=next(n for n in admission['body']['statements'] if n.get('nodeType')=='ForStatement')
  loop['loopExpression']['expression']['operator']='--'
  with self.assertRaises(AssertionError):check_cache(mutant)
if __name__=='__main__':unittest.main(verbosity=2)
