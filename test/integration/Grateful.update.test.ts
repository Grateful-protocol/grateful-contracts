import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { updateFixture } from "../fixtures/fixtures";

describe("Grateful", () => {
  describe("Update subscription", () => {
    it("Should return the right subscription data", async () => {
      const {
        subscriptionsModule,
        giver,
        creator,
        vaultId,
        rate,
        feeRate,
        duration,
      } = await loadFixture(updateFixture);

      // Get last timestamp
      const timestamp = await time.latest();

      // Get subscription struct
      const subscription = await subscriptionsModule.getSubscriptionFrom(
        giver.profileId,
        creator.profileId
      );

      // Assert each subscription element
      expect(subscription.rate).to.be.equal(rate);
      expect(subscription.feeRate).to.be.equal(feeRate);
      expect(subscription.lastUpdate).to.be.equal(timestamp);
      expect(subscription.duration).to.be.equal(duration);
      expect(subscription.creatorId).to.be.equal(creator.profileId);
      expect(subscription.vaultId).to.be.equal(vaultId);
    });

    it("Should return the right subscription rates", async () => {
      const { subscriptionsModule, subscriptionId, rate, feeRate } =
        await loadFixture(updateFixture);

      const [currentRate, currentFeeRate] =
        await subscriptionsModule.getSubscriptionRates(subscriptionId);

      expect(currentRate).to.be.equal(rate);
      expect(currentFeeRate).to.be.equal(feeRate);
    });

    it("Should return the right giver flow", async () => {
      const { balancesModule, giver, vaultId, rate, feeRate } =
        await loadFixture(updateFixture);

      // Negative flow because balance is decreasing
      const flow = -rate.add(feeRate);

      expect(
        await balancesModule.getFlow(giver.profileId, vaultId)
      ).to.be.equal(flow);
    });

    it("Should return the right creator flow", async () => {
      const { balancesModule, creator, vaultId, rate } = await loadFixture(
        updateFixture
      );

      expect(
        await balancesModule.getFlow(creator.profileId, vaultId)
      ).to.be.equal(rate);
    });

    it("Should return the right treasury flow", async () => {
      const { balancesModule, treasuryId, vaultId, feeRate } =
        await loadFixture(updateFixture);

      expect(await balancesModule.getFlow(treasuryId, vaultId)).to.be.equal(
        feeRate
      );
    });

    it("Should return that the user is subscribed to the creator", async () => {
      const { subscriptionsModule, giver, creator } = await loadFixture(
        updateFixture
      );

      expect(
        await subscriptionsModule.isSubscribed(
          giver.profileId,
          creator.profileId
        )
      ).to.equal(true);
    });

    it("Should emit a SubscriptionCreated event", async () => {
      const {
        tx,
        subscriptionsModule,
        giver,
        creator,
        vaultId,
        rate,
        feeRate,
        subscriptionId,
      } = await loadFixture(updateFixture);

      await expect(tx)
        .to.emit(subscriptionsModule, "SubscriptionCreated")
        .withArgs(
          giver.profileId,
          creator.profileId,
          vaultId,
          subscriptionId,
          rate,
          feeRate
        );
    });
  });

  describe("Update subscription NFT", () => {
    it("Should not mint another subscription NFT to giver", async () => {
      const { giver, gratefulSubscription } = await loadFixture(updateFixture);

      expect(await gratefulSubscription.balanceOf(giver.address)).to.be.equal(
        1
      );
    });

    it("Should return the right subscription data from subscription ID", async () => {
      const {
        subscriptionsModule,
        subscriptionId,
        rate,
        feeRate,
        creator,
        vaultId,
        duration,
      } = await loadFixture(updateFixture);

      // Get last timestamp
      const timestamp = await time.latest();

      // Get subscription struct
      const subscription = await subscriptionsModule.getSubscription(
        subscriptionId
      );

      // Assert each subscription element
      expect(subscription.rate).to.be.equal(rate);
      expect(subscription.feeRate).to.be.equal(feeRate);
      expect(subscription.lastUpdate).to.be.equal(timestamp);
      expect(subscription.duration).to.be.equal(duration);
      expect(subscription.creatorId).to.be.equal(creator.profileId);
      expect(subscription.vaultId).to.be.equal(vaultId);
    });
  });
});
