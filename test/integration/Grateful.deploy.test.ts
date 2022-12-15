import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { deployCompleteSystem } from "../fixtures/fixtures";

describe("Grateful", () => {
  describe("Deployment", () => {
    it("Should be initialized", async () => {
      const { ownerModule } = await loadFixture(deployCompleteSystem);

      expect(await ownerModule.isOwnerModuleInitialized()).to.equal(true);
    });

    it("Should set the right owner", async () => {
      const { ownerModule, owner } = await loadFixture(deployCompleteSystem);

      expect(await ownerModule.owner()).to.equal(owner.address);
    });

    it("Should set the right vault", async () => {
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

    it("Should mint grateful profile to user correctly", async () => {
      const { gratefulProfile, giver } = await loadFixture(
        deployCompleteSystem
      );

      expect(await gratefulProfile.ownerOf(giver.tokenId)).to.be.equal(
        giver.address
      );
    });

    it("Should not have user balance into grateful", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        deployCompleteSystem
      );

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.equal(0);
    });
  });
});
