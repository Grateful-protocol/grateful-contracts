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
import "./tasks/getBalance";

dotenv.config();

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
        blockNumber: 27016098,
      },
    },
    mumbai: {
      url: process.env.RPC_MUMBAI as string,
      chainId: 80001,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY as string],
    },
  },

  gasReporter: {
    enabled: true,
  },

  cannon: {
    publicSourceCode: true,
  },

  etherscan: {
    apiKey: {
      polygon: process.env.POLYGON_ETHERSCAN_API_KEY,
      polygonMumbai: process.env.POLYGON_ETHERSCAN_API_KEY,
    },
  },

  defaultNetwork: "cannon",
};

export default config;
