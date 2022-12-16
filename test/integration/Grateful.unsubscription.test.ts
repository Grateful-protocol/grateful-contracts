import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { unsubscribeFixture } from "../fixtures/fixtures";

describe("Grateful", () => {
  describe("Unsubscription", () => {
    it("Should return the right subscription data", async () => {
      const {
        subscriptionsModule,
        giver,
        creator,
        vaultId,
        duration,
        totalRate,
        rate,
      } = await loadFixture(unsubscribeFixture);

      // Get last timestamp
      const timestamp = await time.latest();

      // Get subscription struct
      const subscription = await subscriptionsModule.getSubscription(
        giver.profileId,
        creator.profileId,
        vaultId
      );

      // Assert each subscription element
      expect(subscription.rate).to.be.equal(0);
      expect(subscription.feeRate).to.be.equal(0);
      expect(subscription.lastUpdate).to.be.equal(timestamp);
      expect(subscription.duration).to.be.equal(duration.add(1));
      expect(subscription.totalRate).to.be.equal(totalRate.add(rate));
    });

    it("Should return the right subscription rate", async () => {
      const { subscriptionsModule, giver, creator, vaultId } =
        await loadFixture(unsubscribeFixture);

      expect(
        await subscriptionsModule.getSubscriptionRate(
          giver.profileId,
          creator.profileId,
          vaultId
        )
      ).to.be.equal(0);
    });

    it("Should return the right giver flow", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        unsubscribeFixture
      );

      expect(
        await balancesModule.getFlow(giver.profileId, vaultId)
      ).to.be.equal(0);
    });

    it("Should return the right creator flow", async () => {
      const { balancesModule, creator, vaultId } = await loadFixture(
        unsubscribeFixture
      );

      expect(
        await balancesModule.getFlow(creator.profileId, vaultId)
      ).to.be.equal(0);
    });

    it("Should return the right treasury flow", async () => {
      const { balancesModule, treasuryId, vaultId } = await loadFixture(
        unsubscribeFixture
      );

      expect(await balancesModule.getFlow(treasuryId, vaultId)).to.be.equal(0);
    });

    it("Should return that the user is subscribed to the creator", async () => {
      const { subscriptionsModule, giver, creator, vaultId } =
        await loadFixture(unsubscribeFixture);

      expect(
        await subscriptionsModule.isSubscribe(
          giver.profileId,
          creator.profileId,
          vaultId
        )
      ).to.equal(false);
    });

    it("Should emit a SubscriptionFinished event", async () => {
      const { tx, subscriptionsModule, giver, creator, vaultId, rate } =
        await loadFixture(unsubscribeFixture);

      await expect(tx)
        .to.emit(subscriptionsModule, "SubscriptionFinished")
        .withArgs(giver.profileId, creator.profileId, vaultId, 0, rate);
    });
  });
});
