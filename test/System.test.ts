import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

const { deploySystem } = require("@synthetixio/hardhat-router/utils/tests");
const {
  getProxyAddress,
} = require("@synthetixio/hardhat-router/utils/deployments");

describe("System", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  const deploySystemFixture = async () => {
    const deploymentInfo = {
      network: "hardhat",
      instance: "test",
    };

    await deploySystem(deploymentInfo, { clear: true });

    const proxyAddress = getProxyAddress(deploymentInfo);

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const ownerModule = await ethers.getContractAt(
      "contracts/modules/OwnerModule.sol:OwnerModule",
      proxyAddress
    );

    // Initialize Owner Module
    const tx = await ownerModule
      .connect(owner)
      .initializeOwnerModule(owner.address);

    await tx.wait();

    return { ownerModule, owner, otherAccount };
  };

  describe("Deployment", function () {
    it("Should be initialized", async function () {
      const { ownerModule } = await loadFixture(deploySystemFixture);

      expect(await ownerModule.isOwnerModuleInitialized()).to.equal(true);
    });

    it("Should set the right owner", async function () {
      const { ownerModule, owner } = await loadFixture(deploySystemFixture);

      expect(await ownerModule.owner()).to.equal(owner.address);
    });
  });
});
