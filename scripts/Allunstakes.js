const { ethers } = require("hardhat");
const connector = require("../utils/connect");

async function Data() {
    const contract = await connector();
    const data = await contract.AllUnstakes()
    console.log(data);
}
Data();