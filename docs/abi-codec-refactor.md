# ABI codec consolidation

The production compiler remains solc 0.8.36, optimizer 200 runs, Cancun, without via-IR. AbiCodec shares descriptor parsing, strict validation and ABI assembly across the core and both periphery contracts. All public encoding is strict; scalar semantics remain the descriptor author's claim. Selective navigation is unchanged.

Word templates and typed callbacks remain separate mechanisms. Template windows can substitute repeated words inside nested InputParams without moving offsets. Typed callbacks rebuild whole argument slots to accommodate dynamic sizes. Callback layouts/constants are prepared once, and word loops share their template plumbing.

## Compiler and placement experiments

Run `SOLC=/path/to/solc-0.8.36 pnpm hardhat run scripts/measure-compiler-size.ts`. The script constructs inheritance probes in the compiler input without adding production sources or changing compiler configuration. Sizes below are deployed runtime bytes; the limit is 24,576.

| via-IR | Runs | Assertions | Operators | Collections | Merged periphery | Core + collections |
|---|---:|---:|---:|---:|---:|---:|
| No | 1 | 12,962 | 23,396 | 13,631 | 30,036 | 23,475 |
| No | 50 | 13,058 | 23,552 | 13,637 | 30,192 | 23,616 |
| No | 200 | 13,116 | 23,737 | 13,825 | 30,630 | 23,832 |
| Yes | 1 | 11,129 | 21,668 | 12,329 | 27,501 | 20,629 |
| Yes | 50 | 11,158 | 21,701 | 12,323 | 27,529 | 20,669 |
| Yes | 200 | 11,168 | 21,781 | 12,323 | 27,608 | 20,679 |

Even the smallest merged periphery does not fit. Production therefore retains the agreed split. Moving typed collections into Assertions does fit, but changes the core's responsibility; that alternative has only been compiled for review, not adopted or runtime-tested. Alternative optimizer configurations are size experiments, not approved production builds.

## Gas comparison

Baseline is the working tree before this refactor (Operators 20,780 runtime bytes, Collections 12,534), including the user's existing string changes. Compiler settings and inputs are identical before/after. All numbers below are transaction estimates including intrinsic/calldata gas unless stated otherwise.

`pnpm hardhat run scripts/measure-collection-gas.ts`, descending signed integers:

| Operation | Values | Before | After |
|---|---:|---:|---:|
| packArray | 1 | 36,010 | 32,836 |
| packArray | 4 | 62,122 | 49,016 |
| packArray | 16 | 167,298 | 113,858 |
| sortValues | 1 | 56,011 | 63,614 |
| sortValues | 4 | 266,942 | 137,322 |
| sortValues | 16 | 1,642,267 | 580,707 |
| foldValues | 1 | 120,099 | 86,701 |
| foldValues | 4 | 304,988 | 149,174 |
| foldValues | 16 | 1,044,970 | 399,384 |

Preparing callback metadata increases setup cost (notably the one-element sort, which invokes no comparator), while avoiding repeated parsing/constant validation improves loops. Static canonical values need only their exact head size checked: they have no offsets or dynamic padding to traverse.

`OPERATORS_BASELINE_RUNTIME=/path/to/pre-refactor-runtime.hex pnpm hardhat run scripts/measure-codec-gas.ts` compares the same calldata against baseline runtime and current code. The baseline file is a plain hex runtime, not an artifact JSON. Strings have 33 bytes; string-array components contain an empty string and a 33-byte string.

| encodeBytes components | Count | Before | After |
|---|---:|---:|---:|
| uint256 | 1 | 37,986 | 43,424 |
| uint256 | 16 | 250,325 | 325,549 |
| string | 1 | 40,060 | 48,773 |
| string | 16 | 283,408 | 411,319 |
| string[] | 1 | 43,216 | 63,139 |
| string[] | 16 | 334,116 | 634,675 |

Encoding now checks complete nested values rather than trusting tails. It also builds a reusable tuple layout in memory. These checks/layout allocations explain the increase; the strict policy is retained. Canonical byte padding is checked in one word, scanning bytes only when needed to locate an error.

`pnpm hardhat test solidity contracts/tests/OperatorsGas.t.sol` measures execution around staticcalls, excluding transaction intrinsic costs. The existing composed B1 template sample increased from 21,053 to 21,307 gas; its direct word-template counterpart increased from 7,016 to 7,270. Sharing template functions adds small internal-call overhead without changing callback behavior.

## Verification

- `pnpm test` outside the restricted sandbox: 410 tests (323 Solidity, 87 Node). The sandbox can misleadingly report success while skipping all Node tests.
- Independent Solidity/viem fixtures cover nested and fixed arrays, static/dynamic tuples, empty arrays, and payloads crossing a word boundary. Both encoding entry points reject malformed nested offsets, lengths, padding, and trailing data. Extreme callback lengths retain contextual errors.
- `bun test packages/sdk/test/unit modules/lang/test/integration/helpers/onchain.test.ts modules/lang/test/integration/helpers/typed-collections.test.ts modules/lang/test/integration/helpers/parity-lambda.test.ts modules/lang/test/integration/helpers/parity-records.test.ts modules/std/test/integration/helpers/parity.test.ts modules/std/test/integration/helpers/parity-abi-dynamic.test.ts`: 444 passing tests against synchronized fixtures and addresses. Existing template lambdas and typed callbacks retain their separate compiler routes.
- Artifact export verifies all three runtime limits and replays CREATE2 deployments. The website checker validates all three artifacts against the local SDK via `EVMCRISPR_SRC=/home/sem/Projects/EVMcrispr node scripts/check-integration.mjs` from `website/`.
- The local website check passes all three artifact comparisons and nine builder compilation cases. It reports existing catalog drift for the in-progress arithmetic helper migration (`num!` versus `calc!` and decimal helpers); this refactor does not change that UI catalog.
- The published website vendor pin is unchanged until a tested SDK commit is published. No public-chain deployments were performed.
