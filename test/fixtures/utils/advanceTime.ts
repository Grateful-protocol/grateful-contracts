import { time } from "@nomicfoundation/hardhat-network-helpers";
import { System } from "../fixtures";

const advanceTime = async (fixture: System) => {
  // Load initial fixture
  const { vaultId, giver, creator, balancesModule, treasuryId } = fixture;

  // Get current profiles balance
  const giverBalance = await balancesModule.balanceOf(giver.profileId, vaultId);
  const creatorBalance = await balancesModule.balanceOf(
    creator.profileId,
    vaultId
  );
  const treasuryBalance = await balancesModule.balanceOf(treasuryId, vaultId);

  // Get current profiles flow
  const giverFlow = await balancesModule.getFlow(giver.profileId, vaultId);
  const creatorFlow = await balancesModule.getFlow(creator.profileId, vaultId);
  const treasuryFlow = await balancesModule.getFlow(treasuryId, vaultId);

  // Get giver balance time left
  const giverTimeLeft = await balancesModule.getRemainingTimeToZero(
    giver.profileId,
    vaultId
  );

  // Advance 600 seconds / 10 minutes
  const TIME = 600;
  await time.increase(TIME);

  return {
    ...fixture,
    giverBalance,
    creatorBalance,
    treasuryBalance,
    giverFlow,
    creatorFlow,
    treasuryFlow,
    TIME,
    giverTimeLeft,
  };
};

export { advanceTime };
