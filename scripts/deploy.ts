// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // We get the contract to deploy
  const Crowdfunding = await ethers.getContractFactory("Crowdfunding");
  // deploy the contract
  const crowdfunding = await Crowdfunding.deploy();
  // log the address of the deployed contract
  console.log("Crowdfunding deployed to:", crowdfunding.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
