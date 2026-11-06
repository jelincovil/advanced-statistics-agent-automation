from pathlib import Path
import json,sys
try:
    from jsonschema import Draft202012Validator
except ImportError:
    print('SKIP: jsonschema absent');sys.exit(2)
r=Path(__file__).resolve().parents[1]
s=json.loads((r/'schemas/kernel.schema.json').read_text())
Draft202012Validator.check_schema(s)
v=Draft202012Validator(s)
for f in ['valid_structure_pending.json','lean_anchor_pending.json','empirical_pending.json']:
    v.validate(json.loads((r/'examples'/f).read_text()))
assert list(v.iter_errors(json.loads((r/'examples/invalid_self_approval.json').read_text())))
print('PASS: schema + 3 positive fixtures + self-approval rejection; semantic negatives belong to checker')
