const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  
  const CONTRACT_ADDRESS = "0x6B80d74362e1Cd58Fe1261646Dff3CA47c55094F";
  
  const contract = await hre.ethers.getContractAt("HissedarAssetToken", CONTRACT_ADDRESS);

  console.log("Registering asset on contract...\n");

  // Kadýköy Sahil Residence
  // tokenId: 1 (ilk asset)
  // totalSupply: 1000 (DB'deki total_tokens ile ayný)
  // pricePerToken: 2500 (token_price ? wei olarak deðil, referans deðer)
  // metadataURI: ileride IPFS'e taþýnacak
  const tx = await contract.createAsset(
    1,                                          // tokenId
    "Kadýköy Sahil Residence",                  // name
    1000,                                       // totalSupply
    hre.ethers.parseEther("0.01"),              // pricePerToken (referans, asýl fiyat DB'de)
    "https://api.hissedar.com/metadata/1"       // metadataURI
  );

  await tx.wait();
  console.log("? Asset registered!");
  console.log("   tokenId: 1");
  console.log("   name: Kadýköy Sahil Residence");
  console.log("   totalSupply: 1000");
  console.log("   tx:", tx.hash);

  // Doðrulama
  const asset = await contract.getAsset(1);
  console.log("\n?? On-chain asset bilgisi:");
  console.log("   name:", asset.name);
  console.log("   totalSupply:", asset.totalSupply.toString());
  console.log("   minted:", asset.minted.toString());
  console.log("   active:", asset.active);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });