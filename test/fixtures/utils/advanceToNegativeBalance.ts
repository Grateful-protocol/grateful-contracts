import { time } from "@nomicfoundation/hardhat-network-helpers";
import { System } from "../fixtures";

const advanceToNegativeBalance = async (fixture: System) => {
  // Load initial fixture
  const { vaultId, giver, balancesModule } = fixture;

  // Get giver data
  const giverBalance = await balancesModule.balanceOf(giver.profileId, vaultId);
  const giverFlow = await balancesModule.getFlow(giver.profileId, vaultId);

  // Get giver balance time left
  const giverTimeLeft = await balancesModule.getRemainingTimeToZero(
    giver.profileId,
    vaultId
  );

  // Time that passed since balance went negative
  const NEGATIVE_TIME = 100;

  // Calculate liquidation time
  const elapsedTime = giverTimeLeft.add(NEGATIVE_TIME);

  // Advance to liquidation time
  await time.increase(elapsedTime.toNumber());

  return {
    ...fixture,
    giverBalance,
    giverFlow,
    elapsedTime,
    NEGATIVE_TIME,
  };
};

export { advanceToNegativeBalance };
