# Complete conditional Collections source coverage

This package closes the **source coverage** inventory: 51 explicit function bodies,
29 public pure/view ABI entries, no public getters, constructors, receive or fallback
body, and no unmapped overload. It does not close the exact compiled-bytecode track.

`requirements.json` maps every body exactly once to retained source connection
methods. Every public entry maps to its complete public source composition; private
helper controls are also covered. Public caller proofs instantiate actual retained
codec/binding/call/memory helpers, rather than assuming their acceptance or calling
only an abstract output model. Sorting and uniqueness retain their exact arbitrary
observation semantics; coherent preorder/key equality/grouping premises apply only
to the stronger sorting/key-class theorems.

`generate.py` gates the entire normalized compiler Collections function AST and
all ABI input/output types, mutabilities and signatures against `structure.json`.
It obtains all 29 unique selectors from the pinned compiler and fills
`Boundary.template.dfy`. `Boundary.generated.dfy` proves round-trip correspondence,
selector injectivity, sound and complete abstract routing, unknown-selector
exclusion, and argument/result arities. This case-table theorem **does not prove**
compiler dispatch, ABI decoding, enum validation or return encoding. Those remain
explicit faithful compiler boundary premises of the source theorem family.

`audit.py` verifies all current source/tool/artifact hashes, original native CSV
rows, complete successful method/lemma declaration coverage and zero escape audit
through every recursively linked dependency manifest. It binds current compiler
AST/ABI coverage and ledger checks to the original proof methods and preserves
all original leaf scopes and assumptions in `coverage.json`.

`verify.py` freezes the finished package before source generation and native proof.
It copies all dependency manifests, runs the 21 existing source package checkers,
then retains native rows, zero audit and format results. A fresh second complete
coverage audit must match the first before completion. Concrete EVM fixtures and
semantic source mutation campaigns are inherited from the mapped packages; no new
fixture or mutation campaign is claimed by this completion audit.

The union of leaf representation and resource premises applies: finite faithfully
decoded strings/bytes/enums/structs/arrays, fitting cursor/packet/encoding/checked
arithmetic sizes, nonwrapping disjoint memory, successful allocation/copy and outer
serialization projections, adequate reached execution/stack/codec resources,
faithful source/compiler/context projections and truthful history-sensitive
external/code/gas observations. Logical byte/array theorems do not establish the
physical compiler allocator or serializer. Allocator guards and OOG are excluded
where the leaf theorem assumes successful allocation. No exact bytecode,
unbounded resource safety, gas, deployment, complexity or performance claim follows.

Run with the pinned tools:

```sh
python3 -B formal/collections/completion/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/completion/evidence/all-source-bodies
```
