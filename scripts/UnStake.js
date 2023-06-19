const { ethers } = require("hardhat");
const connector = require("../utils/connect");

async function unstake() {
    const [signer, addr1] = await ethers.getSigners();
    const contract = await connector();
    const set = await contract.connect(signer).Unstake("1");
    console.log(set);
}
unstake()