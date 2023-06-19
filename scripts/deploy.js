const { ethers } = require("hardhat");
const { Tokens } = require("./deployTokens");
const fs = require('fs');

async function main() {
    const [deployer] = await ethers.getSigners();
    const addresses = await Tokens();
    fs.writeFileSync("./data/addresses.json", JSON.stringify(addresses));
    console.log("deploying tokens with address:", deployer.address);

    const Contract = await ethers.getContractFactory("Staking");
    const Staking = await Contract.deploy(addresses.ArchieToken, addresses.BUSDToken, deployer.address);
    console.log("Staking contract address is:", Staking.address);

    fs.writeFileSync("./data/address_this.json", JSON.stringify(Staking.address))
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });