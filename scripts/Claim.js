const { ethers } = require("hardhat");
const connector = require("../utils/connect");

async function claim() {
    const [signer, addr1] = await ethers.getSigners();
    const contract = await connector();
    const set = await contract.connect(addr1).ClaimReward("1");
}