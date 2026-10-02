import shutil,json
from pathlib import Path
root=Path(__file__).resolve().parents[3];out=root/'formal/source/evidence/concat-correspondence-v1';snap=out/'snapshot';snap.mkdir(parents=True,exist_ok=False)
for rel in ['contracts/Operations.sol','contracts/lib/AbiCodec.sol','node_modules/@openzeppelin/contracts/utils/math/Math.sol','node_modules/@openzeppelin/contracts/utils/math/SafeCast.sol','node_modules/@openzeppelin/contracts/utils/Panic.sol','formal/operations/concat/ConcatOracle.t.sol']:
 target=snap/rel;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(root/rel,target)
for rel in ['formal/source/operations/concat/v1','formal/source/foundations/v1']:
 shutil.copytree(root/rel,snap/rel)
pkg=snap/'formal/source/operations/concat/v1'
for name in ['generate.py','structure.json','entries.json','Control.template.dfy']:shutil.copy2(root/'formal/operations/concat'/name,pkg/name)
(snap/'foundry.toml').write_text('[profile.default]\nsrc="contracts"\ntest="formal/operations/concat"\nsolc="/home/sem/assertions/proof-tools/assertions/solc-0.8.36"\noptimizer=true\noptimizer_runs=200\nevm_version="cancun"\nremappings=["@openzeppelin/contracts/=node_modules/@openzeppelin/contracts/"]\n[lint]\nlint_on_build=false\n')
script=(root/'formal/operations/concat/source-fault-audit.py').read_text().replace("here=root/'formal/operations/concat'","here=root/'formal/source/operations/concat/v1'")
(out/'source-fault-audit.py').write_text(script)
