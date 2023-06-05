import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { liquidateFixture } from "../../fixtures/fixtures";

describe("Liquidation", () => {
  describe("Liquidate subscription", () => {
    it("Should return giver balance correctly", async () => {
      const { balancesModule, giver, vaultId, giverBalance, giverFlow } =
        await loadFixture(liquidateFixture);

      // Add flow after tx
      const currentBalance = giverBalance.add(giverFlow);

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.equal(currentBalance);
    });

    it("Should return creator balance correctly", async () => {
      const { balancesModule, creator, vaultId, creatorBalance, creatorFlow } =
        await loadFixture(liquidateFixture);

      // Add flow after tx
      const currentBalance = creatorBalance.add(creatorFlow);

      expect(
        await balancesModule.balanceOf(creator.profileId, vaultId)
      ).to.be.equal(currentBalance);
    });

    it("Should return treasury balance correctly", async () => {
      const {
        balancesModule,
        treasuryId,
        vaultId,
        treasuryBalance,
        treasuryFlow,
      } = await loadFixture(liquidateFixture);

      // Add flow after tx
      const currentBalance = treasuryBalance.add(treasuryFlow);

      expect(await balancesModule.balanceOf(treasuryId, vaultId)).to.be.equal(
        currentBalance
      );
    });

    // @audit test with rewards
    // it("Should return liquidator balance correctly", async () => {
    //   const { balancesModule, liquidatorId, vaultId } = await loadFixture(
    //     liquidateFixture
    //   );

    //   expect(await balancesModule.balanceOf(liquidatorId, vaultId)).to.be.equal(
    //     0
    //   );
    // });

    it("Should return that the user cannot be liquidated", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        liquidateFixture
      );

      expect(
        await balancesModule.canBeLiquidated(giver.profileId, vaultId)
      ).to.equal(false);
    });

    // @audit test with rewards
    // it("returns the liquidation reward correctly", async () => {
    //   expect(
    //     await grateful.getSubscriptionLiquidationReward(
    //       giverId,
    //       creatorId,
    //       adapterId
    //     )
    //   ).to.equal(0);
    // });

    it("Should return the remaining time for the user correctly", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        liquidateFixture
      );

      expect(
        await balancesModule.getRemainingTimeToZero(giver.profileId, vaultId)
      ).to.equal(0);
    });

    it("Should emit a SubscriptionFinished event", async () => {
      const {
        tx,
        liquidationsModule,
        giver,
        creator,
        vaultId,
        subscriptionId,
        rate,
        feeRate,
      } = await loadFixture(liquidateFixture);

      await expect(tx)
        .to.emit(liquidationsModule, "SubscriptionFinished")
        .withArgs(
          giver.profileId,
          creator.profileId,
          vaultId,
          subscriptionId,
          rate,
          feeRate
        );
    });

    it("Should emit a SubscriptionLiquidated event", async () => {
      const {
        tx,
        liquidationsModule,
        giver,
        creator,
        vaultId,
        subscriptionId,
      } = await loadFixture(liquidateFixture);

      await expect(tx)
        .to.emit(liquidationsModule, "SubscriptionLiquidated")
        .withArgs(
          giver.profileId,
          creator.profileId,
          vaultId,
          subscriptionId,
          0,
          0
        );
    });
  });
});
