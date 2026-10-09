# Assertions 2.0 release review

The reviewed release candidate uses the final sources in this checkout. All six production source files retain the executable tokens of the rebased HEAD; comment corrections change compiler metadata and CREATE2 predictions. No executable contract behavior was changed during this review.

| Contract | CREATE2 address | Runtime bytes | EIP-170 headroom |
|---|---|---|---|
| Assertions | `0xa55e47A8F0701e231a9c0ac916776074e5c561d5` | 20,049 | 4,527 |
| Operations | `0x09e4A7EA7868aEC605bE16FE64Bd5b56A8B9601A` | 21,346 | 3,230 |
| Collections | `0xc011eC7071DA62522F0DCD03606e5A299a8e6323` | 24,560 | 16 |
| Expressions | `0xE5594e5577165b73F3f3CFcc4F3983345c5F0F48` | 17,776 | 6,800 |

All four contracts are stateless and read-only, with no immutables or linked libraries. Build: solc 0.8.36, optimizer 200 runs, Cancun target. Solidity formatting passed before the canonical build and mining. The generated verification inputs include the exact final sources/settings. Addresses identify deployment candidates; no public-chain deployment was performed.

Validation: 602 Solidity and 102 Node/differential tests passed under Hardhat; 602 Solidity tests passed under Forge; 17 targeted decoder/resource tests passed with 512 fuzz runs; all 172 bounded Halmos properties passed; 493 SDK unit tests passed in each SDK checkout without the unused fork preload; website/SDK/fixture integration passed both directly and through preparation of the published pin. Commands, source hashes, results, mining outputs and artifact measurements are in [the release record](assertions-2.0-release-checks.json).

The review corrected universal bare-revert comments for Resolve/evaluateEncoded, added exact allocation regressions, and qualified indexOf resource behavior. [The functional claims](claims.md) retain 140 formally verified, 44 partially verified, 136 tested and 3 partially tested claims, with 2 scope limitations and 1 environment assumption. Supplemental Dafny runs retain their original provenance; this release review did not rerun them.

Collections has 16 bytes of EIP-170 headroom. The remaining partial test coverage concerns arbitrary navigation depth, general fixed-point step rounding and sorting complexity/memory use. Real-function exp/log accuracy and external execution/resource assumptions remain scoped explicitly in the ledger.

Modexp pricing comments were checked against [EIP-7883](https://eips.ethereum.org/EIPS/eip-7883) and [EIP-2565](https://eips.ethereum.org/EIPS/eip-2565).

The SDK update is [commit `8b79d31b`](https://github.com/EVMcrispr/evmcrispr/commit/8b79d31b91a45a8b970007a36d899cb3e05dfafe), directly on the latest published `origin/next` (`5fc08004`). It is published on `codex/assertions-2-release` and pinned in `website/package.json`.

The release history excludes separate formal proof campaigns. The independent test-vector oracle is retained under `scripts/`; regenerating its Solidity fixture is byte-identical. Tests and integration passed in a checkout containing no `formal/` folder; see [history cleanup checks](history-cleanup-checks.json).
