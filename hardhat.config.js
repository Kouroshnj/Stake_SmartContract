require("@nomicfoundation/hardhat-toolbox");
require('hardhat-contract-sizer');
// require('dotenv').config({ path: "./config/config.env" });


// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
// const MNEMONIC = process.env.MNEMONIC
module.exports = {
  defaultNetwork: "localhost",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    hardhat: {
    },
    ganache: {
      url: "http://127.0.0.1:8545",
      chainId: 1337,

      // gas: 5000000, //units of gas you are willing to pay, aka gas limit
      // gasPrice: 50000000000, //gas is typically in units of gwei, but you must enter it as wei here
    },
    // testnet: {
    //   url: "https://data-seed-prebsc-1-s1.binance.org:8545",
    //   chainId: 97,
    //   gasPrice: 20000000000,
    //   accounts: { mnemonic: MNEMONIC },

    // },
    // mainnet: {
    //   url: "https://bsc-dataseed.binance.org/",
    //   chainId: 56,
    //   gasPrice: 20000000000,
    //   accounts: { mnemonic: MNEMONIC }
    // }
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 20000
  },
  etherscan: {
    apiKey: "P9PB88B2UK49J137QZ4JD9IMD44Q1CZ2H3"
  }
};
//constructor