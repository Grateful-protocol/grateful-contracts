import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import {
  depositFixture,
  subscribeFixture,
  withdrawFixture,
} from "../fixtures/fixtures";
import { BigNumber } from "ethers";

describe("Grateful", () => {
  describe("Withdraw", () => {
    it("Should update token balances correctly", async () => {
      const { token, giver, tokenBalanceBefore, expectedWithdrawal } =
        await loadFixture(withdrawFixture);

      const delta = ethers.utils.parseUnits("1", 11);

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

      const delta = ethers.utils.parseUnits("1", 11);

      const aprox = (i: BigNumber): boolean => {
        expect(i).to.be.approximately(expectedWithdrawal, delta);
        return true;
      };

      await expect(tx)
        .to.emit(fundsModule, "FundsWithdrawn")
        .withArgs(giver.profileId, vaultId, WITHDRAW_SHARES, aprox);
    });
  });

  describe("Withdraw reverts", () => {
    it("Should revert when withdrawing with zero shares", async () => {
      const { fundsModule, vaultId, giver } = await loadFixture(depositFixture);

      const tx = fundsModule
        .connect(giver.signer)
        .withdrawFunds(giver.profileId, vaultId, 0);

      await expect(tx).to.be.revertedWithCustomError(fundsModule, "ZeroAmount");
    });

    it("Should revert when withdrawing from an invalid vault", async () => {
      const { fundsModule, giver } = await loadFixture(depositFixture);

      const WITHDRAW_AMOUNT = ethers.utils.parseUnits("1", 18);

      const vaultId = ethers.utils.formatBytes32String("invalid-vaultId");

      const tx = fundsModule
        .connect(giver.signer)
        .withdrawFunds(giver.profileId, vaultId, WITHDRAW_AMOUNT);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "InvalidVault"
      );
    });

    it("Should revert when withdrawing from a paused vault", async () => {
      const { fundsModule, vaultId, giver, vaultsModule, owner } =
        await loadFixture(depositFixture);

      const WITHDRAW_AMOUNT = ethers.utils.parseUnits("1", 18);

      await vaultsModule.connect(owner).pauseVault(vaultId);

      const tx = fundsModule
        .connect(giver.signer)
        .withdrawFunds(giver.profileId, vaultId, WITHDRAW_AMOUNT);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "InvalidVault"
      );
    });

    it("Should revert when withdrawing from an inexistence profile", async () => {
      const { fundsModule, vaultId, giver } = await loadFixture(depositFixture);

      const WITHDRAW_AMOUNT = ethers.utils.parseUnits("1", 18);

      const profileId = ethers.utils.formatBytes32String("invalid-profileId");

      const tx = fundsModule
        .connect(giver.signer)
        .withdrawFunds(profileId, vaultId, WITHDRAW_AMOUNT);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "PermissionDenied"
      );
    });

    it("Should revert when withdrawing with not enough balance", async () => {
      const { fundsModule, vault, vaultId, giver } = await loadFixture(
        depositFixture
      );

      const tokenAddress = await vault.asset();
      const token = await ethers.getContractAt("ERC20", tokenAddress);
      const decimals = await token.decimals();
      const WITHDRAW_AMOUNT = ethers.utils.parseUnits("1000", decimals);
      const DECIMALS_DIVISOR = 10 ** (20 - decimals);
      const WITHDRAW_SHARES = WITHDRAW_AMOUNT.mul(DECIMALS_DIVISOR);

      const tx = fundsModule
        .connect(giver.signer)
        .withdrawFunds(giver.profileId, vaultId, WITHDRAW_SHARES);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "InsufficientBalance"
      );
    });

    it("Should revert when withdrawing more than allowed when having open subscriptions", async () => {
      const { fundsModule, vault, vaultId, giver } = await loadFixture(
        subscribeFixture
      );

      const tokenAddress = await vault.asset();
      const token = await ethers.getContractAt("ERC20", tokenAddress);
      const decimals = await token.decimals();
      const WITHDRAW_AMOUNT = ethers.utils.parseUnits("9.9", decimals);
      const DECIMALS_DIVISOR = 10 ** (20 - decimals);
      const WITHDRAW_SHARES = WITHDRAW_AMOUNT.mul(DECIMALS_DIVISOR);

      const tx = fundsModule
        .connect(giver.signer)
        .withdrawFunds(giver.profileId, vaultId, WITHDRAW_SHARES);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "InsolventUser"
      );
    });
  });
});
