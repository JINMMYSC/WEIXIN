#!/usr/bin/env python3
import argparse, json

ap = argparse.ArgumentParser(description='Build a candidate reorder shim from black-box reference/replica captures.')
ap.add_argument('corpus')
ap.add_argument('reference')
ap.add_argument('replica')
ap.add_argument('-o','--output', required=True)
ap.add_argument('--prefix-limit', type=int, default=10)
a = ap.parse_args()
corpus=json.load(open(a.corpus, encoding='utf-8'))
ref=json.load(open(a.reference, encoding='utf-8'))
rep=json.load(open(a.replica, encoding='utf-8'))
probes={x['id']:x for x in corpus['probes']}
r={x['probeID']:x for x in ref['snapshots']}
p={x['probeID']:x for x in rep['snapshots']}
rules=[]
for pid in sorted(set(r)&set(p)):
    if pid not in probes or r[pid].get('candidates',[]) == p[pid].get('candidates',[]):
        continue
    local=set(p[pid].get('candidates',[]))
    desired=[x for x in r[pid].get('candidates',[])[:max(1,a.prefix_limit)] if x in local]
    if not desired:
        continue
    rules.append({
        'id':pid,
        'inputMode':probes[pid].get('inputMode') or 'pinyin26',
        'composition':p[pid].get('composition',''),
        'preferredCandidateOrder':desired,
        'hiddenCandidates':[]
    })
out={'formatVersion':1,'referenceImplementation':ref.get('implementation','WeType 3.5.3'),'rules':rules}
with open(a.output,'w',encoding='utf-8') as f: json.dump(out,f,ensure_ascii=False,indent=2)
print(f'wrote {len(rules)} safe reorder rules to {a.output}')
