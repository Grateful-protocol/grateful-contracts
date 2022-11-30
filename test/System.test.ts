import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import {
  deployCompleteSystem,
  depositFixture,
  withdrawFixture,
} from "./fixtures";
import { BigNumber } from "ethers";

describe("System", () => {
  describe("Deployment", () => {
    it("Should be initialized", async () => {
      const { ownerModule } = await loadFixture(deployCompleteSystem);

      expect(await ownerModule.isOwnerModuleInitialized()).to.equal(true);
    });

    it("Should set the right owner", async () => {
      const { ownerModule, owner } = await loadFixture(deployCompleteSystem);

      expect(await ownerModule.owner()).to.equal(owner.address);
    });

    it("Should set the right vault", async () => {
      const { vaultsModule, vaultId, vault } = await loadFixture(
        deployCompleteSystem
      );

      expect(await vaultsModule.getVault(vaultId)).to.equal(vault.address);
    });

    it("Should set grateful profile allowed", async () => {
      const { profileModule, gratefulProfile } = await loadFixture(
        deployCompleteSystem
      );

      expect(await profileModule.isProfileAllowed(gratefulProfile.address)).to
        .be.true;
    });

    it("Should mint grateful profile to user correctly", async () => {
      const { gratefulProfile, giver } = await loadFixture(
        deployCompleteSystem
      );

      expect(await gratefulProfile.ownerOf(giver.tokenId)).to.be.equal(
        giver.address
      );
    });

    it("Should not have user balance into grateful", async () => {
      const { balancesModule, giver, vaultId } = await loadFixture(
        deployCompleteSystem
      );

      expect(
        await balancesModule.balanceOf(giver.profileId, vaultId)
      ).to.be.equal(0);
    });
  });

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
