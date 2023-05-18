import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deploySystemFixture } from "../fixtures/fixtures";

describe("Grateful", () => {
  describe("Deployment", () => {
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

    it("Should set grateful profile NFT as an associated system", async () => {
      const { associatedSystemsModule, gratefulProfile } = await loadFixture(
        deploySystemFixture
      );

      const profileSystemName =
        ethers.utils.formatBytes32String("gratefulProfileNft");
      const profileSystemKind = ethers.utils.formatBytes32String("erc721");

      const profile = await associatedSystemsModule.getAssociatedSystem(
        profileSystemName
      );

      expect(profile.addr).to.be.equal(gratefulProfile.address);
      expect(profile.kind).to.be.equal(profileSystemKind);
    });

    it("Should set grateful subscription NFT as an associated system", async () => {
      const { associatedSystemsModule, gratefulSubscription } =
        await loadFixture(deploySystemFixture);

      const subscriptionSystemName = ethers.utils.formatBytes32String(
        "gratefulSubscriptionNft"
      );
      const subscriptionSystemKind = ethers.utils.formatBytes32String("erc721");

      const subscription = await associatedSystemsModule.getAssociatedSystem(
        subscriptionSystemName
      );

      expect(subscription.addr).to.be.equal(gratefulSubscription.address);
      expect(subscription.kind).to.be.equal(subscriptionSystemKind);
    });

    it("Should return no duration for unexistent subscription", async () => {
      const { subscriptionsModule } = await loadFixture(deploySystemFixture);

      const subscriptionId = ethers.utils.formatBytes32String(
        "invalid-subscriptionId"
      );

      const duration = await subscriptionsModule.getSubscriptionDuration(
        subscriptionId
      );

      expect(duration).to.be.equal(0);
    });
  });
});
