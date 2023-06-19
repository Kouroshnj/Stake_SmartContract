const { ethers } = require("hardhat");
const connector = require("../utils/connect");

async function Data() {
    const contract = await connector();
    const data = await contract.StakerInfo("1");
    console.log(data);
}
Data();