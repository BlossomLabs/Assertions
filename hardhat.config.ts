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
        // This Ignition salt is NOT the canonical path (see the note above).
        // The canonical per-contract vanity salts live in
        // website/scripts/export-deploy-artifact.mjs, mined with
        // `cast create2` as random 32-byte salts (the old shared-base
        // convention is retired):
        // core v2.0 salt 0xd4f532eb...faeae45b → 0xA55E472841ca3D318205036724A94F5abDbf7b18,
        // Operators v1.0 salt 0x92d34082...4b998cf9 → 0x09e4a7e55200600314165ddFB381639dace41bEA.
        // Prior releases (Arachnid-proxy addresses):
        // interim core v2.0 zero salt → 0xA01bC220Efc4c730BBcBC9ee52EE570D33EA956F,
        // interim Operators v1.0 zero salt → 0x8e832Ace3f433943eb605c258bA37AF24a69dC53,
        // core v2.0-rc salt 0x0b11b1be...01469a3b → 0xa55E47F37088b6D0212BdfD56b175ec08744DB19,
        // Combinators v2.0-rc salt 0x0b11b1be...031de88b → 0xA55Ec0935FB5aaf95CAC1F48DD822005d91b64b9,
        // core v1.1 salt 0x0b11b1be...012c7cd0 → 0xA55E47bFD3d20A76e8E63a173387A5e3d4bEe3e0,
        // core v1.0 salt 0xea760d18... → 0xA55e4707A94Ce4Aa647517ed9aD4084e4E5D1f3F.
        salt: "0x0000000000000000000000000000000000000000000000000000000000000000",
      },
    },
  },
  solidity: {
    // The two profiles are intentionally identical: the CREATE2 vanity address
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
