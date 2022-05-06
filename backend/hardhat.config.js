require("@nomiclabs/hardhat-waffle");
const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: "0.8.4",
  paths: {                         // add this 
    artifacts: './../client/src/artifacts',  // this is where our compiled contracts will go
  },
  networks: {     
    // ローカル設定用
    hardhat: {
      chainId: 1337              // this is needed for MetaMask
    }, 
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
      details: {
        yul: false
      },
    }
  },
  viaIR : true
};
