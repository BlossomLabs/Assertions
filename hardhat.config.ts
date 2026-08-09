import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable, defineConfig } from "hardhat/config";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  ignition: {
    // NOTE: Ignition's create2 strategy deploys through the CreateX factory,
    // which guards (re-hashes) the salt, so it does NOT reproduce the canonical
    // vanity address below. The canonical deployment goes through the Arachnid
    // deterministic-deployment proxy (0x4e59b44847b379578588920cA78FbF26c0B4956C);
    // see website/scripts/export-deploy-artifact.mjs and the README.
    strategyConfig: {
      create2: {
        // Assertions core v2.0 salt, mined for the Arachnid-proxy vanity address
        // 0xa55E47F37088b6D0212BdfD56b175ec08744DB19
        // (see website/scripts/mine-salt.mjs).
        // Combinators v2.0 uses salt
        // 0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f6031de88b
        // for 0xA55Ec0935FB5aaf95CAC1F48DD822005d91b64b9 (Ignition only supports
        // one global salt; the canonical deploy path is the website / Arachnid
        // proxy anyway — see website/scripts/export-deploy-artifact.mjs).
        // (v1.1 core salt 0x0b11b1be...012c7cd0 produced 0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0;
        //  v1.0 core salt 0xea760d18... produced 0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F)
        salt: "0x0b11b1becbd8e5f2ff0c192633404d5a6774818e9ba8b5c2cfdce9f601469a3b",
      },
    },
  },
  solidity: {
    // The two profiles are intentionally identical: the CREATE2 vanity address
    // is derived from the exact bytecode, so test builds and production builds
    // must produce the same output. Do not let them drift.
    profiles: {
      default: {
        version: "0.8.28",
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
        version: "0.8.28",
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
