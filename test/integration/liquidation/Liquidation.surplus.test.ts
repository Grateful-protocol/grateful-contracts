import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { liquidateSurplusFixture } from "../../fixtures/fixtures";

describe("Liquidation", () => {
  describe("Liquidate subscription with negative balance", () => {
    it("Should return giver balance correctly", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        liquidateSurplusFixture
      );

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.equal(0);
    });

    it("Should return creator balance correctly", async () => {
      const {
        balancesModule,
        creator,
        vaultId,
        creatorBalance,
        creatorFlow,
        rate,
        surplus,
        giverFlow,
      } = await loadFixture(liquidateSurplusFixture);

      const discountedSurplus = rate.mul(surplus).div(giverFlow).abs();

      // Add flow after tx
      const currentBalance = creatorBalance
        .add(creatorFlow)
        .sub(discountedSurplus);

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
        feeRate,
        surplus,
        giverFlow,
      } = await loadFixture(liquidateSurplusFixture);

      const discountedSurplus = feeRate.mul(surplus).div(giverFlow).abs();

      // Add flow after tx
      const currentBalance = treasuryBalance
        .add(treasuryFlow)
        .sub(discountedSurplus);

      expect(await balancesModule.balanceOf(treasuryId, vaultId)).to.be.equal(
        currentBalance
      );
    });

    // @audit test with rewards
    // it("Should return liquidator balance correctly", async () => {
    //   const { balancesModule, liquidatorId, vaultId } = await loadFixture(
    //     liquidateSurplusFixture
    //   );

    //   expect(await balancesModule.balanceOf(liquidatorId, vaultId)).to.be.equal(
    //     0
    //   );
    // });

    it("Should return that the user cannot be liquidated", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        liquidateSurplusFixture
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
        liquidateSurplusFixture
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
      } = await loadFixture(liquidateSurplusFixture);

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
        surplus,
        owner,
      } = await loadFixture(liquidateSurplusFixture);

      await expect(tx)
        .to.emit(liquidationsModule, "SubscriptionLiquidated")
        .withArgs(
          giver.profileId,
          creator.profileId,
          owner.address,
          vaultId,
          subscriptionId,
          surplus
        );
    });
  });
});
