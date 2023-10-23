import * as dotenv from "dotenv";
import fs from "fs";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@synthetixio/router/utils/cannon";
import "@synthetixio/hardhat-storage";
import "hardhat-cannon";
import "hardhat-preprocessor";
import "hardhat-abi-exporter";
import "./tasks/deposit";
import "./tasks/subscribe";
import "./tasks/unsubscribe";
import "./tasks/getBalance";
import "./tasks/createProfile";
import "./tasks/transferProfile";

// Router generation cannon plugin
import { registerAction } from "@usecannon/builder";
registerAction(require("cannon-plugin-router"));

dotenv.config();

const alchemyKey = process.env.ALCHEMY_API_KEY as string;

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean) // remove empty lines
    .map((line) => line.trim().split("="));
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  // This fully resolves paths for imports in the ./lib directory for Hardhat
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          for (const [from, to] of getRemappings()) {
            if (line.includes(from)) {
              line = line.replace(from, to);
              break;
            }
          }
        }
        return line;
      },
      settings: { comment: true },
      files: "./contracts/vaults/*.sol",
    }),
  },

  networks: {
    local: {
      url: "http://localhost:8545",
      chainId: 31337,
      accounts: [process.env.LOCAL_PRIVATE_KEY as string],
    },
    hardhat: {
      forking: {
        url: process.env.RPC_MUMBAI as string,
        blockNumber: 32860318,
      },
    },
    mumbai: {
      url: process.env.RPC_MUMBAI as string,
      chainId: 80001,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY as string],
    },
    polygon: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/${alchemyKey}`,
      chainId: 137,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY as string],
    },
    optimismGoerli: {
      url: `https://opt-goerli.g.alchemy.com/v2/${alchemyKey}`,
      chainId: 420,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY as string],
    },
    optimism: {
      url: `https://opt-mainnet.g.alchemy.com/v2/${alchemyKey}`,
      chainId: 10,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY as string],
    },
  },

  gasReporter: {
    enabled: true,
    currency: "USD",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY as string,
    token: "ETH",
    gasPrice: 1,
  },

  cannon: {
    publicSourceCode: true,
  },

  etherscan: {
    apiKey: {
      polygon: process.env.POLYGON_ETHERSCAN_API_KEY as string,
      polygonMumbai: process.env.POLYGON_ETHERSCAN_API_KEY as string,
      optimisticGoerli: process.env.OPTIMISTIC_ETHERSCAN_API_KEY as string,
      optimisticEthereum: process.env.OPTIMISTIC_ETHERSCAN_API_KEY as string,
    },
  },

  defaultNetwork: "cannon",
};

export default config;
