const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("HissedarAssetToken", function () {
  // ────────────────────────────────────────────
  //  Fixture
  // ────────────────────────────────────────────

  async function deployFixture() {
    const [owner, treasury, user1, user2, user3] = await ethers.getSigners();

    const HissedarAssetToken = await ethers.getContractFactory("HissedarAssetToken");
    const contract = await HissedarAssetToken.deploy(
      "https://api.hissedar.com/metadata/",
      treasury.address
    );

    // Sample asset data
    const sampleAsset = {
      tokenId: 1,
      name: "Kadıköy Residence #1",
      totalSupply: 10000,
      pricePerToken: ethers.parseEther("0.01"),
      metadataURI: "ipfs://QmSampleHash1",
    };

    return { contract, owner, treasury, user1, user2, user3, sampleAsset };
  }

  // ────────────────────────────────────────────
  //  Deployment
  // ────────────────────────────────────────────

  describe("Deployment", function () {
    it("should set the correct owner", async function () {
      const { contract, owner } = await loadFixture(deployFixture);
      expect(await contract.owner()).to.equal(owner.address);
    });

    it("should set the correct treasury", async function () {
      const { contract, treasury } = await loadFixture(deployFixture);
      expect(await contract.treasury()).to.equal(treasury.address);
    });

    it("should revert if treasury is zero address", async function () {
      const HissedarAssetToken = await ethers.getContractFactory("HissedarAssetToken");
      await expect(
        HissedarAssetToken.deploy("https://api.hissedar.com/metadata/", ethers.ZeroAddress)
      ).to.be.revertedWithCustomError(HissedarAssetToken, "InvalidAddress");
    });
  });

  // ────────────────────────────────────────────
  //  Asset Management
  // ────────────────────────────────────────────

  describe("Asset Management", function () {
    it("should create an asset", async function () {
      const { contract, sampleAsset } = await loadFixture(deployFixture);

      await expect(
        contract.createAsset(
          sampleAsset.tokenId,
          sampleAsset.name,
          sampleAsset.totalSupply,
          sampleAsset.pricePerToken,
          sampleAsset.metadataURI
        )
      )
        .to.emit(contract, "AssetCreated")
        .withArgs(sampleAsset.tokenId, sampleAsset.name, sampleAsset.totalSupply, sampleAsset.pricePerToken);

      const asset = await contract.getAsset(sampleAsset.tokenId);
      expect(asset.name).to.equal(sampleAsset.name);
      expect(asset.totalSupply).to.equal(sampleAsset.totalSupply);
      expect(asset.minted).to.equal(0);
      expect(asset.active).to.equal(true);
    });

    it("should revert if asset already exists", async function () {
      const { contract, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );

      await expect(
        contract.createAsset(
          sampleAsset.tokenId, "Duplicate", 100,
          ethers.parseEther("0.05"), "ipfs://dup"
        )
      ).to.be.revertedWithCustomError(contract, "AssetAlreadyExists");
    });

    it("should revert if totalSupply is zero", async function () {
      const { contract } = await loadFixture(deployFixture);

      await expect(
        contract.createAsset(99, "Zero Supply", 0, ethers.parseEther("0.01"), "ipfs://zero")
      ).to.be.revertedWithCustomError(contract, "InvalidTotalSupply");
    });

    it("should update asset price and active status", async function () {
      const { contract, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );

      const newPrice = ethers.parseEther("0.02");
      await contract.updateAsset(sampleAsset.tokenId, newPrice, false);

      const asset = await contract.getAsset(sampleAsset.tokenId);
      expect(asset.pricePerToken).to.equal(newPrice);
      expect(asset.active).to.equal(false);
    });

    it("should only allow owner to create assets", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await expect(
        contract.connect(user1).createAsset(
          sampleAsset.tokenId, sampleAsset.name,
          sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
        )
      ).to.be.revertedWithCustomError(contract, "OwnableUnauthorizedAccount");
    });
  });

  // ────────────────────────────────────────────
  //  Whitelist
  // ────────────────────────────────────────────

  describe("Whitelist", function () {
    it("should add address to whitelist", async function () {
      const { contract, user1 } = await loadFixture(deployFixture);

      await expect(contract.addToWhitelist(user1.address))
        .to.emit(contract, "AddressWhitelisted")
        .withArgs(user1.address);

      expect(await contract.whitelisted(user1.address)).to.equal(true);
    });

    it("should batch add addresses", async function () {
      const { contract, user1, user2, user3 } = await loadFixture(deployFixture);

      await contract.batchAddToWhitelist([user1.address, user2.address, user3.address]);

      expect(await contract.whitelisted(user1.address)).to.equal(true);
      expect(await contract.whitelisted(user2.address)).to.equal(true);
      expect(await contract.whitelisted(user3.address)).to.equal(true);
    });

    it("should remove address from whitelist", async function () {
      const { contract, user1 } = await loadFixture(deployFixture);

      await contract.addToWhitelist(user1.address);
      await contract.removeFromWhitelist(user1.address);

      expect(await contract.whitelisted(user1.address)).to.equal(false);
    });

    it("should revert whitelist with zero address", async function () {
      const { contract } = await loadFixture(deployFixture);

      await expect(
        contract.addToWhitelist(ethers.ZeroAddress)
      ).to.be.revertedWithCustomError(contract, "InvalidAddress");
    });
  });

  // ────────────────────────────────────────────
  //  Minting
  // ────────────────────────────────────────────

  describe("Minting", function () {
    it("should mint tokens to whitelisted address", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);

      const mintAmount = 100;
      await expect(contract.mintTokens(user1.address, sampleAsset.tokenId, mintAmount))
        .to.emit(contract, "TokensMinted")
        .withArgs(sampleAsset.tokenId, user1.address, mintAmount);

      expect(await contract.balanceOf(user1.address, sampleAsset.tokenId)).to.equal(mintAmount);

      const asset = await contract.getAsset(sampleAsset.tokenId);
      expect(asset.minted).to.equal(mintAmount);
    });

    it("should revert mint to non-whitelisted address", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );

      await expect(
        contract.mintTokens(user1.address, sampleAsset.tokenId, 100)
      ).to.be.revertedWithCustomError(contract, "NotWhitelisted");
    });

    it("should revert if exceeds max supply", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);

      await expect(
        contract.mintTokens(user1.address, sampleAsset.tokenId, sampleAsset.totalSupply + 1)
      ).to.be.revertedWithCustomError(contract, "ExceedsMaxSupply");
    });

    it("should revert mint with zero amount", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);

      await expect(
        contract.mintTokens(user1.address, sampleAsset.tokenId, 0)
      ).to.be.revertedWithCustomError(contract, "InvalidAmount");
    });

    it("should revert mint on inactive asset", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);
      await contract.updateAsset(sampleAsset.tokenId, sampleAsset.pricePerToken, false);

      await expect(
        contract.mintTokens(user1.address, sampleAsset.tokenId, 100)
      ).to.be.revertedWithCustomError(contract, "AssetNotActive");
    });
  });

  // ────────────────────────────────────────────
  //  Burning
  // ────────────────────────────────────────────

  describe("Burning", function () {
    it("should burn tokens", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);
      await contract.mintTokens(user1.address, sampleAsset.tokenId, 100);

      await expect(contract.burnTokens(user1.address, sampleAsset.tokenId, 50))
        .to.emit(contract, "TokensBurned")
        .withArgs(sampleAsset.tokenId, user1.address, 50);

      expect(await contract.balanceOf(user1.address, sampleAsset.tokenId)).to.equal(50);

      const asset = await contract.getAsset(sampleAsset.tokenId);
      expect(asset.minted).to.equal(50);
    });

    it("should revert burn exceeding balance", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);
      await contract.mintTokens(user1.address, sampleAsset.tokenId, 100);

      await expect(
        contract.burnTokens(user1.address, sampleAsset.tokenId, 200)
      ).to.be.revertedWithCustomError(contract, "InsufficientBalance");
    });
  });

  // ────────────────────────────────────────────
  //  Transfer Restriction
  // ────────────────────────────────────────────

  describe("Transfer Restriction", function () {
    it("should block user-to-user transfers", async function () {
      const { contract, user1, user2, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);
      await contract.addToWhitelist(user2.address);
      await contract.mintTokens(user1.address, sampleAsset.tokenId, 100);

      // safeTransferFrom should revert
      await expect(
        contract.connect(user1).safeTransferFrom(
          user1.address, user2.address, sampleAsset.tokenId, 50, "0x"
        )
      ).to.be.revertedWithCustomError(contract, "TransferDisabled");
    });

    it("should block batch transfers", async function () {
      const { contract, user1, user2, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);
      await contract.addToWhitelist(user2.address);
      await contract.mintTokens(user1.address, sampleAsset.tokenId, 100);

      await expect(
        contract.connect(user1).safeBatchTransferFrom(
          user1.address, user2.address, [sampleAsset.tokenId], [50], "0x"
        )
      ).to.be.revertedWithCustomError(contract, "TransferDisabled");
    });
  });

  // ────────────────────────────────────────────
  //  Pause
  // ────────────────────────────────────────────

  describe("Pause", function () {
    it("should pause and unpause", async function () {
      const { contract } = await loadFixture(deployFixture);

      await contract.pause();
      expect(await contract.paused()).to.equal(true);

      await contract.unpause();
      expect(await contract.paused()).to.equal(false);
    });

    it("should block minting when paused", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);
      await contract.pause();

      await expect(
        contract.mintTokens(user1.address, sampleAsset.tokenId, 100)
      ).to.be.revertedWithCustomError(contract, "EnforcedPause");
    });
  });

  // ────────────────────────────────────────────
  //  View Functions
  // ────────────────────────────────────────────

  describe("View Functions", function () {
    it("should return available supply", async function () {
      const { contract, user1, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.addToWhitelist(user1.address);
      await contract.mintTokens(user1.address, sampleAsset.tokenId, 300);

      const available = await contract.getAvailableSupply(sampleAsset.tokenId);
      expect(available).to.equal(sampleAsset.totalSupply - 300);
    });

    it("should return correct asset count", async function () {
      const { contract, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );
      await contract.createAsset(2, "Art Piece #1", 500, ethers.parseEther("0.1"), "ipfs://art1");

      expect(await contract.getAssetCount()).to.equal(2);
    });

    it("should return per-asset URI", async function () {
      const { contract, sampleAsset } = await loadFixture(deployFixture);

      await contract.createAsset(
        sampleAsset.tokenId, sampleAsset.name,
        sampleAsset.totalSupply, sampleAsset.pricePerToken, sampleAsset.metadataURI
      );

      expect(await contract.uri(sampleAsset.tokenId)).to.equal(sampleAsset.metadataURI);
    });
  });

  // ────────────────────────────────────────────
  //  Treasury
  // ────────────────────────────────────────────

  describe("Treasury", function () {
    it("should update treasury address", async function () {
      const { contract, user1, treasury } = await loadFixture(deployFixture);

      await expect(contract.setTreasury(user1.address))
        .to.emit(contract, "TreasuryUpdated")
        .withArgs(treasury.address, user1.address);

      expect(await contract.treasury()).to.equal(user1.address);
    });

    it("should revert treasury update to zero address", async function () {
      const { contract } = await loadFixture(deployFixture);

      await expect(
        contract.setTreasury(ethers.ZeroAddress)
      ).to.be.revertedWithCustomError(contract, "InvalidAddress");
    });
  });
});
