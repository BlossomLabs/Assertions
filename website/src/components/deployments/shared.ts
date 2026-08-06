import type { Chain, PublicClient } from "viem";
import { createPublicClient, http } from "viem";
import { polygon } from "viem/chains";

import {
  ASSERTIONS_ADDRESS,
  ASSERTIONS_CREATION_BYTECODE,
  ASSERTIONS_SALT,
} from "../../lib/assertions-deployment";
import {
  COMBINATORS_ADDRESS,
  COMBINATORS_CREATION_BYTECODE,
  COMBINATORS_SALT,
} from "../../lib/combinators-deployment";

/** The two contracts that make up a canonical deployment on a chain. */
export interface DeployableContract {
  key: "core" | "combinators";
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
    gasLabel: "~4.5M",
  },
  {
    key: "combinators",
    name: "Combinators",
    address: COMBINATORS_ADDRESS,
    salt: COMBINATORS_SALT,
    bytecode: COMBINATORS_CREATION_BYTECODE,
    gasLabel: "~1.4M",
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
