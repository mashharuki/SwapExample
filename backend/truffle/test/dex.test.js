const chai = require("chai");
const { ethers } = require("hardhat");
const BN = require("bn.js");
const { expect } = chai;
chai.use(require("chai-bn")(BN));
const truffleAssert = require("truffle-assertions");

describe('DEX test', () => {

    let dai, link, comp, dex;
    let ERC20;
    let owner;
    let alice;
    let bob;
    let accounts;

    beforeEach(async() => {
        ERC20 = await ethers.getContractFactory("ERC20");
        // create Token Contracts
        dai = await ERC20.deploy("Dai", "DAI", 100000);
        link = await ERC20.deploy("Chainlink", "LINK", 1000000);
        comp = await ERC20.deploy("Compound", "COMP", 100000);
        // deploy DEX contract
        DEX = await ethers.getContractFactory("DEX");
        dex = await DEX.deploy([dai.address, link.address, comp.address]);
        await dex.deployed();
        // get accounts
        accounts = await ethers.getSigners();
        owner = accounts[0].address;
        alice = accounts[1].address;
        bob = accounts[2].address;
        // transfer
        await dai.transfer(dex.address, await dai.totalSupply());
        await link.transfer(dex.address, await link.totalSupply());
        await comp.transfer(dex.address, await comp.totalSupply());
    }); 

    
    describe("Buy token test", () => {
        it("Should revert when invalid token address is entered", async () => {
            const randomAddr = accounts[8].address;
            await truffleAssert.reverts(
              dex.buyToken(randomAddr, "1", "1", { value: "1" })
            );
        });
    
        it("Should pass when every paramter is valid", async () => {
            const tokenAddr = dai.address;
            console.log("alies:", alice)
            await truffleAssert.passes(
                // dex.connect(alice).buyToken(tokenAddr, "100", "10000", { value: "100" })
                dex.connect(owner).buyToken(tokenAddr, "100", "10000", { value: "100" })
            );
        });
    
        it("Should update dex and alice balance after buying", async () => {
            const aliceDai = await dai.balanceOf(alice);
            const ownerDai = await dai.balanceOf(owner);
            const dexEth = await web3.eth.getBalance(dex.address);
        
            expect(ownerDai).to.be.equal("10000");
            expect(dexEth).to.be.equal("100");
        });
    });
    
    describe("Sell token test", async () => {
        it("Should only pass if alice approved token transfer", async () => {
            const tokenAddr = dai.address;
            await truffleAssert.reverts(
              dex.connect(alice).sellToken(tokenAddr, "5000", "50")
            );
      
            await dai.connect(alice).approve(dex.address, "5000");
      
            await truffleAssert.passes(
              dex.connect(alice).sellToken(tokenAddr, "5000", "50")
            );
        });
    });
});