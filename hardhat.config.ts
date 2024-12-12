import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000
      }
    }
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat:{

    },
    localhost: {
      url: "http://127.0.0.1:8545"
    },
  },
  paths: {
    sources: "./contracts/",
    tests: "./test/",
    cache: "./cache/",
    artifacts: "./artifacts/"
  },
  mocha: {
    timeout: 40000,
    //parallel: true
  }
};

export default config;
