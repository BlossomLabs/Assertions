import { createEvml } from "@evmcrispr/core";

/**
 * The builder's EVML tag: an isolated registry (not the global singleton)
 * with exactly the modules the Assertion Builder uses. `std` is always
 * available; the rest lazy-load on first `load <module>`.
 */
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
