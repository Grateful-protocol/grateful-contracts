import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySystemFixture } from "../../fixtures/fixtures";

describe("Config", () => {
  it("Should set the new solvency time", async () => {
    const { configModule, owner } = await loadFixture(deploySystemFixture);

    const newSolvencyTime = 1;

    await configModule.connect(owner).setSolvencyTimeRequired(newSolvencyTime);

    expect(await configModule.getSolvencyTimeRequired()).to.be.equal(
      newSolvencyTime
    );
  });

  it("Should set the new liquidation time", async () => {
    const { configModule, owner } = await loadFixture(deploySystemFixture);

    const newLiquidationTime = 1;

    await configModule
      .connect(owner)
      .setLiquidationTimeRequired(newLiquidationTime);

    expect(await configModule.getLiquidationTimeRequired()).to.be.equal(
      newLiquidationTime
    );
  });

  it("Should revert when calling write functions without the owner", async () => {
    const { configModule, giver } = await loadFixture(deploySystemFixture);

    const initTx = configModule
      .connect(giver.signer)
      .initializeConfigModule(0, 0);

    const solvencyTx = configModule
      .connect(giver.signer)
      .setSolvencyTimeRequired(0);

    const liquidationTx = configModule
      .connect(giver.signer)
      .setLiquidationTimeRequired(0);

    await expect(initTx).to.be.revertedWithCustomError(
      configModule,
      "Unauthorized"
    );

    await expect(solvencyTx).to.be.revertedWithCustomError(
      configModule,
      "Unauthorized"
    );

    await expect(liquidationTx).to.be.revertedWithCustomError(
      configModule,
      "Unauthorized"
    );
  });

  it("Should revert when initializing config module again", async () => {
    const { configModule, owner } = await loadFixture(deploySystemFixture);

    const solvencyTime = 604800;
    const liquidationTime = 259200;

    const tx = configModule
      .connect(owner)
      .initializeConfigModule(solvencyTime, liquidationTime);

    await expect(tx).to.be.revertedWithCustomError(
      configModule,
      "AlreadyInitialized"
    );
  });

  it("Should revert when initializing config module with zero times", async () => {
    const { configModule, owner } = await loadFixture(deploySystemFixture);

    const solvencyTime = 604800;
    const liquidationTime = 259200;

    const solvencyZeroTx = configModule
      .connect(owner)
      .initializeConfigModule(0, liquidationTime);

    const liquidationZeroTx = configModule
      .connect(owner)
      .initializeConfigModule(solvencyTime, 0);

    await expect(solvencyZeroTx).to.be.revertedWithCustomError(
      configModule,
      "ZeroTime"
    );

    await expect(liquidationZeroTx).to.be.revertedWithCustomError(
      configModule,
      "ZeroTime"
    );
  });

  it("Should revert when setting zero time values", async () => {
    const { configModule, owner } = await loadFixture(deploySystemFixture);

    const solvencyZeroTx = configModule
      .connect(owner)
      .setSolvencyTimeRequired(0);

    const liquidationZeroTx = configModule
      .connect(owner)
      .setLiquidationTimeRequired(0);

    await expect(solvencyZeroTx).to.be.revertedWithCustomError(
      configModule,
      "ZeroTime"
    );

    await expect(liquidationZeroTx).to.be.revertedWithCustomError(
      configModule,
      "ZeroTime"
    );
  });
});
