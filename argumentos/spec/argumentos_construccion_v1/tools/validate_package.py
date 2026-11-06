"""Valida este paquete y fixtures; NO certifica matemática ni evidencia."""
from pathlib import Path
import json, hashlib
R=Path(__file__).resolve().parents[1]
def validate(d):
    assert set(d)=={'schema_version','claims','arguments','evidence_specs'}, 'top_fields'
    assert d['schema_version']=='1.0','version'
    cs=d['claims']; args=d['arguments']; es=d['evidence_specs']
    ids=[x['id'] for x in cs+args+es]
    assert len(ids)==len(set(ids)), 'duplicate_id'
    C={c['id']:c for c in cs};E={e['id']:e for e in es}
    deps={i:[] for i in C}
    for c in cs:
        assert set(c)=={'id','book_key','kind','statement','expression','scope','assumptions'},'claim_fields'
        for p in c['assumptions']:
            assert p in C,'missing_assumption'
            deps[c['id']].append(p)
    for e in es:
        assert e['claim_id'] in C,'evidence_target'
        assert e['scope']==C[e['claim_id']]['scope'],'evidence_scope'
        assert e['availability'] in ('pending','candidate'),'self_approval'
    for a in args:
        assert a['conclusion'] in C,'missing_conclusion'
        c=C[a['conclusion']]
        for p in a['premises']:
            assert p in C,'missing_premise'
            deps[c['id']].append(p)
            assert C[p]['scope']==c['scope'],'scope_mismatch'
        for e in a['evidence_specs']:
            assert e in E and E[e]['claim_id']==c['id'],'evidence_link'
        if a['rule']=='MODUS_PONENS':
            assert len(a['premises'])==2,'mp_arity'
            ps=[C[p]['expression'] for p in a['premises']]
            ok=any(ps[j].get('op')=='implies' and ps[j]['antecedent']==ps[1-j] and ps[j]['consequent']==c['expression'] for j in (0,1))
            assert ok,'mp_conclusion'
        elif a['rule']=='EMPIRICAL_RECORD':
            assert c['kind']=='empirical','empirical_promotion'
            assert any(E[e]['kind']=='python' for e in a['evidence_specs']),'python_missing'
        elif a['rule']=='LEAN_ANCHOR':
            assert c['kind']=='formal','lean_kind'
            assert any(E[e]['kind']=='lean' for e in a['evidence_specs']),'lean_missing'
        else:
            raise AssertionError('fixture_rule_unsupported')
    active=set();done=set()
    def dfs(n):
        assert n not in active,'cycle'
        if n in done:return
        active.add(n)
        for p in deps[n]:dfs(p)
        active.remove(n);done.add(n)
    for n in C:dfs(n)
def main():
    checks=[]
    for p in sorted((R/'examples').glob('*.json')):
        expected=not p.name.startswith('invalid_')
        try:validate(json.loads(p.read_text()));ok=True;reason='structure_only_pending_evidence'
        except AssertionError as e:ok=False;reason=str(e)
        assert ok==expected,(p.name,reason)
        checks.append({'file':p.name,'expected_accept':expected,'reason':reason})
    m=R/'MANIFEST.sha256.json'
    if m.exists():
        for path,h in json.loads(m.read_text()).items():
            assert hashlib.sha256((R/path).read_bytes()).hexdigest()==h,('hash',path)
    print(json.dumps({'package_validation':'PASS','fixture_count':len(checks),'checks':checks,'limit':'Not the Rust implementation; no scientific proof certification'},ensure_ascii=False,indent=2))
if __name__=='__main__':main()
