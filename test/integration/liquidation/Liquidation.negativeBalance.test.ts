import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { advanceToNegativeBalanceFixture } from "../../fixtures/fixtures";

describe("Liquidation", () => {
  describe("Advance time to negative balance", () => {
    it("Should return giver balance correctly", async () => {
      const {
        balancesModule,
        giver,
        vaultId,
        giverBalance,
        giverFlow,
        elapsedTime,
      } = await loadFixture(advanceToNegativeBalanceFixture);

      const totalFlow = giverFlow.mul(elapsedTime);
      const currentBalance = giverBalance.add(totalFlow);

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.equal(currentBalance);
    });

    it("Should return that the user can be liquidated", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        advanceToNegativeBalanceFixture
      );

      expect(
        await balancesModule.canBeLiquidated(giver.profileId, vaultId)
      ).to.equal(true);
    });

    // @audit test with rewards
    // it("returns that the liquidation reward is zero", async () => {
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
        advanceToNegativeBalanceFixture
      );

      expect(
        await balancesModule.getRemainingTimeToZero(giver.profileId, vaultId)
      ).to.equal(0);
    });
  });
});
