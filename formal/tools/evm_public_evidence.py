"""Review finite public-call evidence without granting universal proof credit."""
import json
import re
from evm_public_resolve import canonical, sha, success_cases


def validate(report, profile):
    assert report['status'] == 'passed', 'Public calls did not pass'
    assert report['sourceAcceptance'] is False and report['bytecodeCredit'] is False
    assert report['scope'] == profile['scope']
    assert report['runtimeSha256'] == profile['runtimeSha256']
    expected = success_cases(profile)
    rows = report['cases']
    assert len(rows) == len(expected) >= 84, 'Missing public-call cases'
    assert profile['routes'] == [0,1,2] and profile['fetcher'] == 0 and profile['constraints'] == []
    assert profile['maximumPayloadLength'] >= 4096 and 4096 in profile['boundaryLengths']
    for row, case in zip(rows, expected):
        payload = bytes.fromhex(case['payload'])
        assert row['name'] == case['name'], 'Missing/reordered public-call case'
        assert row['route'] == case['route'] and row['length'] == len(payload)
        assert row['payloadSha256'] == sha(payload)
        assert row['gasBudget'] == case['gas'] and row['callValue'] == 0
        assert row['agree'] and row['specMatches'] and row['dafny'] == row['pyEvm']
        assert row['dafny']['kind'] == 'return' and row['dafny']['data'] == case['payload']
        assert 0 <= row['dafny']['gas'] <= row['gasBudget']
        assert row['steps'] == profile['successInstructionCount'] == 413
        assert row['pcsSha256'] == profile['successPcsSha256']
        assert re.fullmatch(r'[0-9a-f]{64}', row['traceSha256'])
    required = []
    kinds = {}
    for index in profile['gasBoundaryCaseIndexes']:
        cost = rows[index]['gasBudget']-rows[index]['dafny']['gas']
        for gas, kind in [(cost,'return'),(cost-1,'fault'),(0,'fault')]:
            name = f'gas-boundary-{index}-{gas}'
            required.append(name); kinds[name] = kind
    malformed = ['empty-calldata','short-selector','truncated-struct','truncated-payload',
                 'nonpayable-value','invalid-fetcher','data-offset-overflow','length-overflow']
    required += malformed+['driver-fuel-exhaustion']
    kinds.update({name:'revert' for name in malformed})
    assert [p['name'] for p in report['probes']] == required, 'Missing public rejection/boundary probe'
    assert all(p['expectationMet'] for p in report['probes'])
    for probe in report['probes'][:-1]:
        assert probe['agree'] and probe['dafny'] == probe['pyEvm']
        assert probe['dafny']['kind'] == kinds[probe['name']]
    assert len(report['mutations']) == len(profile['mutations']) >= 4, 'Missing public-call mutant'
    payload = next(c['payload'] for c in expected if c['route'] == 0 and len(bytes.fromhex(c['payload'])) == 33)
    for row, mutant in zip(report['mutations'],profile['mutations']):
        assert row['name'] == mutant['name'] and row['pc'] == mutant['pc']
        assert row['agree'] and row['killed'] and row['dafny'] == row['pyEvm']
        assert row['specMatches'] is False
        assert row['dafny']['kind'] != 'return' or row['dafny']['data'] != payload
    observations = report['outOfProfileObservations']
    assert len(observations) == 1
    assert observations[0]['name'] == 'unused-route-tag-outside-canonical-profile'
    assert observations[0]['agree'] and observations[0]['specMatches']
    assert observations[0]['dafny']['data'] == payload
    return {'publicCases':len(rows), 'publicProbes':len(report['probes']),
            'publicMutants':len(report['mutations'])}
