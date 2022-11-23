import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { deployCompleteSystem, depositFixture } from "./fixtures";

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

    it("emits a FundsDeposited event", async () => {
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
