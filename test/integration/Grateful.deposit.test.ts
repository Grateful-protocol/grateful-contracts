import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { depositFixture } from "../fixtures/fixtures";
import { deposit } from "../fixtures/utils/deposit";
import { BigNumber } from "ethers";

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

  describe("Dobule deposit", () => {
    const doubleDepositFixture = async () => {
      const fixture = await loadFixture(depositFixture);
      return deposit(fixture);
    };

    const delta = ethers.utils.parseUnits("1", 14);

    it("Should update token balances correctly", async () => {
      const { token, giver, balanceBefore, DEPOSIT_AMOUNT } = await loadFixture(
        doubleDepositFixture
      );

      expect(await token.balanceOf(giver.address)).to.be.equal(
        balanceBefore.sub(DEPOSIT_AMOUNT)
      );
    });

    it("Should update user balance correctly", async () => {
      const {
        balancesModule,
        giver,
        vaultId,
        expectedShares,
        gratefulBalanceBefore,
      } = await loadFixture(doubleDepositFixture);

      const newBalance = gratefulBalanceBefore.add(expectedShares);

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.approximately(newBalance, delta);
    });

    it("Should emit a FundsDeposited event", async () => {
      const {
        tx,
        DEPOSIT_AMOUNT,
        fundsModule,
        giver,
        vaultId,
        expectedShares,
      } = await loadFixture(doubleDepositFixture);

      const aprox = (i: BigNumber): boolean => {
        expect(i).to.be.approximately(expectedShares, delta);
        return true;
      };

      await expect(tx)
        .to.emit(fundsModule, "FundsDeposited")
        .withArgs(giver.profileId, vaultId, DEPOSIT_AMOUNT, aprox);
    });
  });
});
