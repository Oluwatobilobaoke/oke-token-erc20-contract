import { ethers } from "hardhat";

async function main() {
  const erc20Token = await ethers.deployContract("OkeToken");

  await erc20Token.waitForDeployment();

  console.log(`OkeToken contract deployed to ${erc20Token.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// npx hardhat run scripts/deploy.ts --network sepolia
//  npx hardhat verify --network sepolia 0x94123523FB53055B5486822c2DDe1B46a8CD69E1

// npx hardhat test
