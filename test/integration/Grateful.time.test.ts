import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { advanceTimeFixture } from "../fixtures/fixtures";

describe("Grateful", () => {
  describe("Advance time", () => {
    it("Should return the right giver balance", async () => {
      const { balancesModule, giver, vaultId, giverBalance, giverFlow, TIME } =
        await loadFixture(advanceTimeFixture);

      const totalFlow = giverFlow.mul(TIME);
      const newBalance = giverBalance.add(totalFlow);

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.equal(newBalance);
    });

    it("Should return the right creator balance", async () => {
      const {
        balancesModule,
        creator,
        vaultId,
        creatorBalance,
        creatorFlow,
        TIME,
      } = await loadFixture(advanceTimeFixture);

      const totalFlow = creatorFlow.mul(TIME);
      const newBalance = creatorBalance.add(totalFlow);

      expect(
        await balancesModule.balanceOf(creator.profileId, vaultId)
      ).to.be.equal(newBalance);
    });

    it("Should return the right treasury balance", async () => {
      const {
        balancesModule,
        treasuryId,
        vaultId,
        treasuryBalance,
        treasuryFlow,
        TIME,
      } = await loadFixture(advanceTimeFixture);

      const totalFlow = treasuryFlow.mul(TIME);
      const newBalance = treasuryBalance.add(totalFlow);

      expect(await balancesModule.balanceOf(treasuryId, vaultId)).to.be.equal(
        newBalance
      );
    });
  });
});
