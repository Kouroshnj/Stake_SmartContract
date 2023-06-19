const { ethers } = require("hardhat");
const abi = require("../artifacts/contracts/Staking.sol/Staking.json").abi;
const address = require("../data/address_this.json");

async function run() {
    const [signer] = await ethers.getSigners();
    const Contract = new ethers.Contract(address, abi, signer.provider);
    return Contract;
}
module.exports = run;