#!/usr/bin/env python3
"""Validate whole completed native modules against the identical current closure.

A failed prior attempt is never promoted to passed. Only individually complete
passed modules are reusable, after its full207-module native matrix is terminal.
No partial or timed-out rows can be reused. All new physical/fault gates still run.
"""
import copy,json,re,shutil
from pathlib import Path

EXPECTED_TIMEOUTS = {'proof-BytecodeApplyRawTemplateCopy','proof-BytecodeApplyRawSuccessfulEntry'}


def prepare(root, prior, spec, closed, hashes, tool_hashes, getter, common, output):
    prior = prior.resolve()
    assert prior.is_relative_to(root) and prior.name == 'manifest.json'
    raw = prior.read_bytes()
    old = json.loads(raw)
    assert old['status'] in {'failed','passed'} and old.get('completedAt'), 'Prior run must actually be terminal'
    assert old['rootProofs'] == spec['rootProofs'] and old['publicEntries'] == spec['publicEntries']
    assert old['scope'] == spec['scope'] and old['assumptions'] == spec['assumptions']
    assert old['executableSha256'] == tool_hashes
    graph = {str(p.relative_to(root)): common.sha(p) for p in closed}
    assert graph == old['dependencyGraph'], 'Entire included native graph must be identical'
    for name, digest in old['sourceSha256'].items():
        assert hashes.get(name) == digest
        assert common.sha(root/name) == digest
        assert common.sha(prior.parent/'source-snapshot'/name) == digest
    failed = {j['name'] for j in old['checks'] if j.get('passed') is False}
    assert failed <= EXPECTED_TIMEOUTS, 'Unexpected prior failure requires review'
    owners = {re.search(r'^module (\w+)',p.read_text(),re.M)[1]:p for p in closed if re.search(r'^module (\w+)',p.read_text(),re.M)}
    jobs = [j for j in old['checks'] if isinstance(j.get('nativeResults'),list)]
    assert len(jobs) == len(owners) == 207
    assert {j['name'] for j in jobs} == {'proof-'+m for m in owners}
    assert len(jobs) == len({j['name'] for j in jobs})
    for proof in spec['rootProofs']:
        job = next(j for j in old['checks'] if j['name']=='audit-'+Path(proof).parent.name)
        assert job['passed'] and job['exitCode']==0
        log = prior.parent/job['log'];assert common.sha(log)==old['evidenceSha256'][job['log']]
        assert 'auditor completed with 0 findings' in log.read_text()
    target = output/'prior-native';target.mkdir()
    (target/'manifest.json').write_bytes(raw)
    reusable = {}
    for job in jobs:
        if not job['passed']:
            assert job['name'] in EXPECTED_TIMEOUTS and job['exitCode']==4
            log=prior.parent/job['log'];assert common.sha(log)==old['evidenceSha256'][job['log']]
            assert '0 errors' in log.read_text() and 'timed out after 30 seconds' in log.read_text()
            continue
        name=job['name'];module=name.removeprefix('proof-');source=owners[module]
        old_source=prior.parent/'source-snapshot'/source.relative_to(root)
        csv=prior.parent/(name+'.csv');log=prior.parent/job['log']
        expected=common.proof_command(Path(job['command'][0]),old_source,csv)+['--filter-symbol',module,'--filter-position',str(old_source),'--progress','Symbol']
        assert job['command']==list(map(str,expected)), 'Only original complete module command is reusable'
        assert job['exitCode']==0
        for p in [log,csv]:
            assert common.sha(p)==old['evidenceSha256'][str(p.relative_to(prior.parent))]
            shutil.copy2(p,output/p.name)
        checked=copy.deepcopy(job)
        common.check_proof(checked,output/log.name,output/csv.name,getter.inventory(source))
        assert checked['passed'] and checked['nativeResults']==job['nativeResults'] and checked['declarations']==job['declarations']
        checked['nativeEvidenceOrigin']='reused-completed-whole-module-identical-full-input-closure'
        checked['priorManifest']=str(prior.relative_to(root))
        checked['priorManifestSha256']=common.sha(prior)
        checked['priorLogSha256']=common.sha(log);checked['priorCsvSha256']=common.sha(csv)
        reusable[name]=checked
    assert common.sha(prior)==common.sha(target/'manifest.json')
    return reusable, {'manifest':str(prior.relative_to(root)),'manifestSha256':common.sha(prior),'status':old['status'],'completedAt':old['completedAt'],'identicalPriorInputFiles':len(old['sourceSha256']),'reusedCompleteModules':len(reusable),'failedModulesNotReused':sorted(failed),'scope':'Prior failed attempt preserved. Only complete whole passed module logs/CSV under identical entire captured source/tool closure reused; all current generation/audits/physical/semantic/dependency checks remain fresh. Ordinary120 seconds only for two previously timed-out modules, same statements/domains/postconditions.'}


