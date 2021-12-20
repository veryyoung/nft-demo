const hre = require("hardhat");

async function main() {
  const contractFactory = await hre.ethers.getContractFactory("VeryyongNFTDemo");
  const contract = await contractFactory.deploy(
    "ipfs://QmPphQMMEhwmXMp3m4sJrtL9xqAX8emiXBZw8UeVGhqZhK/"
  );

  await contract.deployed();

  console.log("Veryyoung NFT demo contract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });