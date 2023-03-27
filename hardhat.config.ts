import * as dotenv from "dotenv";
import "ethers-maths";
import "hardhat-deal";
import "hardhat-gas-reporter";
import "hardhat-tracer";
import { HardhatUserConfig } from "hardhat/config";

import "@nomicfoundation/hardhat-chai-matchers";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-vyper";
import "@typechain/hardhat";

dotenv.config();

export const rpcUrl = process.env.RPC_HTTP_URL || process.env.RPC_URL || "https://rpc.ankr.com/eth";
if (!rpcUrl) throw Error(`no RPC url provided`);

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1,
      forking: {
        url: rpcUrl,
        blockNumber: 16_600_000,
      },
      gasPrice: 0,
      initialBaseFeePerGas: 0,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          viaIR: true,
        },
      },
      {
        version: "0.5.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  vyper: {
    compilers: [
      { version: "0.2.15" },
      { version: "0.2.16" },
      { version: "0.3.0" },
      { version: "0.3.1" },
      { version: "0.3.3" },
    ],
  },
  gasReporter: {
    currency: "EUR",
  },
  mocha: {
    timeout: 300000,
  },
  typechain: {
    outDir: "types/",
  },
  tracer: {
    defaultVerbosity: 1,
    gasCost: true,
  },
};

export default config;
