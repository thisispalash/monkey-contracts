import { ethers, upgrades } from "hardhat";

async function main() {

  const RecipeFactory = await ethers.getContractFactory("RecipeFactory");

  const factory = await upgrades.deployProxy(
    RecipeFactory,
    [],
    {
      initializer: "initialize",
      kind: "uups",
    }
  );

  await factory.waitForDeployment();
  console.log("Recipe Factory deployed to:", await factory.getAddress());

  // Deploy MonkeyFactory as a regular contract since it doesn't have an initialize function
  const MonkeyFactory = await ethers.getContractFactory("MonkeyFactory");
  const monkeyFactory = await MonkeyFactory.deploy();
  
  await monkeyFactory.waitForDeployment();
  console.log("Monkey Factory deployed to:", await monkeyFactory.getAddress());
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});