import { helpers as acl } from "@evmcrispr/module-acl/registry";
import { helpers as aragonosx } from "@evmcrispr/module-aragonosx/registry";
import { helpers as contracts } from "@evmcrispr/module-contracts/registry";
import { helpers as governor } from "@evmcrispr/module-governor/registry";
import { helpers as lang } from "@evmcrispr/module-lang/registry";
import { helpers as math } from "@evmcrispr/module-math/registry";
import { helpers as receipts } from "@evmcrispr/module-receipts/registry";
import { helpers as safe } from "@evmcrispr/module-safe/registry";
import { helpers as sim } from "@evmcrispr/module-sim/registry";
import { helpers as std } from "@evmcrispr/module-std/registry";
import { helpers as token } from "@evmcrispr/module-token/registry";
import { helpers as vault } from "@evmcrispr/module-vault/registry";
import type { HelperImportMap } from "@evmcrispr/sdk";

/**
 * Which module owns each on-chain (`!`) helper face, derived from the
 * generated registries of every module the builder's tag registers
 * (evml.ts). The script surgery derives `load` lines from this map, so a
 * helper the codegen or the chat emits can never miss its module.
 */

/** Every registered module's helper registry, keyed by module name. */
export const REGISTRIES: Record<string, HelperImportMap> = {
  std,
  contracts,
  sim,
  lang,
  receipts,
  math,
  token,
  vault,
  acl,
  safe,
  governor,
  aragonosx,
};

function buildOwners(): Record<string, string> {
  const owners: Record<string, string> = {};
  const clashes: string[] = [];
  for (const [module, registry] of Object.entries(REGISTRIES)) {
    for (const [name, entry] of Object.entries(registry)) {
      if (!entry.onchain || !name.endsWith("!")) continue;
      if (name in owners) clashes.push(`@${name} (${owners[name]}, ${module})`);
      else owners[name] = module;
    }
  }
  // An unprefixed `!` face resolves against any loaded module declaring
  // it (the analyzer takes the first), so two owners would make the load
  // derivation ambiguous.
  if (clashes.length && import.meta.env.DEV)
    throw new Error(
      `[assertion-builder] on-chain helper faces owned by two modules: ${clashes.join(", ")}`,
    );
  return owners;
}

/** `"name!"` (no `@`) to the module that registers it. */
export const HELPER_OWNER: Record<string, string> = buildOwners();

/** Modules whose on-chain faces need a `load` line (std is implicit). */
export const HELPER_MODULES: string[] = [
  ...new Set(Object.values(HELPER_OWNER)),
].filter((module) => module !== "std");

/**
 * The module a helper reference resolves to: an explicit `@mod:` prefix
 * wins; an unprefixed name is looked up only for `!` faces (a plain
 * unprefixed helper is std's or an import, which the analyzer decides).
 * Undefined when nothing owns the name.
 */
export function ownerOf(ref: {
  module?: string;
  name: string;
}): string | undefined {
  if (ref.module) return ref.module;
  if (!ref.name.endsWith("!")) return undefined;
  return HELPER_OWNER[ref.name];
}
