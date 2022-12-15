import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { depositFixture } from "../fixtures/fixtures";

describe("Grateful", () => {
  describe("Deposit", () => {
    it("Should update token balances correctly", async () => {
      const { token, giver, balanceBefore, DEPOSIT_AMOUNT } = await loadFixture(
        depositFixture
      );

      expect(await token.balanceOf(giver.address)).to.be.equal(
        balanceBefore.sub(DEPOSIT_AMOUNT)
      );
    });

    it("Should update user balance correctly", async () => {
      const { balancesModule, giver, vaultId, expectedShares } =
        await loadFixture(depositFixture);

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.equal(expectedShares);
    });

    it("Should emit a FundsDeposited event", async () => {
      const {
        tx,
        DEPOSIT_AMOUNT,
        fundsModule,
        giver,
        vaultId,
        expectedShares,
      } = await loadFixture(depositFixture);

      await expect(tx)
        .to.emit(fundsModule, "FundsDeposited")
        .withArgs(giver.profileId, vaultId, DEPOSIT_AMOUNT, expectedShares);
    });
  });
});