def repair(root, manifest, spec, closed, tool_hashes, getter, common, output):
    manifest = manifest.resolve()
    assert manifest.is_relative_to(root) and manifest.name == 'manifest.json'
    old = json.loads(manifest.read_text())
    assert old['status']=='development-native-passed-not-retained' and old['inputsUnchanged'] and old['toolsUnchanged'] and old.get('completedAt')
    assert all(j['passed'] for j in old['checks'])
    assert old['executableSha256']=={k:v for k,v in tool_hashes.items() if k!='solc'}
    selected=[root/'formal/bytecode/word-apply/raw-template/Connection.dfy',root/'formal/bytecode/word-apply/raw-success/Connection.dfy']
    assert old['selectedSources']==[str(p.relative_to(root)) for p in selected]
    graph=set()
    def visit(p):
        p=p.resolve();assert p.is_relative_to(root) and p in closed
        if p in graph:return
        graph.add(p)
        for inc in re.findall(r'^include "([^"]+)"',p.read_text(),re.M):visit(p.parent/inc)
    for p in selected:visit(p)
    assert old['dependencyGraph']=={str(p.relative_to(root)):common.sha(p) for p in graph}
    for name,digest in old['sourceSha256'].items():
        assert common.sha(root/name)==digest and common.sha(manifest.parent/'source-snapshot'/name)==digest
    dest=output/'prior-repair';dest.mkdir();shutil.copy2(manifest,dest/'manifest.json')
    result={}
    jobs=[j for j in old['checks'] if isinstance(j.get('nativeResults'),list)]
    assert {j['name'] for j in jobs}==EXPECTED_TIMEOUTS and len(jobs)==2
    for source in selected:
        module=re.search(r'^module (\w+)',source.read_text(),re.M)[1];name='proof-'+module
        job=next(j for j in jobs if j['name']==name)
        snapshot=manifest.parent/'source-snapshot'/source.relative_to(root)
        csv=manifest.parent/(name+'.csv');log=manifest.parent/job['log']
        expected=common.proof_command(Path(job['command'][0]),snapshot,csv)
        assert expected.count('--verification-time-limit')==1
        expected[expected.index('--verification-time-limit')+1]='120'
        expected+=['--filter-symbol',module,'--filter-position',str(snapshot),'--progress','Symbol']
        assert job['command']==list(map(str,expected)) and job['exitCode']==0 and job['passed']
        audit=next(j for j in old['checks'] if j['name']=='audit-'+module)
        assert audit['exitCode']==0 and audit['passed']
        auditlog=manifest.parent/audit['log']
        assert common.sha(auditlog)==old['evidenceSha256'][audit['log']] and 'auditor completed with 0 findings' in auditlog.read_text()
        for p in [csv,log]:
            assert common.sha(p)==old['evidenceSha256'][str(p.relative_to(manifest.parent))]
            shutil.copy2(p,output/p.name)
        checked=copy.deepcopy(job)
        common.check_proof(checked,output/log.name,output/csv.name,getter.inventory(source))
        assert checked['passed'] and checked['nativeResults']==job['nativeResults'] and checked['declarations']==job['declarations']
        checked['nativeEvidenceOrigin']='reused-completed-unchanged-120-second-repair-module-identical-current-include-closure'
        checked['priorRepairManifest']=str(manifest.relative_to(root));checked['priorRepairManifestSha256']=common.sha(manifest)
        checked['priorLogSha256']=common.sha(log);checked['priorCsvSha256']=common.sha(csv)
        result[name]=checked
    assert common.sha(manifest)==common.sha(dest/'manifest.json')
    return result,{'manifest':str(manifest.relative_to(root)),'manifestSha256':common.sha(manifest),'completedAt':old['completedAt'],'completeRepairModules':2,'includedModuleFiles':len(graph),'currentAndSnapshotInputFiles':len(old['sourceSha256']),'scope':'Two original timed-out modules proved under identical current complete include closure; statements/domains/postconditions unchanged, ordinary120 seconds, full module commands/inventories/CSV/log/tool/snapshot closure rechecked. Development status alone gives no public credit; this fresh full retainer closes all other native/physical/fault/dependency gates.'}
