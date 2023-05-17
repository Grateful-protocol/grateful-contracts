import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySystemFixture } from "../../../fixtures/fixtures";
import { ethers } from "hardhat";

const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

describe("Vaults", () => {
  const emptyBytes = ethers.utils.formatBytes32String("");

  it("Should return the correct implementation address", async () => {
    const { vaultsModule, vault, vaultId } = await loadFixture(
      deploySystemFixture
    );

    const impl = await vaultsModule.getVault(vaultId);

    expect(impl).to.be.equal(vault.address);
  });

  it("Should set the new minimum rate", async () => {
    const { vaultsModule, owner, vaultId } = await loadFixture(
      deploySystemFixture
    );

    const newMinRate = 10;

    const tx = vaultsModule.connect(owner).setMinRate(vaultId, newMinRate);

    await expect(tx)
      .to.emit(vaultsModule, "MinRateChanged")
      .withArgs(vaultId, anyValue, newMinRate);
  });

  it("Should set the new maximum rate", async () => {
    const { vaultsModule, owner, vaultId } = await loadFixture(
      deploySystemFixture
    );

    const newMaxRate = 10;

    const tx = vaultsModule.connect(owner).setMaxRate(vaultId, newMaxRate);

    await expect(tx)
      .to.emit(vaultsModule, "MaxRateChanged")
      .withArgs(vaultId, anyValue, newMaxRate);
  });

  it("Should deprecate a vault", async () => {
    const { vaultsModule, owner, vaultId } = await loadFixture(
      deploySystemFixture
    );

    const tx = vaultsModule.connect(owner).deprecateVault(vaultId);

    await expect(tx).to.emit(vaultsModule, "VaultDeprecated").withArgs(vaultId);
  });

  it("Should activate a vault", async () => {
    const { vaultsModule, owner, vaultId } = await loadFixture(
      deploySystemFixture
    );

    const tx = vaultsModule.connect(owner).activateVault(vaultId);

    await expect(tx).to.emit(vaultsModule, "VaultActivated").withArgs(vaultId);
  });

  it("Should pause a vault", async () => {
    const { vaultsModule, owner, vaultId } = await loadFixture(
      deploySystemFixture
    );

    const tx = vaultsModule.connect(owner).pauseVault(vaultId);

    await expect(tx).to.emit(vaultsModule, "VaultPaused").withArgs(vaultId);
  });

  it("Should unpause a vault", async () => {
    const { vaultsModule, owner, vaultId } = await loadFixture(
      deploySystemFixture
    );

    const tx = vaultsModule.connect(owner).unpauseVault(vaultId);

    await expect(tx).to.emit(vaultsModule, "VaultUnpaused").withArgs(vaultId);
  });

  it("Should revert when calling write functions without the owner", async () => {
    const { vaultsModule, giver } = await loadFixture(deploySystemFixture);

    const addTx = vaultsModule
      .connect(giver.signer)
      .addVault(emptyBytes, ethers.constants.AddressZero, 0, 0);

    const minTx = vaultsModule.connect(giver.signer).setMinRate(emptyBytes, 0);

    const maxTx = vaultsModule.connect(giver.signer).setMaxRate(emptyBytes, 0);

    const deprecateTx = vaultsModule
      .connect(giver.signer)
      .deprecateVault(emptyBytes);

    const activateTx = vaultsModule
      .connect(giver.signer)
      .activateVault(emptyBytes);

    const pauseTx = vaultsModule.connect(giver.signer).pauseVault(emptyBytes);

    const unpauseTx = vaultsModule
      .connect(giver.signer)
      .unpauseVault(emptyBytes);

    await expect(addTx).to.be.revertedWithCustomError(
      vaultsModule,
      "Unauthorized"
    );

    await expect(minTx).to.be.revertedWithCustomError(
      vaultsModule,
      "Unauthorized"
    );

    await expect(maxTx).to.be.revertedWithCustomError(
      vaultsModule,
      "Unauthorized"
    );

    await expect(deprecateTx).to.be.revertedWithCustomError(
      vaultsModule,
      "Unauthorized"
    );

    await expect(activateTx).to.be.revertedWithCustomError(
      vaultsModule,
      "Unauthorized"
    );

    await expect(pauseTx).to.be.revertedWithCustomError(
      vaultsModule,
      "Unauthorized"
    );

    await expect(unpauseTx).to.be.revertedWithCustomError(
      vaultsModule,
      "Unauthorized"
    );
  });

  it("Should revert when adding a vault again", async () => {
    const { vaultsModule, vaultId, owner, giver } = await loadFixture(
      deploySystemFixture
    );

    const anyAddress = giver.address;

    const tx = vaultsModule.connect(owner).addVault(vaultId, anyAddress, 0, 0);

    await expect(tx).to.be.revertedWithCustomError(
      vaultsModule,
      "AlreadyInitialized"
    );
  });

  it("Should revert when adding a vault with zero ID", async () => {
    const { vaultsModule, owner, giver } = await loadFixture(
      deploySystemFixture
    );

    const anyAddress = giver.address;

    const tx = vaultsModule
      .connect(owner)
      .addVault(emptyBytes, anyAddress, 0, 0);

    await expect(tx).to.be.revertedWithCustomError(vaultsModule, "ZeroId");
  });

  it("Should revert when adding a vault with zero address", async () => {
    const { vaultsModule, vaultId, owner } = await loadFixture(
      deploySystemFixture
    );

    const tx = vaultsModule
      .connect(owner)
      .addVault(vaultId, ethers.constants.AddressZero, 0, 0);

    await expect(tx).to.be.revertedWithCustomError(vaultsModule, "ZeroAddress");
  });

  it("Should revert when calling write functions without initializing the vault", async () => {
    const { vaultsModule, owner } = await loadFixture(deploySystemFixture);

    const minTx = vaultsModule.connect(owner).setMinRate(emptyBytes, 0);

    const maxTx = vaultsModule.connect(owner).setMaxRate(emptyBytes, 0);

    const deprecateTx = vaultsModule.connect(owner).deprecateVault(emptyBytes);

    const activateTx = vaultsModule.connect(owner).activateVault(emptyBytes);

    const pauseTx = vaultsModule.connect(owner).pauseVault(emptyBytes);

    const unpauseTx = vaultsModule.connect(owner).unpauseVault(emptyBytes);

    await expect(minTx).to.be.revertedWithCustomError(
      vaultsModule,
      "VaultNotInitialized"
    );

    await expect(maxTx).to.be.revertedWithCustomError(
      vaultsModule,
      "VaultNotInitialized"
    );

    await expect(deprecateTx).to.be.revertedWithCustomError(
      vaultsModule,
      "VaultNotInitialized"
    );

    await expect(activateTx).to.be.revertedWithCustomError(
      vaultsModule,
      "VaultNotInitialized"
    );

    await expect(pauseTx).to.be.revertedWithCustomError(
      vaultsModule,
      "VaultNotInitialized"
    );

    await expect(unpauseTx).to.be.revertedWithCustomError(
      vaultsModule,
      "VaultNotInitialized"
    );
  });
});
