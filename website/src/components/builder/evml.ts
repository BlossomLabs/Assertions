import { createEvml, type ModuleLoader } from "@evmcrispr/core";

/**
 * The builder's EVML tag: an isolated registry (not the global singleton)
 * with exactly the modules the Assertion Builder uses. `std` is always
 * available; the rest lazy-load on first `load <module>`.
 */

/** Modules resolved from the vendored checkout only (no npm release): the
 *  checkout carries its own @evmcrispr/sdk copy, so tsc sees a nominally
 *  different Module class there. At runtime Vite aliases every copy to the
 *  same checkout sources, so the cast is type-level noise only. */
const vendored = (load: () => Promise<unknown>) => load as ModuleLoader;
export const evml = createEvml().use(
  {
    name: "sim",
    load: () => import("@evmcrispr/module-sim"),
    description: "Fork simulation",
  },
  {
    name: "assertions",
    load: () => import("@evmcrispr/module-assertions"),
    description: "On-chain assertions via assertions.eth",
  },
  {
    name: "lang",
    load: vendored(() => import("@evmcrispr/module-lang")),
    description:
      "Array/string helpers (str.split!, bytes.len!, len!, map!, ...)",
  },
  {
    name: "receipts",
    load: vendored(() => import("@evmcrispr/module-receipts")),
    description:
      "Block/tx context reads (block.timestamp!, tx.from!, tx.gasprice!, ...)",
  },
  {
    name: "math",
    load: vendored(() => import("@evmcrispr/module-math")),
    description: "Plain math (min, max, absdiff, sqrt) with on-chain ! faces",
  },
  {
    name: "token",
    load: vendored(() => import("@evmcrispr/module-token")),
    description: "ERC-20 helpers (amounts, allowances, live reads)",
  },
  {
    name: "vault",
    load: vendored(() => import("@evmcrispr/module-vault")),
    description: "ERC-4626 vault reads",
  },
  {
    name: "acl",
    load: vendored(() => import("@evmcrispr/module-acl")),
    description: "Access-control reads (roles, owners)",
  },
  {
    name: "safe",
    load: () => import("@evmcrispr/module-safe"),
    description: "Safe transactions and proposals",
  },
  {
    name: "governor",
    load: () => import("@evmcrispr/module-governor"),
    description: "OpenZeppelin Governor proposals",
  },
  {
    name: "aragonosx",
    load: () => import("@evmcrispr/module-aragonosx"),
    description: "Aragon OSx DAO proposals",
  },
);
