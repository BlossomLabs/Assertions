import { isAddress } from "viem";
import type { Address } from "viem";

/** Who ultimately executes the batch — decides simulation `--from` and the
 *  wrapper the final script gets. */
export type ContextKind = "eoa" | "safe" | "governor" | "aragonosx";

export interface ExecutionContext {
  kind: ContextKind;
  /** Safe address / Governor address / DAO address. Unused for `eoa`. */
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
 *  connected wallet for a direct batch. */
export function executorAddress(
  context: ExecutionContext,
  connected: Address | undefined,
): Address | undefined {
  if (context.kind === "eoa") return connected;
  return context.address && isAddress(context.address)
    ? context.address
    : undefined;
}

export function contextReady(
  context: ExecutionContext,
  connected: Address | undefined,
): boolean {
  if (context.kind === "eoa") return !!connected;
  const hasAddress = !!context.address && isAddress(context.address);
  if (context.kind === "aragonosx") return hasAddress && !!context.plugin;
  return hasAddress;
}
