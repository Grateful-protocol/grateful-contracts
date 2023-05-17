import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySystemFixture } from "../../../fixtures/fixtures";
import { ethers } from "hardhat";

describe("Fees", () => {
  const emptyBytes = ethers.utils.formatBytes32String("");

  it("Should set the new grateful treasury", async () => {
    const { feesModule, owner } = await loadFixture(deploySystemFixture);

    const treasury = ethers.utils.formatBytes32String("grateful treasury");

    await feesModule.connect(owner).setGratefulFeeTreasury(treasury);

    expect(await feesModule.getFeeTreasuryId()).to.be.equal(treasury);
  });

  it("Should set the new fee percentage", async () => {
    const { feesModule, owner } = await loadFixture(deploySystemFixture);

    const feePercentage = 0;

    await feesModule.connect(owner).setFeePercentage(feePercentage);

    expect(await feesModule.getFeePercentage()).to.be.equal(feePercentage);
  });

  it("Should revert when calling write functions without the owner", async () => {
    const { feesModule, giver } = await loadFixture(deploySystemFixture);

    const initTx = feesModule
      .connect(giver.signer)
      .initializeFeesModule(emptyBytes, 0);

    const solvencyTx = feesModule
      .connect(giver.signer)
      .setGratefulFeeTreasury(emptyBytes);

    const liquidationTx = feesModule.connect(giver.signer).setFeePercentage(0);

    await expect(initTx).to.be.revertedWithCustomError(
      feesModule,
      "Unauthorized"
    );

    await expect(solvencyTx).to.be.revertedWithCustomError(
      feesModule,
      "Unauthorized"
    );

    await expect(liquidationTx).to.be.revertedWithCustomError(
      feesModule,
      "Unauthorized"
    );
  });

  it("Should revert when initializing module again", async () => {
    const { feesModule, owner } = await loadFixture(deploySystemFixture);

    const treasury = ethers.utils.formatBytes32String("grateful treasury");
    const feePercentage = 0;

    const tx = feesModule
      .connect(owner)
      .initializeFeesModule(treasury, feePercentage);

    await expect(tx).to.be.revertedWithCustomError(
      feesModule,
      "AlreadyInitialized"
    );
  });

  it("Should revert when initializing module with empty treasury ID", async () => {
    const { feesModule, owner } = await loadFixture(deploySystemFixture);

    const tx = feesModule.connect(owner).initializeFeesModule(emptyBytes, 0);

    await expect(tx).to.be.revertedWithCustomError(feesModule, "ZeroId");
  });

  it("Should revert when setting empty treasury ID", async () => {
    const { feesModule, owner } = await loadFixture(deploySystemFixture);

    const tx = feesModule.connect(owner).setGratefulFeeTreasury(emptyBytes);

    await expect(tx).to.be.revertedWithCustomError(feesModule, "ZeroId");
  });
});
