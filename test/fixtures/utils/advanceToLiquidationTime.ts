import { time } from "@nomicfoundation/hardhat-network-helpers";
import { System } from "../fixtures";

const advanceToLiquidationTime = async (fixture: System) => {
  // Load initial fixture
  const { vaultId, giver, balancesModule, configModule } = fixture;

  // Get liquidation time required
  const liquidationTimeRequired =
    await configModule.getLiquidationTimeRequired();

  // Get giver balance time left
  const giverTimeLeft = await balancesModule.getRemainingTimeToZero(
    giver.profileId,
    vaultId
  );

  // Calculate liquidation time
  const liquidationTime = giverTimeLeft.sub(liquidationTimeRequired).add(1);

  // Advance to liquidation time
  await time.increase(liquidationTime.toNumber());

  return {
    ...fixture,
    liquidationTimeRequired,
  };
};

export { advanceToLiquidationTime };
