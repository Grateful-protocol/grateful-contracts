import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { unsubscribeFixture } from "../fixtures/fixtures";
import { utils } from "ethers";

describe("Grateful", () => {
  describe("Unsubscription", () => {
    it("Should return the right subscription data", async () => {
      const {
        subscriptionsModule,
        subscriptionId,
        duration,
        creator,
        vaultId,
      } = await loadFixture(unsubscribeFixture);

      // Get last timestamp
      const timestamp = await time.latest();

      // Get subscription struct
      const subscription = await subscriptionsModule.getSubscription(
        subscriptionId
      );

      // Assert each subscription element
      expect(subscription.rate).to.be.equal(0);
      expect(subscription.feeRate).to.be.equal(0);
      expect(subscription.lastUpdate).to.be.equal(timestamp);
      expect(subscription.duration).to.be.equal(duration.add(1));
      expect(subscription.creatorId).to.be.equal(creator.profileId);
      expect(subscription.vaultId).to.be.equal(vaultId);
    });

    it("Should return the right subscription rate", async () => {
      const { subscriptionsModule, subscriptionId } = await loadFixture(
        unsubscribeFixture
      );

      const [currentRate, currentFeeRate] =
        await subscriptionsModule.getSubscriptionRates(subscriptionId);

      expect(currentRate).to.be.equal(0);
      expect(currentFeeRate).to.be.equal(0);
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
        await subscriptionsModule.isSubscribed(
          giver.profileId,
          creator.profileId
        )
      ).to.equal(false);
    });

    it("Should emit a SubscriptionFinished event", async () => {
      const {
        tx,
        subscriptionsModule,
        giver,
        creator,
        vaultId,
        rate,
        feeRate,
        subscriptionId,
      } = await loadFixture(unsubscribeFixture);

      await expect(tx)
        .to.emit(subscriptionsModule, "SubscriptionFinished")
        .withArgs(
          giver.profileId,
          creator.profileId,
          vaultId,
          subscriptionId,
          rate,
          feeRate
        );
    });

    describe("when a giver try to unsubscribe from a profile without permissions", () => {
      it("reverts", async () => {
        const { subscriptionsModule, giver, creator } = await loadFixture(
          unsubscribeFixture
        );

        const tx = subscriptionsModule
          .connect(creator.signer)
          .unsubscribe(giver.profileId, creator.profileId);

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "PermissionDenied"
        );
      });
    });

    describe("when a giver try to unsubscribe from an inexistent profile", () => {
      it("reverts", async () => {
        const { subscriptionsModule, giver, creator } = await loadFixture(
          unsubscribeFixture
        );

        const invalidProfileId = utils.formatBytes32String("invalid-profileId");

        const tx = subscriptionsModule
          .connect(giver.signer)
          .unsubscribe(giver.profileId, invalidProfileId);

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "ProfileNotFound"
        );
      });
    });

    describe("when a giver try to unsubscribe to an invalid creator", () => {
      it("reverts", async () => {
        const { subscriptionsModule, giver } = await loadFixture(
          unsubscribeFixture
        );

        const tx = subscriptionsModule
          .connect(giver.signer)
          .unsubscribe(giver.profileId, giver.profileId);

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "InvalidCreator"
        );
      });

      it("reverts", async () => {
        const { subscriptionsModule, giver, treasuryId } = await loadFixture(
          unsubscribeFixture
        );

        const tx = subscriptionsModule
          .connect(giver.signer)
          .unsubscribe(giver.profileId, treasuryId);

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "InvalidCreator"
        );
      });
    });

    describe("when a giver try to unsubscribe to a creator already unsubscribed", () => {
      it("reverts", async () => {
        const { subscriptionsModule, giver, creator } = await loadFixture(
          unsubscribeFixture
        );

        const tx = subscriptionsModule
          .connect(giver.signer)
          .unsubscribe(giver.profileId, creator.profileId);

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "NotSubscribed"
        );
      });
    });
  });
});
