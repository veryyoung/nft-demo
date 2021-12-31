const { expect } = require("chai");
const { ethers } = require("hardhat");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

describe("NFTDemo", function () {

  const initBaseURI = "ipfs://initBaseURI";

  let wallets;
  let contract;
  let tree;

  beforeEach(async function () {
    wallets = await ethers.getSigners();

    // build Merkle Tree with whitelist addresses as leaves
    const leaves = wallets.map((w) => keccak256(w.address));
    tree = new MerkleTree(leaves, keccak256, { sort: true });
    const root = tree.getHexRoot();

    const contractFactory = await ethers.getContractFactory("VeryyoungNFTDemo");
    contract = await contractFactory.deploy("Veryyoung NFT Demo", "VND", initBaseURI, root);
    await contract.deployed();
  });

  it("should raise an error if the presale is not active", async function () {
    const wallet = wallets[1];
    const proof = tree.getHexProof(keccak256(wallet.address));

    await expect(contract.connect(wallet).presaleMint(1, proof, {
      value: ethers.utils.parseEther("0.1")
    })).to.be.revertedWith(
      "Presale is not active."
    );
  });

  it("should allow minting for whitelisted wallets", async function () {
    await contract.connect(wallets[0]).startPresale();
    for (const [index, wallet] of wallets.entries()) {
      const proof = tree.getHexProof(keccak256(wallet.address));

      // use whitelist wallet to sent the tx
      const tx = await contract.connect(wallet).presaleMint(1, proof, {
        value: ethers.utils.parseEther("0.1")
      });
      const tr = await tx.wait();
      expect(tr.status).equal(1)
    }
  });

  it("should raise an error if the caller wallet was not whitelisted", async function () {
    await contract.connect(wallets[0]).startPresale();
    // use a random wallet which is not whitelisted
    const wallet = ethers.Wallet.createRandom().connect(wallets[0].provider);

    const proof = tree.getHexProof(keccak256(wallet.address));

    await expect(contract.connect(wallet).presaleMint(1, proof, {
      value: ethers.utils.parseEther("0.1")
    })).to.be.revertedWith(
      "User is not eligible to the Presale"
    );
  });

});