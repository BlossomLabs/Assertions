# Public canonical value pairing

Targets `zipValues`, `unzipValues`, `_zipPlan` and `_unzipPair`. This package proves
conditional source semantics at the decoded ABI boundary. Read the retained
manifest for actual run status; development checks alone add no public coverage.
Exact compiled bytecode remains a separate incomplete track.

`Model` specifies the finite two-component framing checks independently: a
static pair is bare words; a dynamic pair starts with 0x20. Both dynamic offsets
must equal the next tail, the first dynamic boundary must not move backwards,
each slice must stay in bounds, and the final tail must consume the exact input.
`Source.Pair` connects the compiler-derived controls and actual retained word and
slice adapters to this specification. `Reconstruction.Reconstruct` proves every
successfully split pair reassembles to its original bytes without assuming either
component's canonicality. `Properties.SplitFrame` proves canonical construction
splits to the original two values in all four static/dynamic geometries.

`EntryModel` specifies raw public admission/error precedence and first reached
row failure. Zip checks length mismatch before either descriptor, then left/right
shapes and checked plan width. Unzip checks lane before descriptors. `Entry` calls
the actual parser/validator/assembler adapters and projects the full source loops,
logical output allocation, pair assignments and selected-lane writes. Zip validates
left before right at each original index. Unzip completes framing before validating
both components left then right; it validates the unselected lane too.
`Connection.Run` proves exact independent outcomes, row count, selected original
encodings, canonical zip pairs and byte-preserving successful unzip reassembly.
Separate per-row ghost methods expose only opaque row results to the quantified
public loops; their actual validation/assembly/reconstruction proofs stay local.
The count helpers expose scalar prefix bounds. Public per-row proofs establish
all canonicality/selection facts. The final composition controls unnecessary
recursive Tail unfolding while those Tail/source equations stay independently
verified in the linked entry proofs.

`Inverses.UnzipZip` calls the public source composition in both directions for
independent canonical side inputs. `Inverses.ZipUnzip` calls both public lane
projections and public zip for independently successful framing with both extracted
components canonical. These are explicit canonical input premises for the inverse
relations, not acceptance assumptions for the general public `Run` theorem. Both
inverse directions require representation/codec/allocation resources for the
intermediate produced inputs as well as their original inputs. Arrays are finite
but no chosen finite count/type-depth bound is imposed.

`generate.py` gates the complete four compiler ASTs and binds error selectors from
solc. Generated controls lower raw length/lane checks, validation/assignment/lane
indices, assembly array mode and envelope, checked head calculation and all split
guards. Remaining source statements are structurally fixed by the AST gate and
projected by the adapters. Edit `Control.template.dfy` and regenerate; never
hand-edit `Control.generated.dfy`.

Explicit premises include faithful finite decoded ABI strings/bytes/pointer arrays,
representable uint256 lengths/checked head/cursor/packet/encoding footprints, codec
resources covering invalid as well as valid values, source/compiler checked
arithmetic/calldata/context and byte-memory/MCOPY/MSTORE projections, logical array
writes, successful allocator/outer return serializer and adequate execution and
allocation resources. The split budget conservatively requires representable
head plus 64 and input bytes plus 32 after admission. Checked shape/head arithmetic
failure retains Panic(0x11). Compiler allocator guards/OOG and physical allocation
or return serialization behavior are outside the logical array/bytes theorem.
No callbacks/external observations occur. Exact bytecode, gas, complexity,
deployment and performance are separate and incomplete.

`verify.py` freezes every package file, including this README, before verifying
`Inverses.dfy` with all local declarations included. It checks identical transitive
dependency/tool/native/declaration/artifact closure, regeneration, isolated native
assertions, zero audit findings, formats, thirteen real EVM fixtures and six source
mutations in separate snapshots. Each mutation must translate and fail a native
semantic assertion covered by the baseline and a real EVM fixture. Timeout or
inconclusive results never count as detection. Finish package files before the
snapshot and poll a live run to completion without restarting on polling timeout.

```sh
python3 -B formal/collections/value-pairs/verify.py \
  --dafny /tmp/assertions-dafny-4.11.0/dafny/dafny \
  --solc /home/sem/.cache/hardhat-nodejs/compilers-v3/linux-amd64/solc-linux-amd64-v0.8.36+commit.8a079791 \
  --output formal/collections/value-pairs/evidence/public-canonical-pairs
```
