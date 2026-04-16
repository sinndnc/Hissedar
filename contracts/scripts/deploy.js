const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying HissedarAssetToken with account:", deployer.address);
  console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

  const baseURI = process.env.BASE_METADATA_URI || "https://api.hissedar.com/metadata/";
  const treasury = process.env.TREASURY_ADDRESS || deployer.address;

  const HissedarAssetToken = await hre.ethers.getContractFactory("HissedarAssetToken");
  const contract = await HissedarAssetToken.deploy(baseURI, treasury);

  await contract.waitForDeployment();

  const contractAddress = await contract.getAddress();

  console.log("\n✅ HissedarAssetToken deployed!");
  console.log("   Contract address:", contractAddress);
  console.log("   Treasury:", treasury);
  console.log("   Base URI:", baseURI);
  console.log("   Network:", hre.network.name);

  // Log verification command
  if (hre.network.name !== "hardhat") {
    console.log("\n📋 To verify on Polygonscan:");
    console.log(`   npx hardhat verify --network ${hre.network.name} ${contractAddress} "${baseURI}" "${treasury}"`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
