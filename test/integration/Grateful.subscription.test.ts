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
      const subscription = await subscriptionsModule.getSubscriptionFrom(
        giver.profileId,
        creator.profileId
      );

      // Assert each subscription element
      expect(subscription.rate).to.be.equal(rate);
      expect(subscription.feeRate).to.be.equal(feeRate);
      expect(subscription.lastUpdate).to.be.equal(timestamp);
      expect(subscription.duration).to.be.equal(0);
      expect(subscription.creatorId).to.be.equal(creator.profileId);
      expect(subscription.vaultId).to.be.equal(vaultId);
    });

    it("Should return the right subscription rates", async () => {
      const { subscriptionsModule, subscriptionId, rate, feeRate } =
        await loadFixture(subscribeFixture);

      const [currentRate, currentFeeRate] =
        await subscriptionsModule.getSubscriptionRates(subscriptionId);

      expect(currentRate).to.be.equal(rate);
      expect(currentFeeRate).to.be.equal(feeRate);
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
      const { subscriptionsModule, giver, creator } = await loadFixture(
        subscribeFixture
      );

      expect(
        await subscriptionsModule.isSubscribed(
          giver.profileId,
          creator.profileId
        )
      ).to.equal(true);
    });

    it("Should emit a SubscriptionStarted event", async () => {
      const {
        tx,
        subscriptionsModule,
        giver,
        creator,
        vaultId,
        rate,
        feeRate,
        subscriptionId,
      } = await loadFixture(subscribeFixture);

      await expect(tx)
        .to.emit(subscriptionsModule, "SubscriptionStarted")
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
      const {
        subscriptionsModule,
        subscriptionId,
        rate,
        feeRate,
        creator,
        vaultId,
      } = await loadFixture(subscribeFixture);

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
      expect(subscription.duration).to.be.equal(0);
      expect(subscription.creatorId).to.be.equal(creator.profileId);
      expect(subscription.vaultId).to.be.equal(vaultId);
    });
  });
});
