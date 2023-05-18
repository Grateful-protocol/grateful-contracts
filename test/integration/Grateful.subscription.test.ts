import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { BigNumber, utils } from "ethers";
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

    describe("when a giver try to subscribe with an invactive vault", () => {
      it("reverts", async () => {
        const { subscriptionsModule, giver, creator, SUBSCRIPTION_RATE } =
          await loadFixture(subscribeFixture);

        const vaultId = utils.formatBytes32String("invalid-vaultId");

        const tx = subscriptionsModule
          .connect(giver.signer)
          .subscribe(
            giver.profileId,
            creator.profileId,
            vaultId,
            SUBSCRIPTION_RATE
          );

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "InvalidVault"
        );
      });
    });

    describe("when a giver try to subscribe from a profile without permissions", () => {
      it("reverts", async () => {
        const {
          subscriptionsModule,
          giver,
          creator,
          vaultId,
          SUBSCRIPTION_RATE,
        } = await loadFixture(subscribeFixture);

        const tx = subscriptionsModule
          .connect(creator.signer)
          .subscribe(
            giver.profileId,
            creator.profileId,
            vaultId,
            SUBSCRIPTION_RATE
          );

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "PermissionDenied"
        );
      });
    });

    describe("when a giver try to subscribe to an inexistent profile", () => {
      it("reverts", async () => {
        const { subscriptionsModule, giver, vaultId, SUBSCRIPTION_RATE } =
          await loadFixture(subscribeFixture);

        const invalidProfileId = utils.formatBytes32String("invalid-profileId");

        const tx = subscriptionsModule
          .connect(giver.signer)
          .subscribe(
            giver.profileId,
            invalidProfileId,
            vaultId,
            SUBSCRIPTION_RATE
          );

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "ProfileNotFound"
        );
      });
    });

    describe("when a giver try to subscribe to an invalid creator", () => {
      it("reverts", async () => {
        const { subscriptionsModule, giver, vaultId, SUBSCRIPTION_RATE } =
          await loadFixture(subscribeFixture);

        const tx = subscriptionsModule
          .connect(giver.signer)
          .subscribe(
            giver.profileId,
            giver.profileId,
            vaultId,
            SUBSCRIPTION_RATE
          );

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "InvalidCreator"
        );
      });

      it("reverts", async () => {
        const {
          subscriptionsModule,
          giver,
          treasuryId,
          vaultId,
          SUBSCRIPTION_RATE,
        } = await loadFixture(subscribeFixture);

        const tx = subscriptionsModule
          .connect(giver.signer)
          .subscribe(giver.profileId, treasuryId, vaultId, SUBSCRIPTION_RATE);

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "InvalidCreator"
        );
      });
    });

    describe("when a giver try to subscribe to a creator already subscribed", () => {
      it("reverts", async () => {
        const {
          subscriptionsModule,
          giver,
          creator,
          vaultId,
          SUBSCRIPTION_RATE,
        } = await loadFixture(subscribeFixture);

        const tx = subscriptionsModule
          .connect(giver.signer)
          .subscribe(
            giver.profileId,
            creator.profileId,
            vaultId,
            SUBSCRIPTION_RATE
          );

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "AlreadySubscribed"
        );
      });
    });

    describe("when a giver try to subscribe to a creator with an invalid rate", () => {
      it("reverts", async () => {
        const { subscriptionsModule, creator, vaultId, owner, treasuryId } =
          await loadFixture(subscribeFixture);

        const tx = subscriptionsModule
          .connect(owner)
          .subscribe(treasuryId, creator.profileId, vaultId, 0);

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "InvalidRate"
        );
      });
    });

    describe("when a giver try to subscribe to a creator with a rate that make it insolvent", () => {
      it("reverts", async () => {
        const {
          subscriptionsModule,
          creator,
          vaultId,
          owner,
          treasuryId,
          SUBSCRIPTION_RATE,
        } = await loadFixture(subscribeFixture);

        const bigRate = BigNumber.from(SUBSCRIPTION_RATE).mul(100);

        const tx = subscriptionsModule
          .connect(owner)
          .subscribe(treasuryId, creator.profileId, vaultId, bigRate);

        await expect(tx).to.be.revertedWithCustomError(
          subscriptionsModule,
          "InsolventUser"
        );
      });
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
