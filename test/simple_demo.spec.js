const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTSimpleDemo", function () {

  const initBaseURI = "ipfs://initBaseURI";

  beforeEach(async function () {
    const contractFactory = await ethers.getContractFactory("VeryyoungNFTSimpleDemo");
    contract = await contractFactory.deploy("Veryyoung NFT Simple Demo", "VNSD", initBaseURI);
    await contract.deployed();

    accounts = await ethers.getSigners();
    deployer = accounts[0];
    minter = accounts[1];
  });

  it("Should return the new baseURI once it's changed", async function () {
    expect(await contract.baseURI()).to.equal(initBaseURI);

    const newBaseURI = "ipfs://newBaseURI";
    const setBaseURITx = await contract.setBaseURI(newBaseURI);
    await setBaseURITx.wait();

    expect(await contract.baseURI()).to.equal(newBaseURI);
  });

  it("Should mint one success when amount and value is set ok", async function () {
    const amount = 1;
    const tx = await contract.connect(minter).mint(amount, {
      value: ethers.utils.parseEther("0.1")
    });
    const tr = await tx.wait();
    expect(tr.status).equal(1)

    let events = tr.events;
    if (events && events[0] && events[0].args) {
      let tokenID = events[0].args.tokenId;
      expect(await contract.ownerOf(tokenID.toString())).to.equal(minter.address);
    }
  });
});