import { createEvml, type EvmlTag, type ModuleLoader } from "@evmcrispr/core";

/**
 * The builder's EVML tag: an isolated registry (not the global singleton)
 * with exactly the modules the Assertion Builder uses. `std` is always
 * available; the rest lazy-load on first `load <module>`. The chain,
 * executor and transports are applied by the EvmcrisprProvider around the
 * builder; components read the configured tag with `useEvmlTag()`.
 */

/** Modules resolved from the vendored checkout only (no npm release): the
 *  checkout carries its own @evmcrispr/sdk copy, so tsc sees a nominally
 *  different Module class there. At runtime Vite aliases every copy to the
 *  same checkout sources, so the cast is type-level noise only. */
const vendored = (load: () => Promise<unknown>) => load as ModuleLoader;
export const evml = createEvml().use(
  {
    name: "contracts",
    load: vendored(() => import("@evmcrispr/module-contracts")),
    description: "Contract code, storage and ABI helpers",
  },
  {
    name: "sim",
    load: () => import("@evmcrispr/module-sim"),
    description: "Fork simulation",
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
      "Block/tx context reads (block.timestamp!, tx.from!, tx.gasPrice!, ...)",
  },
  {
    name: "math",
    load: vendored(() => import("@evmcrispr/module-math")),
    description: "Plain math (min, max, absDiff, sqrt) with on-chain ! faces",
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

/**
 * A tag that forwards every call to whatever `current()` returns at call
 * time. The chat agent's tool set is built once and must stay stable, yet
 * the configured tag changes with the chain and the executor; the tools
 * hold this proxy and always see the latest one.
 */
export function createLiveTag(current: () => EvmlTag): EvmlTag {
  const call = (...args: unknown[]) =>
    (current() as unknown as (...a: unknown[]) => unknown)(...args);
  return new Proxy(call as unknown as EvmlTag, {
    apply: (_target, _thisArg, args) => call(...args),
    get: (_target, prop) => {
      const tag = current();
      const value = (tag as unknown as Record<PropertyKey, unknown>)[prop];
      return typeof value === "function" ? value.bind(tag) : value;
    },
  });
}
