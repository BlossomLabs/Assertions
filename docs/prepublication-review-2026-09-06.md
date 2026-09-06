# Assertions pre-publication review — 2026-09-06

Reviewed Assertions `fbaf788`, its four production Solidity sources, Solidity
and differential tests, deployment exports, and builder integration. Findings
below are fixed in the accompanying commits. This is a targeted review, not an independent
security audit.

## Contract findings fixed

### P2 — LEN accepted incomplete dynamic encodings

`Assertions._navLength` returned the claimed length without checking that its
payload existed. `abi.encode(32, 999)` reported 999 for `uint256[]`, `bytes` and
`string`, although normal ABI decoding rejected each value. A length constraint
could therefore pass on malformed external returndata.

LEN now checks padded bytes/string payload extent and array head extent, using
division to avoid overflow from hostile counts. Multiword static elements and
dynamic-element arrays remain supported. Dynamic element tails are not recursively
validated. Three regression tests cover missing payloads, hostile lengths, padding,
head footprints and empty values. Disabling the bounds checks causes all three
regressions to fail. The standalone `scripts/probe-nav-length.ts` confirms that
all three original malformed examples now revert on the local EVM.

### P2 — rpow's accuracy promise was incorrect

The NatSpec claimed rounding error was bounded by approximately `2 * log2(n)`
output units. Early rounding loss can be amplified by later squarings:
`rpow(19, 16, 10)` returns 276889, whereas flooring the exact rational result once
returns 288441, a difference of 11552 rather than at most 8.

Corrected the NatSpec and website documentation and added an independent
rational-power regression. The arithmetic algorithm is unchanged. Also corrected
fold/map window-order comments, empty-domain validation comments, and the misplaced
`uniqueWords` NatSpec.

## Regenerated deployment and compiler integration

The user explicitly permitted new addresses. Keeping the existing salts produces:

| Contract | New CREATE2 address | Runtime bytes |
| --- | --- | --- |
| Assertions | `0x67DBB438FdC614466984Dc8F68dAB812d785a2aE` | 13,116 |
| Operators | `0x7AD80f224A8473A4206ad486e5b6b4e4367D17AD` | 17,042 |

Both fit the EIP-170 limit of 24,576 bytes. Deployment bytecodes, verification
inputs, documentation, SDK addresses and EVM test fixtures have been synchronized.

The website pins published EVMcrispr commit
[`6513da6c4407f912d41a6490995afb6ff204b498`](https://github.com/EVMcrispr/evmcrispr/commit/6513da6c4407f912d41a6490995afb6ff204b498),
on `codex/assertions-len-validation`. It contains the address/fixture update on
top of latest verified published `next`, `4fd8ed6b6c8c53c88251a71e3584f9cae09038c9`.
The compatibility branch was pushed so fresh website builds can fetch the pin;
`next` itself was not changed.

## Integration findings fixed

- Registered `contracts` in the builder: generated code-hash expressions and
  documented `load contracts` scripts previously had no module loader.
- Adapted chat to the new `{ kind, message }` error API; payment-required probes
  do not discard a working key even when the response contains auth-like text.
- Restricted hash/byte-length forms to strings and bytes, matching the compiler's
  existing `requireBytesLike` guard. Array hashing was still offered by the UI.
- Corrected fold/map/filter signatures and examples to `uint256[] elemOffsets`,
  and documented validation of template windows even for empty domains.
- Documented the pinned compiler, supported builder modules, and `@sender`
  versus wallet `@me` and transaction-origin `@tx.from!`; updated assistant guidance.
- Made preparation explicit in dev/build/IPFS scripts. The installed pnpm does
  not execute the previous implicit prebuild hook, allowing stale vendor code.
- Removed forced vendor checkout; dirty trees are rejected. A readiness stamp
  is written only after installation and codegen, allowing failed preparations
  to retry even when HEAD already equals the pin.
- Added a shared source-alias configuration and an offline integration gate
  checking real builder compilation and deployment/SDK/fixture agreement.

## Verification

| Check | Result |
| --- | --- |
| `pnpm test` outside the sandbox | 370 passing: 291 Solidity, 79 nodejs |
| LEN reproducer | All three malformed payloads rejected |
| SDK suite against updated fixtures | 218 passing |
| Lang onchain/parity/parity-strings suites | 136 passing |
| `cd website && pnpm test:vendor` | 2 passing |
| `cd website && pnpm check:integration` | 9 scripts compile; invalid byte operands rejected; both artifact sets match |
| `cd website && pnpm build` | 17 pages built |
| Browser | Builder hydrated without captured warnings/errors; updated documentation rendered |

The integration gate compares exact creation bytecodes, exact runtime fixtures
and hashes, SDK addresses and independently derived CREATE2 addresses. Examples
cover code hashes, environment, array lengths, byte/string operations, math,
executor identity and multiple live dynamic arguments.

Full static type checking remains a limitation: the existing broad website
`tsconfig` causes both tested TypeScript versions to exhaust their stacks. A
narrowed diagnostic run also exposed duplicate dependency types and stale npm
SDK declarations. No passing full type check is claimed. The build warns that
sitemap generation needs an Astro `site` setting. Wallet signing, paid chat and
live deployment were not exercised.

Sandboxed child-process tests can misleadingly report zero nodejs tests. The
reported full suite ran outside the sandbox and executed all 79 differential tests.

## Existing semantics to retain in release documentation

- Constraints compare the first word unsigned. Signed and richer comparisons
  must be expressed through Operators.
- `isValid`, `orElse` and unqualified revert probes also catch subcall out-of-gas;
  they cannot distinguish a business-logic failure from gas starvation.
- Descriptor claims are not proof of the target's ABI. Selection does not
  recursively validate unrelated components, and raw read segments require
  correct ABI layout from the caller.
- A zero TARGET skips the constructed call. This follows the
  [ERC-8211 predicate-entry convention](https://www.erc8211.com/), rather than
  asserting that a call to the zero address succeeded.
- The contracts use Cancun compilation settings; blob opcodes need appropriate
  chain support. The Ignition zero salt is not the canonical Arachnid-proxy path.

No additional high-severity exploit was established in this review. Contract and
website changes are committed locally in Assertions. Neither the
contracts nor the website have been deployed; only the EVMcrispr compatibility
branch has been published.
