const hre = require("hardhat");

async function main() {
  const contractFactory = await hre.ethers.getContractFactory("VeryyoungNFTSimpleDemo");
  const contract = await contractFactory.deploy("Veryyoung NFT Simple Demo", "VNSD", "ipfs://QmPphQMMEhwmXMp3m4sJrtL9xqAX8emiXBZw8UeVGhqZhK/");

  await contract.deployed();

  console.log("Veryyoung simple NFT demo contract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });