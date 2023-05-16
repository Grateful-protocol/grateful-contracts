import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deploySystemFixture, depositFixture } from "../fixtures/fixtures";
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

  describe("Deposit reverts", () => {
    it("Should revert when depositing with zero amount ", async () => {
      const { fundsModule, vaultId, giver } = await loadFixture(
        deploySystemFixture
      );

      const tx = fundsModule
        .connect(giver.signer)
        .depositFunds(giver.profileId, vaultId, 0);

      await expect(tx).to.be.revertedWithCustomError(fundsModule, "ZeroAmount");
    });

    it("Should revert when depositing to an invalid vault", async () => {
      const { fundsModule, giver } = await loadFixture(deploySystemFixture);

      const DEPOSIT_AMOUNT = ethers.utils.parseUnits("1", 18);

      const vaultId = ethers.utils.formatBytes32String("invalid-vaultId");

      const tx = fundsModule
        .connect(giver.signer)
        .depositFunds(giver.profileId, vaultId, DEPOSIT_AMOUNT);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "InvalidVault"
      );
    });

    it("Should revert when depositing to a paused vault", async () => {
      const { fundsModule, vaultId, giver, vaultsModule, owner } =
        await loadFixture(deploySystemFixture);

      const DEPOSIT_AMOUNT = ethers.utils.parseUnits("1", 18);

      await vaultsModule.connect(owner).pauseVault(vaultId);

      const tx = fundsModule
        .connect(giver.signer)
        .depositFunds(giver.profileId, vaultId, DEPOSIT_AMOUNT);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "InvalidVault"
      );
    });

    it("Should revert when depositing to a deprecated vault", async () => {
      const { fundsModule, vaultId, giver, vaultsModule, owner } =
        await loadFixture(deploySystemFixture);

      const DEPOSIT_AMOUNT = ethers.utils.parseUnits("1", 18);

      await vaultsModule.connect(owner).deprecateVault(vaultId);

      const tx = fundsModule
        .connect(giver.signer)
        .depositFunds(giver.profileId, vaultId, DEPOSIT_AMOUNT);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "InvalidVault"
      );
    });

    it("Should revert when depositing to a inexistent profile", async () => {
      const { fundsModule, vaultId, giver } = await loadFixture(
        deploySystemFixture
      );

      const DEPOSIT_AMOUNT = ethers.utils.parseUnits("1", 18);

      const profileId = ethers.utils.formatBytes32String("invalid-profileId");

      const tx = fundsModule
        .connect(giver.signer)
        .depositFunds(profileId, vaultId, DEPOSIT_AMOUNT);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "ProfileNotFound"
      );
    });

    it("Should revert when depositing with insufficient allowance", async () => {
      const { fundsModule, vault, vaultId, giver } = await loadFixture(
        deploySystemFixture
      );

      const tokenAddress = await vault.asset();
      const token = await ethers.getContractAt("ERC20", tokenAddress);
      const decimals = await token.decimals();
      const DEPOSIT_AMOUNT = ethers.utils.parseUnits("1", decimals);

      const tx = fundsModule
        .connect(giver.signer)
        .depositFunds(giver.profileId, vaultId, DEPOSIT_AMOUNT);

      await expect(tx).to.be.revertedWithCustomError(
        fundsModule,
        "InsufficientAllowance"
      );
    });
  });
});
