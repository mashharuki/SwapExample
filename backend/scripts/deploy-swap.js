const hre = require("hardhat");

async function main() {
  const toWei = (number) => web3.utils.toWei(web3.utils.toBN(number), 'ether');
  // deploy token contracts
  const ERC20 = await hre.ethers.getContractFactory("ERC20");
  const dai = await ERC20.deploy("Dai", "DAI", toWei(10**10));
  const link = await ERC20.deploy("Chainlink", "LINK", toWei(10**6));
  const comp = await ERC20.deploy("Compound", "COMP", toWei(10**4));

  await dai.deployed();
  await link.deployed();
  await comp.deployed();

  console.log("Dai deployed to:", dai.address);
  console.log("Chainlink deployed to:", link.address);
  console.log("Compound deployed to:", comp.address);

  // deploy DEX contract
  const DEX = await hre.ethers.getContractFactory("DEX");
  const dex = await DEX.deploy([dai.address, link.address, comp.address]);
  await dex.deployed();

  console.log("DEX deployed to:", dex.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
