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

    it("Should set the right solvency time required", async () => {
      const { configModule, SOLVENCY_TIME } = await loadFixture(
        deployCompleteSystem
      );

      expect(await configModule.getSolvencyTimeRequired()).to.be.equal(
        SOLVENCY_TIME
      );
    });

    it("Should set the right liquidation time required", async () => {
      const { configModule, LIQUIDATION_TIME } = await loadFixture(
        deployCompleteSystem
      );

      expect(await configModule.getLiquidationTimeRequired()).to.be.equal(
        LIQUIDATION_TIME
      );
    });

    it("Should set the right grateful subscription address", async () => {
      const { configModule, gratefulSubscription } = await loadFixture(
        deployCompleteSystem
      );

      expect(await configModule.getGratefulSubscription()).to.be.equal(
        gratefulSubscription.address
      );
    });

    it("Should set the right treasury ID", async () => {
      const { feesModule, treasuryId } = await loadFixture(
        deployCompleteSystem
      );

      expect(await feesModule.getFeeTreasuryId()).to.be.equal(treasuryId);
    });

    it("Should set the right fee percentage", async () => {
      const { feesModule, FEE_PERCENTAGE } = await loadFixture(
        deployCompleteSystem
      );

      expect(await feesModule.getFeePercentage()).to.be.equal(FEE_PERCENTAGE);
    });
  });
});
