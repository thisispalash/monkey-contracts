import { ethers } from "hardhat";
import { writeFileSync } from "fs";
import { join } from "path";

async function main() {
  console.log("Deploying WRBTC and rUSDT tokens...");

  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  // Deploy WRBTC
  console.log("Deploying WRBTC...");
  const WRBTC = await ethers.getContractFactory("DummyERC20");
  const wrbtc = await WRBTC.deploy("WRBTC", "WRBTC");
  await wrbtc.waitForDeployment();
  const wrbtcAddress = await wrbtc.getAddress();
  console.log(`WRBTC deployed to: ${wrbtcAddress}`);

  // Deploy rUSDT
  console.log("Deploying rUSDT...");
  const RUSDT = await ethers.getContractFactory("DummyERC20");
  const rusdt = await RUSDT.deploy("rUSDT", "rUSDT");
  await rusdt.waitForDeployment();
  const rusdtAddress = await rusdt.getAddress();
  console.log(`rUSDT deployed to: ${rusdtAddress}`);

  // Save deployment addresses to a file
  const deploymentData = {
    WRBTC: wrbtcAddress,
    RUSDT: rusdtAddress,
    timestamp: new Date().toISOString(),
    network: (await ethers.provider.getNetwork()).name,
  };

  const deploymentsDir = join(__dirname, "../deployments");
  try {
    writeFileSync(
      join(deploymentsDir, "tokens.json"),
      JSON.stringify(deploymentData, null, 2)
    );
    console.log("Deployment addresses saved to deployments/tokens.json");
  } catch (error) {
    console.error("Failed to save deployment addresses:", error);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
