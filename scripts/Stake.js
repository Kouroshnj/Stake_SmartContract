const { ethers } = require("hardhat");
const connector = require("../utils/connect");
const { BigNumber } = require("ethers");

async function stake() {
    const [signer] = await ethers.getSigners();
    const contract = await connector();
    const amount = ethers.utils.parseEther("60")
    const set = await contract.connect(signer).Stake(amount, "1");
    console.log(set);
}
stake();