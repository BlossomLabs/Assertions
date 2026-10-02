# Indexed bottom-up merge-sort foundation

This package proves the mathematical algorithm needed by both current Collections
sort paths. It tracks original occurrence IDs, so equal keys cannot conceal a
stability defect. It does not yet establish Solidity source correspondence.

The independent specification is recursive `Merge`. `MergeRange` implements the
indexed two-cursor/destination loop: choose the left head when both are available
and the relation accepts it, exhaust either run safely, and write one destination
slot per step. Its invariant connects the written prefix and remaining merge to
the full specification. Prefix/suffix frame conditions preserve every slot outside
the selected range. Multiset equality establishes occurrence preservation without
any comparator laws.

`Pass` merges adjacent runs into scratch, preserving completed blocks and the
exact occurrence interval of each run. `Sort` doubles run width, swaps buffers,
and terminates with a permutation of `0..n-1`. The counters are mathematical
naturals; allocation and uint256 arithmetic are later source obligations.

For ordering, `Order` requires a total preorder on the finite occurrence domain.
`Before` refines comparator ties by increasing original index. Adjacent runs have
separated original occurrence intervals, so the algorithm's left-biased comparison
implements this tie order. The final theorem establishes both global sortedness
and strict original-index order for equivalent occurrences. `SortKeys` derives
the order premise for arbitrary natural-number keys. The count/uniqueness proof
ensures that stability is about distinct occurrences, not just equal output bytes.

`UntrustedComparator` exhibits reversal of two occurrences under an always-false
relation. Permutation remains valid without comparator laws; global stability and
sortedness are not claimed for arbitrary malicious or history-sensitive callbacks.

## Source connection still required

Both production `sortWords` and `sortValues` currently use bottom-up merge sort.
The indexed algorithm here mirrors their cursor and buffer structure, but the
Solidity adapters must still be gated/translated and connected. Word memory reads,
writes, alignment and representation; value admission and validation; actual
binary callback preparation/cache/history; exact signed one-word comparison;
current merge-position callback indices and first failure all remain required.
A faithful external observation model may depend on history, caller and gas.
Suitable comparator consistency must be supplied only for ordering/stability;
successful source permutation must not assume callback determinism.

The full Collections scope remains 29 public entries. This mathematical package
adds no completed public source entry. Physical memory/allocation, uint256 bounds,
ABI boundaries and exact compiled bytecode remain separate obligations. No
complexity, gas, deployment or historical performance result is inferred.

The retained driver verifies every local theorem, declaration coverage, formatting,
source/tool/artifact hashes and a zero-finding audit. No EVM or source-fault result
is claimed for this abstract package.

```sh
PATH=/home/sem/.foundry/bin:$PATH python3 formal/collections/sort-core/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/sort-core/evidence/indexed-stable-merge-sort
```
