const chai = require("chai");
const { ethers } = require("hardhat");
const BN = require("bn.js");
const { expect } = chai;
chai.use(require("chai-bn")(BN));

describe('ERC20 test', () => {

    let dai, link, comp;
    let ERC20;
    let owner;
    let alice;
    let bob;

    beforeEach(async() => {
        ERC20 = await ethers.getContractFactory("ERC20");
        // create Token Contracts
        dai = await ERC20.deploy("Dai", "DAI", 1000);
        link = await ERC20.deploy("Chainlink", "LINK", 1000);
        comp = await ERC20.deploy("Compound", "COMP", 1000);
        // get accounts
        const accounts = await ethers.getSigners();
        owner = accounts[0].address;
        alice = accounts[1].address;
        bob = accounts[2].address;
    });

    it("Should be init data", async function() {
        const dainame = await dai.name();
        const daisymbol = await dai.symbol();
        const daitotalSupply = await dai.totalSupply();
        const linkname = await link.name();
        const linksymbol = await link.symbol();
        const linktotalSupply = await link.totalSupply();
        const compname = await comp.name();
        const compsymbol = await comp.symbol();
        const comptotalSupply = await comp.totalSupply();

        expect(dainame).to.be.equal("Dai");
        expect(daisymbol).to.be.equal("DAI");
        expect(daitotalSupply).to.be.equal(1000);
        expect(linkname).to.be.equal("Chainlink");
        expect(linksymbol).to.be.equal("LINK");
        expect(linktotalSupply).to.be.equal(1000);
        expect(compname).to.be.equal("Compound");
        expect(compsymbol).to.be.equal("COMP");
        expect(comptotalSupply).to.be.equal(1000);
    });

    it("transfer token test", async function() {
        const daiTransferTx1 = await dai.transfer(alice, 100);
        const daiTransferTx2 = await dai.transfer(bob, 200);
        // wait until the transaction is mined
        await daiTransferTx1.wait();
        await daiTransferTx2.wait();

        const aliceDaiBalance = await dai.balanceOf(alice);
        const bobDaiBalance = await dai.balanceOf(bob);
        const ownerDaiBalance = await dai.balanceOf(owner);

        expect(aliceDaiBalance).to.be.equal(100);
        expect(bobDaiBalance).to.be.equal(200);
        expect(ownerDaiBalance).to.be.equal(700);
    });

    it("approve token test", async function() {
        const daiApproveTx1 = await dai.approve(alice, 100);
        const daiApproveTx2 = await dai.approve(bob, 200);
        await daiApproveTx1.wait();
        await daiApproveTx2.wait();
        const aliceAllowance = await dai.allowance(owner, alice);
        const bobAllowance = await dai.allowance(owner, bob);
        expect(aliceAllowance).to.be.equal(100);
        expect(bobAllowance).to.be.equal(200);

        /*
        const daiTransferTx1 = await dai.connect(alice).transferFrom(alice, bob, 90);
        const daiTransferTx2 = await dai.connect(bob).transferFrom(bob, alice, 190);
        // wait until the transaction is mined
        await daiTransferTx1.wait();
        await daiTransferTx2.wait();

        const aliceDaiBalance = await dai.balanceOf(alice);
        const bobDaiBalance = await dai.balanceOf(bob);
        const ownerDaiBalance = await dai.balanceOf(owner);

        expect(aliceDaiBalance).to.be.equal(190);
        expect(bobDaiBalance).to.be.equal(390);
        expect(ownerDaiBalance).to.be.equal(520);
        */
    });
});
