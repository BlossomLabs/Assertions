import { getAddress, isAddress } from "viem";
import * as viemChains from "viem/chains";

import { CONTEXT_NAMES, type ExecutionContext } from "./context";
import { addressVariables, hoistLoads, setVariables } from "./script-ops";
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

/**
 * The context's account as the wrapper refers to it: always a variable.
 * An address is the variable the block already has for it, whatever its
 * name (the builder names it `$safe`, `$governor` or `$dao`; the user may
 * have renamed it), or a variable of that name set above the wrapper, with
 * a number when the block uses the name for something else. An ENS name
 * becomes a `$variable` backed by a `set $var @ens(name)` line (the same
 * convention the composer uses for ENS call arguments). `reserved` is the
 * name the block must not hoist a variable of its own under.
 */
function addressRef(
  block: string,
  context: ExecutionContext,
): { ref: string; sets: string[]; reserved: string[] } {
  const value = (context.address ?? "").trim();
  if (context.kind === "eoa" || !value) return { ref: "", sets: [], reserved: [] };
  if (!isAddress(value)) {
    const varName = ensVarName(value);
    return {
      ref: varName,
      sets: [`set ${varName} @ens(${value})`],
      reserved: [varName.replace(/^\$/, "")],
    };
  }
  const existing = [...addressVariables(block)].find(
    ([, address]) => address.toLowerCase() === value.toLowerCase(),
  );
  if (existing) return { ref: `$${existing[0]}`, sets: [], reserved: [] };
  const taken = setVariables(block);
  const base = CONTEXT_NAMES[context.kind];
  let name: string = base;
  for (let n = 2; taken.has(name); n++) name = `${base}${n}`;
  return { ref: `$${name}`, sets: [`set $${name} ${getAddress(value)}`], reserved: [] };
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
 * - `safe`      -> `safe:propose $safe ( ... )`: queued on the Safe
 *                  Transaction Service for the other owners.
 * - `governor`  -> `governor:propose $proposalId $governor "<description>" ( ... )`
 *                  (`$proposalId` receives the proposal's id).
 * - `aragonosx` -> `aragonosx:connect $dao ( aragonosx:propose <plugin> ... )`.
 *
 * The account is a variable set above the wrapper, like every address the
 * script names (see `addressRef`).
 */
export function buildFinalScript(
  block: string,
  context: ExecutionContext,
  chainId = 1,
): string {
  // A wallet's address only picks who simulates; the wrapper never names
  // it (the block may: `$wallet`, `$executor`).
  const target = addressRef(block, context);
  const { loads, sets, body } = hoistLoads(block, new Set(target.reserved));
  const chainSwitch = switchLine(chainId);
  const prelude = (extra: string[]) =>
    [
      ...(chainSwitch ? [chainSwitch] : []),
      ...new Set([...extra, ...loads]),
      ...target.sets,
      ...sets,
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
      // The command's first argument may be a variable to bind the
      // proposal's id to, so a Governor given as a variable would be
      // taken for that one: the id is bound first, to a name of its own.
      const taken = new Set([...setVariables(block), target.ref.replace(/^\$/, "")]);
      let id = "proposalId";
      for (let n = 2; taken.has(id); n++) id = `proposalId${n}`;
      return [
        prelude(["load governor"]),
        `governor:propose $${id} ${target.ref} "${description}" (\n${indent(body)}\n)`,
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
