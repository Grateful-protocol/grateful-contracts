import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { advanceToLiquidationTimeFixture } from "../../fixtures/fixtures";

describe("Liquidation", () => {
  describe("Advance time to liquidation period", () => {
    it("Should return that the user can be liquidated", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        advanceToLiquidationTimeFixture
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
      const { balancesModule, giver, vaultId, liquidationTimeRequired } =
        await loadFixture(advanceToLiquidationTimeFixture);

      expect(
        await balancesModule.getRemainingTimeToZero(giver.profileId, vaultId)
      ).to.equal(liquidationTimeRequired.sub(1));
    });
  });
});
