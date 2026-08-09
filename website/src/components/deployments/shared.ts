import type { Chain, PublicClient } from "viem";
import { createPublicClient, http } from "viem";
import { polygon } from "viem/chains";

import {
  ASSERTIONS_ADDRESS,
  ASSERTIONS_CREATION_BYTECODE,
  ASSERTIONS_DEPLOY_GAS,
  ASSERTIONS_SALT,
} from "../../lib/assertions-deployment";
import {
  OPERATORS_ADDRESS,
  OPERATORS_CREATION_BYTECODE,
  OPERATORS_DEPLOY_GAS,
  OPERATORS_SALT,
} from "../../lib/operators-deployment";

/** "1245095" -> "~1.2M", for UI copy. */
export function formatDeployGas(gas: number): string {
  return `~${(gas / 1e6).toFixed(1)}M`;
}

/** The two contracts that make up a canonical deployment on a chain. */
export interface DeployableContract {
  key: "core" | "operators";
  name: string;
  address: `0x${string}`;
  salt: `0x${string}`;
  bytecode: `0x${string}`;
  /** Rough deployment gas, for UI copy. */
  gasLabel: string;
}

export const DEPLOYED_CONTRACTS: DeployableContract[] = [
  {
    key: "core",
    name: "Assertions",
    address: ASSERTIONS_ADDRESS,
    salt: ASSERTIONS_SALT,
    bytecode: ASSERTIONS_CREATION_BYTECODE,
    gasLabel: formatDeployGas(ASSERTIONS_DEPLOY_GAS),
  },
  {
    key: "operators",
    name: "Operators",
    address: OPERATORS_ADDRESS,
    salt: OPERATORS_SALT,
    bytecode: OPERATORS_CREATION_BYTECODE,
    gasLabel: formatDeployGas(OPERATORS_DEPLOY_GAS),
  },
];

// Chains whose viem default RPC is dead or unreliable.
// polygon-rpc.com (viem's default) rejects requests with "tenant disabled".
const RPC_OVERRIDES: Record<number, string> = {
  [polygon.id]: "https://polygon-bor-rpc.publicnode.com",
};

export function makePublicClient(chain: Chain): PublicClient {
  return createPublicClient({
    chain,
    transport: http(RPC_OVERRIDES[chain.id]),
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
