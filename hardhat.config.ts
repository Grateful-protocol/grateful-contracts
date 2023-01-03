import * as dotenv from "dotenv";
import fs from "fs";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@synthetixio/hardhat-router";
import "@synthetixio/hardhat-storage";
import "hardhat-cannon";
import "hardhat-preprocessor";

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
      gas: 12000000, // Prevent gas estimation for better error results in tests
    },
    hardhat: {
      forking: {
        url: process.env.RPC_MUMBAI as string,
        blockNumber: 27016098,
      },
      gas: 12000000, // Prevent gas estimation for better error results in tests
    },
  },

  defaultNetwork: "cannon",
};

export default config;
