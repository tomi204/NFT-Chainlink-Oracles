const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFT204", function () {
  async function deployNFTFixture() {
    const [owner, otherAccount] = await ethers.getSigners();

    const NFT = await ethers.getContractFactory("NFT204");
    const NFT204 = await NFT.deploy(
      200,
      1000,
      "https://ipfs.io/ipfs/QmZ1u7J7NQqWbW3U2Y5fGJ2e8HsYnY4hTnZ1i4ZQn4nY5Y/",
      owner.address
    );
    return { NFT204, owner, otherAccount };
  }
  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { NFT204, owner } = await deployNFTFixture();
      expect(await NFT204.owner()).to.equal(owner.address);
    });
  });
});
