#!/usr/bin/env python3
"""Refresh execution labels, counts and claim mappings from the retained baseline."""
from pathlib import Path
import re,json,collections,hashlib,argparse
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--baseline', default='docs/verification/halmos-coverage')
args=parser.parse_args()
root=Path(__file__).resolve().parents[1];p=root/'docs/claims.md';s=p.read_text();dest=root/args.baseline
m=json.loads((dest/'manifest.json').read_text())
if not m.get('completedAt'):raise SystemExit('Baseline still running; refusing proof labels')
assert len(m['results'])==m['inventoryCount'] and m['inventoryCount']>0
current={str(path.relative_to(root)):hashlib.sha256(path.read_bytes()).hexdigest() for path in (root/'contracts').rglob('*.sol')}
assert current==m['sourceSha256'], 'Baseline source drift: rerun every property before refreshing proof labels'
checks=json.loads((dest/'checks.json').read_text())
assert checks['revision']==m['revision'], 'Concrete and symbolic revisions differ'
assert all(c['exitCode']==0 for c in checks['checks'] if not c['name'].startswith('format-')), 'Concrete check failed'
props={r['property']:r for r in m['results']}
assert len(props)==len(m['results'])
rows={}
for l in s.splitlines():
 match=re.match(r'\| ([CAWOLER]\d+) \|',l)
 if match:rows[match[1]]=[v.strip() for v in l.split('|')[1:-1]]
# Explicit symbolic dependencies for rows stated in terms of other rows.
derived={'E48':['E1','E2','E3','E4','E5','E21','E22','E23']}
links={}
def properties(id,stack=()):
 if id in stack:raise ValueError(id)
 row=rows[id];evidence=row[3];names=set()
 for token in re.findall(r'\bcheck_[A-Za-z0-9_]+\*?',evidence):
  names.update(k for k in props if k.startswith(token[:-1])) if token.endswith('*') else names.add(token)
 for n in names:
  if n not in props:raise ValueError('Unknown property '+id+': '+n)
 if 'check_*' in evidence:
  files=re.findall(r'(?:contracts/tests/)?([A-Za-z0-9]+Symbolic\.t\.sol)',evidence)
  names.update(k for k,r in props.items() if Path(r['source']).name in files)
 for dep in derived.get(id,[]):names.update(properties(dep,stack+(id,)))
 return sorted(names)
new={};count=collections.defaultdict(collections.Counter)
for id,row in rows.items():
 if len(row)==7:row=row[:5]+row[6:] # permit a deliberate refresh
 kind='SYMBOLIC' if row[4]=='PROVED' else row[4]
 names=properties(id)
 if kind=='SYMBOLIC':
  statuses=[props[n]['status'] for n in names]
  status='UNVERIFIED' if not statuses else 'FAILED' if 'failed' in statuses else 'INCOMPLETE' if 'incomplete' in statuses else 'PROVED'
 elif kind=='UNBACKED':status='UNVERIFIED'
 elif kind=='RESOLVED':status='HISTORICAL'
 else:status='SUITE PASSED'
 new[id]=row[:4]+[kind,status,row[5]]
 links[id]={'evidenceType':kind,'executionStatus':status,'properties':[{'contract':props[n]['contract'],'property':n,'status':props[n]['status'],'log':props[n]['log']} for n in names], 'partial':row[5].startswith('Partial:')}
 count[id[0]]['Claims']+=1;count[id[0]][kind]+=1;count[id[0]][status]+=1;count[id[0]]['Partial']+=row[5].startswith('Partial:')
 if kind=='SYMBOLIC' and not names:print('UNMAPPED SYMBOLIC',id,row[3])
lines=[]
for l in s.splitlines():
 match=re.match(r'\| ([CAWOLER]\d+) \|',l)
 if match:l='| '+' | '.join(new[match[1]])+' |'
 elif l=='| # | Claim | Source(s) | Evidence | Strength | Notes |':l='| # | Claim | Source(s) | Evidence | Evidence type | Execution | Notes |'
 elif l=='|---|---|---|---|---|---|':l='|---|---|---|---|---|---|---|'
 lines.append(l)
s='\n'.join(lines)+'\n'
cols=['Claims','SYMBOLIC','PROVED','FAILED','INCOMPLETE','DIFFERENTIAL','FUZZED','UNIT','UNBACKED','RESOLVED','Partial']
labels={'C':'Assertions core','A':'AbiCodec','W':'ERC8211 wire format','O':'Operations','L':'Collections','E':'Expressions','R':'Release/environment'}
summary='| Group | '+' | '.join(cols)+' |\n|---|'+'---|'*len(cols)+'\n'
total=collections.Counter()
for prefix in 'CAWOLER':
 c=count[prefix];total.update(c);summary+='| '+labels[prefix]+' ('+prefix+') | '+' | '.join(str(c[k]) for k in cols)+' |\n'
summary+='| **Total** | '+' | '.join('**'+str(total[k])+'**' for k in cols)+' |\n\nPROVED and INCOMPLETE are execution counts within SYMBOLIC, not additional claims. Partial counts overlap evidence types. All '+str(m['inventoryCount'])+' properties are accounted for: '+', '.join(str(m['summary'][k])+' '+k for k in ['passed','failed','incomplete'])+'.'
if '<!-- verification-summary -->' in s:s=s.replace('<!-- verification-summary -->',summary)
else:s=re.sub(r'(?s)(## Summary\n\n).*?(\n\n## Assertions core)',lambda x:x[1]+summary+x[2],s,count=1)
p.write_text(s)
(dest/'claims.json').write_text(json.dumps({'source':'docs/claims.md','baseline':'manifest.json','claimCount':len(new),'uncitedProperties':sorted(set(props)-{p['property'] for c in links.values() for p in c['properties']}),'totals':dict(total),'claims':links},indent=2)+'\n')
print('claims',len(new),'totals',dict(total))
