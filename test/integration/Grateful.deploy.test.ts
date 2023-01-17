import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySystemFixture } from "../fixtures/fixtures";

describe("Grateful", () => {
  describe("Deployment", () => {
    it("Should be initialized", async () => {
      const { coreModule } = await loadFixture(deploySystemFixture);

      expect(await coreModule.isOwnerModuleInitialized()).to.equal(true);
    });

    it("Should set the right owner", async () => {
      const { coreModule, owner } = await loadFixture(deploySystemFixture);

      expect(await coreModule.owner()).to.equal(owner.address);
    });

    it("Should set the right vault", async () => {
      const { vaultsModule, vaultId, vault } = await loadFixture(
        deploySystemFixture
      );

      expect(await vaultsModule.getVault(vaultId)).to.equal(vault.address);
    });

    it("Should set grateful profile allowed", async () => {
      const { profilesModule, gratefulProfile } = await loadFixture(
        deploySystemFixture
      );

      expect(await profilesModule.isProfileAllowed(gratefulProfile.address)).to
        .be.true;
    });

    it("Should mint grateful profile to user correctly", async () => {
      const { gratefulProfile, giver } = await loadFixture(deploySystemFixture);

      expect(await gratefulProfile.ownerOf(giver.tokenId)).to.be.equal(
        giver.address
      );
    });

    it("Should not have user balance into grateful", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        deploySystemFixture
      );

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.equal(0);
    });

    it("Should set the right solvency time required", async () => {
      const { configModule, SOLVENCY_TIME } = await loadFixture(
        deploySystemFixture
      );

      expect(await configModule.getSolvencyTimeRequired()).to.be.equal(
        SOLVENCY_TIME
      );
    });

    it("Should set the right liquidation time required", async () => {
      const { configModule, LIQUIDATION_TIME } = await loadFixture(
        deploySystemFixture
      );

      expect(await configModule.getLiquidationTimeRequired()).to.be.equal(
        LIQUIDATION_TIME
      );
    });

    it("Should set the right grateful subscription address", async () => {
      const { configModule, gratefulSubscription } = await loadFixture(
        deploySystemFixture
      );

      expect(await configModule.getGratefulSubscription()).to.be.equal(
        gratefulSubscription.address
      );
    });

    it("Should set the right treasury ID", async () => {
      const { feesModule, treasuryId } = await loadFixture(deploySystemFixture);

      expect(await feesModule.getFeeTreasuryId()).to.be.equal(treasuryId);
    });

    it("Should set the right fee percentage", async () => {
      const { feesModule, FEE_PERCENTAGE } = await loadFixture(
        deploySystemFixture
      );

      expect(await feesModule.getFeePercentage()).to.be.equal(FEE_PERCENTAGE);
    });
  });
});
