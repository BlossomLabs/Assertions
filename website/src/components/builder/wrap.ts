import { isAddress } from "viem";

import type { ExecutionContext } from "./context";
import { ensVarName } from "./useContractFunctions";

/** `load` must sit at the top level, so pull the block's load lines (e.g.
 *  the AI-inserted `load assertions`) out and above the wrapper. */
function hoistLoads(block: string): { loads: string[]; body: string } {
  const loads = new Set<string>();
  const body: string[] = [];
  for (const line of block.split("\n")) {
    const match = line.trim().match(/^load\s+(.+)$/);
    if (match) loads.add(`load ${match[1]}`);
    else body.push(line);
  }
  return { loads: [...loads], body: body.join("\n").trim() };
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
 * - `eoa`       -> `batch ( ... )` — one atomic transaction from the wallet
 *                  (EIP-5792 `wallet_sendCalls`, which uses the wallet's
 *                  EIP-7702 delegation when available).
 * - `safe`      -> `safe:propose <safe> ( ... )` — queued on the Safe
 *                  Transaction Service for the other owners.
 * - `governor`  -> `governor:propose <governor> "<description>" ( ... )`.
 * - `aragonosx` -> `aragonosx:connect <dao> ( aragonosx:propose <plugin> ... )`.
 */
export function buildFinalScript(
  block: string,
  context: ExecutionContext,
): string {
  const { loads, body } = hoistLoads(block);
  const target = addressRef(context.address);
  const prelude = (extra: string[]) =>
    [...new Set([...extra, ...loads]), ...target.sets].join("\n");

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
