import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deployCompleteSystem } from "./fixtures";

describe("System", function () {
  describe("Deployment", function () {
    it("Should be initialized", async function () {
      const { ownerModule } = await loadFixture(deployCompleteSystem);

      expect(await ownerModule.isOwnerModuleInitialized()).to.equal(true);
    });

    it("Should set the right owner", async function () {
      const { ownerModule, owner } = await loadFixture(deployCompleteSystem);

      expect(await ownerModule.owner()).to.equal(owner.address);
    });

    it("Should set the right vault", async function () {
      const { vaultsModule, vaultId, vault } = await loadFixture(
        deployCompleteSystem
      );

      expect(await vaultsModule.getVault(vaultId)).to.equal(vault.address);
    });

    it("Should set grateful profile allowed", async () => {
      const { profileModule, gratefulProfile } = await loadFixture(
        deployCompleteSystem
      );

      expect(await profileModule.isProfileAllowed(gratefulProfile.address)).to
        .be.true;
    });
  });
});
