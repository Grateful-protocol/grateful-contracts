import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { subscribeFixture } from "../fixtures/fixtures";

describe("Grateful", () => {
  describe("Subscription", () => {
    it("Should return the right subscription data", async () => {
      const { subscriptionsModule, giver, creator, vaultId, rate, feeRate } =
        await loadFixture(subscribeFixture);

      // Get last timestamp
      const timestamp = await time.latest();

      // Get subscription struct
      const subscription = await subscriptionsModule.getSubscription(
        giver.profileId,
        creator.profileId,
        vaultId
      );

      // Assert each subscription element
      expect(subscription.rate).to.be.equal(rate);
      expect(subscription.feeRate).to.be.equal(feeRate);
      expect(subscription.lastUpdate).to.be.equal(timestamp);
      expect(subscription.duration).to.be.equal(0);
      expect(subscription.totalRate).to.be.equal(0);
    });

    it("Should return the right subscription rate", async () => {
      const { subscriptionsModule, giver, creator, vaultId, rate } =
        await loadFixture(subscribeFixture);

      expect(
        await subscriptionsModule.getSubscriptionRate(
          giver.profileId,
          creator.profileId,
          vaultId
        )
      ).to.be.equal(rate);
    });

    it("Should return the right giver flow", async () => {
      const { balancesModule, giver, vaultId, rate, feeRate } =
        await loadFixture(subscribeFixture);

      // Negative flow because balance is decreasing
      const flow = -rate.add(feeRate);

      expect(
        await balancesModule.getFlow(giver.profileId, vaultId)
      ).to.be.equal(flow);
    });

    it("Should return the right creator flow", async () => {
      const { balancesModule, creator, vaultId, rate } = await loadFixture(
        subscribeFixture
      );

      expect(
        await balancesModule.getFlow(creator.profileId, vaultId)
      ).to.be.equal(rate);
    });

    it("Should return the right treasury flow", async () => {
      const { balancesModule, treasuryId, vaultId, feeRate } =
        await loadFixture(subscribeFixture);

      expect(await balancesModule.getFlow(treasuryId, vaultId)).to.be.equal(
        feeRate
      );
    });

    it("Should return that the user is subscribed to the creator", async () => {
      const { subscriptionsModule, giver, creator, vaultId } =
        await loadFixture(subscribeFixture);

      expect(
        await subscriptionsModule.isSubscribe(
          giver.profileId,
          creator.profileId,
          vaultId
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
        subscriptionId,
      } = await loadFixture(subscribeFixture);

      await expect(tx)
        .to.emit(subscriptionsModule, "SubscriptionCreated")
        .withArgs(
          giver.profileId,
          creator.profileId,
          vaultId,
          subscriptionId,
          rate
        );
    });
  });

  describe("Subscription NFT", () => {
    it("Should mint subscription NFT to giver", async () => {
      const { giver, gratefulSubscription, subscriptionId } = await loadFixture(
        subscribeFixture
      );

      expect(await gratefulSubscription.ownerOf(subscriptionId)).to.be.equal(
        giver.address
      );
    });

    it("Should have minted one subscription NFT to giver", async () => {
      const { giver, gratefulSubscription } = await loadFixture(
        subscribeFixture
      );

      expect(await gratefulSubscription.balanceOf(giver.address)).to.be.equal(
        1
      );
    });

    it("Should return the right subscription data from subscription ID", async () => {
      const { subscriptionsModule, subscriptionId, rate, feeRate } =
        await loadFixture(subscribeFixture);

      // Get last timestamp
      const timestamp = await time.latest();

      // Get subscription struct
      const subscription = await subscriptionsModule.getSubscriptionFrom(
        subscriptionId
      );

      // Assert each subscription element
      expect(subscription.rate).to.be.equal(rate);
      expect(subscription.feeRate).to.be.equal(feeRate);
      expect(subscription.lastUpdate).to.be.equal(timestamp);
      expect(subscription.duration).to.be.equal(0);
      expect(subscription.totalRate).to.be.equal(0);
    });
  });
});