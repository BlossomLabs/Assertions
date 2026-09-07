import { isAddress } from "viem";
import * as viemChains from "viem/chains";

import type { ExecutionContext } from "./context";
import { hoistLoads } from "./script-ops";
import { ensVarName } from "./useContractFunctions";

/** viem's camelCase export name per chain id, the names `switch` accepts
 *  (e.g. `mainnet`, `gnosis`, `baseSepolia`). */
const CHAIN_EXPORT_NAMES: Record<number, string> = (() => {
  const byId: Record<number, string> = {};
  for (const [key, value] of Object.entries(viemChains)) {
    const chain = value as { id?: unknown; name?: unknown };
    if (
      typeof chain?.id === "number" &&
      typeof chain?.name === "string" &&
      !(chain.id in byId)
    )
      byId[chain.id] = key;
  }
  return byId;
})();

/** `switch <chain>` opener for non-mainnet scripts, so the script itself
 *  declares the chain it targets instead of relying on runner config. */
function switchLine(chainId: number): string | null {
  if (chainId === 1) return null;
  return `switch ${CHAIN_EXPORT_NAMES[chainId] ?? chainId}`;
}

/** Context address as a script reference: plain addresses pass through, an
 *  ENS name becomes a `$variable` backed by a `set $var @ens(name)` line
 *  (the same convention the composer uses for ENS call arguments). */
function addressRef(input: string | undefined): {
  ref: string;
  sets: string[];
} {
  const value = (input ?? "").trim();
  if (!value || isAddress(value)) return { ref: value, sets: [] };
  const varName = ensVarName(value);
  return { ref: varName, sets: [`set ${varName} @ens(${value})`] };
}

function indent(text: string, depth = 1): string {
  const pad = "  ".repeat(depth);
  return text
    .split("\n")
    .map((line) => (line.trim() ? pad + line : line))
    .join("\n");
}

/**
 * Wrap the composed action block into its final executable script for the
 * selected execution context:
 *
 * - `eoa`       -> `batch ( ... )`: one atomic transaction from the wallet
 *                  (EIP-5792 `wallet_sendCalls`, which uses the wallet's
 *                  EIP-7702 delegation when available).
 * - `safe`      -> `safe:propose <safe> ( ... )`: queued on the Safe
 *                  Transaction Service for the other owners.
 * - `governor`  -> `governor:propose <governor> "<description>" ( ... )`.
 * - `aragonosx` -> `aragonosx:connect <dao> ( aragonosx:propose <plugin> ... )`.
 */
export function buildFinalScript(
  block: string,
  context: ExecutionContext,
  chainId = 1,
): string {
  const { loads, body } = hoistLoads(block);
  const target = addressRef(context.address);
  const chainSwitch = switchLine(chainId);
  const prelude = (extra: string[]) =>
    [
      ...(chainSwitch ? [chainSwitch] : []),
      ...new Set([...extra, ...loads]),
      ...target.sets,
    ].join("\n");

  switch (context.kind) {
    case "eoa":
      return [prelude([]), `batch (\n${indent(body)}\n)`]
        .filter(Boolean)
        .join("\n\n");
    case "safe":
      return [
        prelude(["load safe"]),
        `safe:propose ${target.ref} (\n${indent(body)}\n)`,
      ].join("\n\n");
    case "governor": {
      const description = (
        context.description || "Proposal built with assertions.eth"
      ).replace(/"/g, "'");
      return [
        prelude(["load governor"]),
        `governor:propose ${target.ref} "${description}" (\n${indent(body)}\n)`,
      ].join("\n\n");
    }
    case "aragonosx": {
      const metadata = context.description?.replace(/"/g, "'");
      const opts = metadata ? ` --metadata "${metadata}"` : "";
      return [
        prelude(["load aragonosx"]),
        `aragonosx:connect ${target.ref} (\n` +
          `  aragonosx:propose ${context.plugin}${opts} (\n${indent(body, 2)}\n  )\n)`,
      ].join("\n\n");
    }
  }
}
