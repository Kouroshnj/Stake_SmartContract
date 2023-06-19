const { ethers } = require('hardhat');

const ArchieTokenMain = "ArchieToken";
const BUSDTokenMain = "BUSDToken";

async function Tokens() {
    const [deployer] = await ethers.getSigners();
    console.log("deployer balance is:", (await deployer.getBalance()).toString());

    const ArchieTokenContract = await ethers.getContractFactory(ArchieTokenMain);
    const ArchieToken = await ArchieTokenContract.deploy();
    await ArchieToken.deployed();
    console.log("ArchieToken address is:", ArchieToken.address);

    const BUSDTokenContract = await ethers.getContractFactory(BUSDTokenMain);
    const BUSDToken = await BUSDTokenContract.deploy();
    BUSDToken.deployed();
    console.log("BUSDToken address is:", BUSDToken.address);

    let Contracts = {};
    Contracts["ArchieToken"] = ArchieToken.address;
    Contracts["BUSDToken"] = BUSDToken.address;
    return Contracts;
}
module.exports = {
    Tokens
};
