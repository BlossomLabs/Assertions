import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable, defineConfig } from "hardhat/config";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  ignition: {
    // NOTE: Ignition's create2 strategy deploys through the CreateX factory,
    // which guards (re-hashes) the salt, so it does NOT reproduce the canonical
    // address below. The canonical deployment goes through the Arachnid
    // deterministic-deployment proxy (0x4e59b44847b379578588920cA78FbF26c0B4956C);
    // see website/scripts/export-deploy-artifact.mjs and the README.
    strategyConfig: {
      create2: {
        // This Ignition salt is NOT the canonical path (see the note above),
        // and this module exists for local testing only. The canonical
        // per-contract CREATE2 salts are random 32-byte values mined with
        // `cast create2` and live, with their expected addresses, in
        // website/scripts/export-deploy-artifact.mjs. That script is the single
        // source: it refuses to export when a compiled artifact no longer
        // reproduces its expected address, so do not mirror addresses here.
        salt: "0x0000000000000000000000000000000000000000000000000000000000000000",
      },
    },
  },
  solidity: {
    // The two profiles are intentionally identical: the CREATE2 address
    // is derived from the exact bytecode, so test builds and production builds
    // must produce the same output. Do not let them drift.
    profiles: {
      default: {
        version: "0.8.36",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          // Pinned explicitly so a future solc default bump can't change the
          // bytecode (and therefore the CREATE2 address). Cancun bytecode uses
          // PUSH0: the contract cannot deploy on chains without Shanghai support.
          evmVersion: "cancun",
        },
      },
      production: {
        version: "0.8.36",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          evmVersion: "cancun",
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
    },
    mainnet: {
      type: "http",
      chainType: "l1",
      url: configVariable("MAINNET_RPC_URL"),
      // accounts: [configVariable("MAINNET_PRIVATE_KEY")],
    },
  },
  verify: {
    etherscan: {
      apiKey: configVariable("ETHERSCAN_API_KEY"),
    },
  },
});
