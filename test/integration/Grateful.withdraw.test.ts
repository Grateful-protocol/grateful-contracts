import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { withdrawFixture } from "../fixtures/fixtures";
import { BigNumber } from "ethers";

describe("Grateful", () => {
  describe("Withdraw", () => {
    it("Should update token balances correctly", async () => {
      const { token, giver, tokenBalanceBefore, expectedWithdrawal } =
        await loadFixture(withdrawFixture);

      const delta = ethers.utils.parseUnits("1", 10);

      expect(await token.balanceOf(giver.address)).to.be.approximately(
        tokenBalanceBefore.add(expectedWithdrawal),
        delta
      );
    });

    it("Should update user balance correctly", async () => {
      const {
        balancesModule,
        giver,
        vaultId,
        gratefulBalanceBefore,
        WITHDRAW_SHARES,
      } = await loadFixture(withdrawFixture);

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.equal(gratefulBalanceBefore.sub(WITHDRAW_SHARES));
    });

    it("Should emit a FundsWithdrawn event", async () => {
      const {
        tx,
        WITHDRAW_SHARES,
        fundsModule,
        giver,
        vaultId,
        expectedWithdrawal,
      } = await loadFixture(withdrawFixture);

      const delta = ethers.utils.parseUnits("1", 10);

      const aprox = (i: BigNumber): boolean => {
        expect(i).to.be.approximately(expectedWithdrawal, delta);
        return true;
      };

      await expect(tx)
        .to.emit(fundsModule, "FundsWithdrawn")
        .withArgs(giver.profileId, vaultId, WITHDRAW_SHARES, aprox);
    });
  });
});
