#!/usr/bin/env python3
"""Check faithful source faults with whole healthy/mutated early-witness methods.

The baseline admission premises remain in every witness. Two controls constrain
an actual admitted early branch, so the full method proves all callee
preconditions without selecting a postcondition position. The mutable source
translation is untouched; a separate witness changes only module name and one
explicit requires clause. Original postconditions and complete body stay exact.
"""
import argparse,csv,json,re,shutil,subprocess,datetime
from pathlib import Path
FAULTS=[
 ('inverted-alignment','if (s.length % 32 != 0) revert UnalignedWords(s.length);\n        return _fold(FoldDomain.Words','if (s.length % 32 == 0) revert UnalignedWords(s.length);\n        return _fold(FoldDomain.Words','Run','k.domain == Call.Words && |k.subject| == 0 && Admission(k).Accepted?','testAllEmptyWrappersSkipTarget'),
 ('wrong-byte-count','return _fold(FoldDomain.Bytes, s.length, s,','return _fold(FoldDomain.Bytes, s.length / 32, s,','Build','', 'testNonemptyCodeLessTarget'),
 ('premature-empty-return','if (count == 0) return init;','if (count != 0) return init;','Run','k.domain == Call.Bytes && |k.subject| == 1 && Admission(k).Accepted? && k.code(h,k.target) == 0','testNonemptyCodeLessTarget')]
FORBIDDEN=r'time.?out|inconclusive|resource limit|type error|resolution error|parse error|precondition for this call'
MODULE='CollectionsWordFoldEntrySourceWitness'
def witness(source,extra):
 old='module CollectionsWordFoldEntrySource {';assert source.count(old)==1;source=source.replace(old,'module '+MODULE+' {')
 if extra:
  anchor='    requires Basic(k) && Budget(k,h,memory,base)\n';assert source.count(anchor)==1;source=source.replace(anchor,anchor+'    requires '+extra+'\n')
 return source

def proof_command(dafny,file,csvpath,symbol):
 return [str(dafny),'verify',str(file),'--verify-included-files','--manual-lemma-induction','--isolate-assertions','--cores','2','--verification-time-limit','30','--solver-path',str(dafny.parent/'z3/bin/z3-4.12.1'),'--log-format','csv;LogFileName='+str(csvpath),'--filter-symbol',symbol,'--filter-position',str(file),'--progress','Symbol']
def main():
 p=argparse.ArgumentParser();p.add_argument('--snapshot',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--dafny',type=Path,required=True);p.add_argument('--solc',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
 sourceRelative=Path('formal/collections/word-fold-entry/Source.generated.dfy');canonical=(a.snapshot/sourceRelative).read_text();results=[]
 for name,old,new,method,extra,evmTest in FAULTS:
  root=a.output/name;shutil.copytree(a.snapshot,root,ignore=shutil.ignore_patterns('out','cache','evidence'));here=root/sourceRelative.parent;result=dict(name=name,old=old,new=new,wholeMethod=True,selectedNativeSymbol=MODULE+'.'+method,witnessRequires=extra,baselineAdmissionPreserved=True,expectedEvmTest=evmTest,checks=[])
  healthy=here/'BaselineWitness.generated.dfy';healthy.write_text(witness(canonical,extra));mutated=here/'MutationWitness.generated.dfy'
  def run(label,command):
   command=list(map(str,command));process=subprocess.run(command,capture_output=True,text=True);body=process.stdout+process.stderr;(root/(label+'.log')).write_text(body);job=dict(name=label,command=command,exitCode=process.returncode,passed=False);result['checks'].append(job);return job,body
  job,body=run('healthy-proof',proof_command(a.dafny,healthy,root/'healthy-proof.csv',result['selectedNativeSymbol']));rows=list(csv.DictReader((root/'healthy-proof.csv').open()))if(root/'healthy-proof.csv').exists()else[];job['passed']=job['exitCode']==0 and bool(rows)and all(r['TestResult.Outcome']=='Passed'for r in rows)and not re.search(FORBIDDEN,body,re.I);job['nativeObligations']=len(rows)
  if not job['passed']:raise RuntimeError('Healthy whole witness failed: '+name)
  source=root/'contracts/Collections.sol';text=source.read_text();assert text.count(old)==1;source.write_text(text.replace(old,new));command=['python3','-B',str(here/'generate.py'),'--root',str(root),'--solc',str(a.solc),'--output',str(root/'generated')];job,body=run('source-gate',command);job['passed']=job['exitCode']==0
  if not job['passed']:raise RuntimeError('Source translation failed: '+name)
  translated=(root/'generated/Source.generated.dfy').read_text();mutated.write_text(witness(translated,extra));lines=mutated.read_text().splitlines();oracle='    ensures Build(k) == LoopConfig(k)'if method=='Build'else'    ensures out == Judge(k,h)';assert lines.count(oracle)==1;result['semanticAssertion']=dict(line=lines.index(oracle)+1,text=oracle,file=str(mutated.relative_to(root)))
  job,body=run('proof',proof_command(a.dafny,mutated,root/'proof.csv',result['selectedNativeSymbol']));rows=list(csv.DictReader((root/'proof.csv').open()))if(root/'proof.csv').exists()else[];errors=re.findall(r'^.*\((\d+),(\d+)\): Error: (.*)$',body,re.M);job['passed']=job['exitCode']!=0 and bool(rows)and any(r['TestResult.Outcome']=='Failed'for r in rows)and all(r['TestResult.Outcome']in{'Passed','Failed'}for r in rows)and 'postcondition could not be proved'in body and not re.search(FORBIDDEN,body,re.I)and bool(errors)and all('postcondition could not be proved'in e[2]for e in errors);job['nativeObligations']=len(rows)
  if not job['passed']:raise RuntimeError('Not a clean whole-method semantic failure: '+name)
  job,body=run('concrete',['forge','test','--root',str(root),'--match-contract','^(WordFoldEntryOracleTest|WordFoldLoopOracleTest)$','-vv']);job['passed']=job['exitCode']!=0 and bool(re.search(r'^\[FAIL[^\n]*\] '+re.escape(evmTest)+r'\(',body,re.M))
  if not job['passed']:raise RuntimeError('Matching full EVM witness did not contradict: '+name)
  for relative in ['out','cache']:shutil.rmtree(root/relative,ignore_errors=True)
  results.append(result);(a.output/'results.json').write_text(json.dumps(results,indent=2)+'\n');print(name,'healthy whole witness, clean whole mutation and matching EVM contradiction passed',flush=True)
 print('PASS: three faithful source controls; every baseline admission retained, complete healthy/changed methods with all preconditions checked, ordinary semantic postcondition failures and matching full EVM contradictions')
if __name__=='__main__':main()
