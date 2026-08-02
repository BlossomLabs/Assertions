import type { Address } from "viem";

/** Who ultimately executes the batch — decides simulation `--from` and the
 *  wrapper the final script gets. */
export type ContextKind = "eoa" | "safe" | "governor" | "aragonosx";

export interface ExecutionContext {
  kind: ContextKind;
  /** Safe address / Governor address / DAO address, as typed — a plain
   *  address or an ENS name. Unused for `eoa`. */
  address?: string;
  /** AragonOSx governance plugin (repo name like `token-voting`, or its
   *  address). */
  plugin?: string;
  /** Proposal description (governor) / metadata (aragonosx). */
  description?: string;
}

export const CONTEXT_LABELS: Record<ContextKind, string> = {
  eoa: "This wallet",
  safe: "Safe",
  governor: "Governor",
  aragonosx: "Aragon OSx DAO",
};

/** The address the batch runs as: the contract account for proposals, the
 *  connected wallet for a direct batch. `resolved` is the context address
 *  after ENS resolution (equal to the input when it's a plain address). */
export function executorAddress(
  context: ExecutionContext,
  connected: Address | undefined,
  resolved: Address | null,
): Address | undefined {
  if (context.kind === "eoa") return connected;
  return resolved ?? undefined;
}

export function contextReady(
  context: ExecutionContext,
  connected: Address | undefined,
  resolved: Address | null,
): boolean {
  if (context.kind === "eoa") return !!connected;
  if (context.kind === "aragonosx") return !!resolved && !!context.plugin;
  return !!resolved;
}
