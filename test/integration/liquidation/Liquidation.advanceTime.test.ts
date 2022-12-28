import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { advanceTimeFixture } from "../../fixtures/fixtures";

describe("Liquidation", () => {
  describe("Advance time while having an open subscription for not too long", () => {
    it("Should return that the user cannot be liquidated", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        advanceTimeFixture
      );

      expect(
        await balancesModule.canBeLiquidated(giver.profileId, vaultId)
      ).to.equal(false);
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
      const { balancesModule, giver, vaultId, giverTimeLeft, TIME } =
        await loadFixture(advanceTimeFixture);

      const currentTimeLeft = giverTimeLeft.sub(TIME);

      expect(
        await balancesModule.getRemainingTimeToZero(giver.profileId, vaultId)
      ).to.equal(currentTimeLeft);
    });
  });
});
