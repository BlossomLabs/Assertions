// EIP-170 guard for every production artifact. The computation contracts are
// the ones that grow (Collections sits a few hundred bytes under the limit),
// and a size regression must fail here rather than at deployment time.
//
// The second case pins the artifact SET: a renamed or added production
// contract must be listed consciously, and a stale artifact left behind by a
// removed source fails loudly instead of being sized silently.

import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { artifacts } from "hardhat";

const EIP170_LIMIT = 24_576;
const WARN_HEADROOM = 1_024;

const PRODUCTION_CONTRACTS = [
  "AbiCodec",
  "Assertions",
  "Collections",
  "Expressions",
  "Operations",
];

interface Sized {
  contract: string;
  bytes: number;
  headroom: number;
}

// Every artifact compiled from `contracts/` except the test sources, keeping
// only the ones with runtime code (interfaces, structs-only files and
// internal-only libraries produce none).
async function productionArtifacts(): Promise<Sized[]> {
  const names = await artifacts.getAllFullyQualifiedNames();
  const sized: Sized[] = [];
  for (const fqn of [...names].sort()) {
    if (!fqn.startsWith("contracts/") || fqn.startsWith("contracts/tests/")) continue;
    const artifact = await artifacts.readArtifact(fqn);
    const deployed: string = artifact.deployedBytecode;
    if (!deployed || deployed === "0x") continue;
    const bytes = (deployed.length - 2) / 2;
    sized.push({ contract: artifact.contractName, bytes, headroom: EIP170_LIMIT - bytes });
  }
  return sized;
}

describe("bytecode size", () => {
  it("keeps every production artifact within EIP-170", async () => {
    const sized = await productionArtifacts();
    assert.ok(sized.length > 0, "no production artifacts found; run pnpm compile");
    console.table(sized);
    for (const { contract, bytes, headroom } of sized) {
      if (headroom < WARN_HEADROOM) {
        console.warn(`${contract}: ${headroom} bytes of EIP-170 headroom left (${bytes} runtime bytes)`);
      }
      assert.ok(bytes <= EIP170_LIMIT, `${contract}: ${bytes} runtime bytes exceeds EIP-170 (${EIP170_LIMIT})`);
    }
  });

  it("sizes exactly the known production contracts", async () => {
    const sized = await productionArtifacts();
    assert.deepEqual(
      sized.map((s) => s.contract).sort(),
      [...PRODUCTION_CONTRACTS].sort(),
      "the set of production artifacts with runtime code changed; update PRODUCTION_CONTRACTS deliberately",
    );
  });
});
