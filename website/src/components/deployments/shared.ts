import type { Chain, PublicClient } from "viem";
import { createPublicClient, http } from "viem";
import { polygon } from "viem/chains";

import {
  ASSERTIONS_ADDRESS,
  ASSERTIONS_CREATION_BYTECODE,
} from "../../lib/assertions-deployment";
import { COLLECTIONS_CREATION_BYTECODE } from "../../lib/collections-deployment";
import manifest from "../../lib/deployments.json";
import { EXPRESSIONS_CREATION_BYTECODE } from "../../lib/expressions-deployment";
import { OPERATIONS_CREATION_BYTECODE } from "../../lib/operations-deployment";
import { rpcUrl } from "./rpc";

/** "1245095" -> "~1.2M", for UI copy. */
export function formatDeployGas(gas: number): string {
  return `~${(gas / 1e6).toFixed(1)}M`;
}

export type ContractKey = "core" | "operators" | "collections" | "expressions";

/** The contracts that make up a canonical deployment on a chain. */
export interface DeployableContract {
  key: ContractKey;
  name: string;
  version: string;
  /** False for an artifact candidate the SDK does not compile against yet. */
  released: boolean;
  address: `0x${string}`;
  salt: `0x${string}`;
  bytecode: `0x${string}`;
  /** Rough deployment gas, for UI copy. */
  gasLabel: string;
}

// The manifest carries no bytecode (the generated deployment modules keep
// it); this map is the one place the two are joined, keyed like the manifest.
const CREATION_BYTECODE: Record<ContractKey, `0x${string}`> = {
  core: ASSERTIONS_CREATION_BYTECODE,
  operators: OPERATIONS_CREATION_BYTECODE,
  collections: COLLECTIONS_CREATION_BYTECODE,
  expressions: EXPRESSIONS_CREATION_BYTECODE,
};

/**
 * Every exported contract in manifest order, released or not. Derived from
 * src/lib/deployments.json, which `pnpm sync:artifact` writes; nothing here
 * is typed by hand.
 */
export const DEPLOYED_CONTRACTS: DeployableContract[] = manifest.contracts.map(
  (contract) => {
    const key = contract.key as ContractKey;
    return {
      key,
      name: contract.name,
      version: contract.version,
      released: contract.released,
      address: contract.address as `0x${string}`,
      salt: contract.salt as `0x${string}`,
      bytecode: CREATION_BYTECODE[key],
      gasLabel: formatDeployGas(contract.deployGas),
    };
  },
);

/** The contracts the SDK compiles against: what the builder needs on a chain. */
export const RELEASED_CONTRACTS: DeployableContract[] =
  DEPLOYED_CONTRACTS.filter((contract) => contract.released);

// Chains whose viem default RPC is dead or unreliable.
// polygon-rpc.com (viem's default) rejects requests with "tenant disabled".
const RPC_OVERRIDES: Record<number, string> = {
  [polygon.id]: "https://polygon-bor-rpc.publicnode.com",
};

export function makePublicClient(chain: Chain): PublicClient {
  return createPublicClient({
    chain,
    transport: http(rpcUrl(chain.id) ?? RPC_OVERRIDES[chain.id]),
  });
}

export function shortAddress(address: string): string {
  return `${address.slice(0, 6)}…${address.slice(-4)}`;
}

export function explorerAddressUrl(
  chain: Chain,
  address: string = ASSERTIONS_ADDRESS,
): string | null {
  const base = chain.blockExplorers?.default?.url;
  return base ? `${base.replace(/\/$/, "")}/address/${address}` : null;
}

export function explorerTxUrl(chain: Chain, hash: string): string | null {
  const base = chain.blockExplorers?.default?.url;
  return base ? `${base.replace(/\/$/, "")}/tx/${hash}` : null;
}
