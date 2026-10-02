#!/usr/bin/env python3
"""Repeat the body mutation campaign with a same-width extent fault.

The earlier +1 fault was refused by a preserved solc nameLocations field after
source locations shifted. That translator rejection is retained as incomplete;
this fault changes arithmetic without changing those source locations.
"""
import importlib.util
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('dynamic_mutations', HERE/'mutations.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)
runner.MUTATIONS[0] = (
    'body-extent', 'return x.base - p + x.tail;',
    'return x.base + p + x.tail;', 'AbiDynamicSource.BodyExtent', 2, 'all')
if __name__ == '__main__':
    code = runner.main()
    out = Path(sys.argv[sys.argv.index('--output')+1]).resolve()
    report = json.loads((out/'mutations.json').read_text())
    script = out/'campaign.py'
    script.write_bytes(Path(__file__).read_bytes())
    report['campaignScriptSha256'] = runner.sha(script)
    report['evidenceSha256']['campaign.py'] = runner.sha(script)
    (out/'mutations.json').write_text(json.dumps(report, indent=2)+'\n')
    sys.exit(code)
