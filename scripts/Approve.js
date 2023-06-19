const { ethers } = require("hardhat");
const abi_Archie = require("../artifacts/contracts/utils/Archietoken.sol/ArchieToken.json").abi;
const abi_BUSD = require("../artifacts/contracts/utils/BUSDToken.sol/BUSDToken.json").abi;
const { ArchieToken } = require("../data/addresses.json");
const { BUSDToken } = require("../data/addresses.json");
const Staking = require("../data/address_this.json");
const connector = require("../utils/connect");

async function Approve() {
    const [signer] = await ethers.getSigners();
    console.log("Archie", ArchieToken);
    console.log("BUSD", BUSDToken);
    const Archie = new ethers.Contract(ArchieToken, abi_Archie, signer.provider);
    const BUSD = new ethers.Contract(BUSDToken, abi_BUSD, signer.provider);
    const amount = "10000000000000000000000000000000000000";
    await Archie.connect(signer).approve(Staking, amount);
    await BUSD.connect(signer).approve(Staking, amount);
}
Approve()