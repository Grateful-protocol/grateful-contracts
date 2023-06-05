import { ethers } from "hardhat";
import { System } from "../fixtures";

const liquidate = async (fixture: System) => {
  // Load initial fixture
  const {
    vaultId,
    liquidationsModule,
    balancesModule,
    subscriptionsModule,
    giver,
    creator,
    owner,
    treasuryId,
  } = fixture;

  // Get subscription data
  const subscriptionId = await subscriptionsModule.getSubscriptionId(
    giver.profileId,
    creator.profileId
  );

  const [rate, feeRate] = await subscriptionsModule.getSubscriptionRates(
    subscriptionId
  );

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

  // Calculate surplus
  const surplus = giverBalance.lt(0) ? giverBalance.add(giverFlow).abs() : 0;

  // Set liquidator
  // const liquidatorId = treasuryId;

  // Liquidation tx
  const tx = await liquidationsModule
    .connect(owner)
    .liquidate(giver.profileId, creator.profileId);

  await tx.wait();

  return {
    ...fixture,
    giverBalance,
    creatorBalance,
    treasuryBalance,
    giverFlow,
    creatorFlow,
    treasuryFlow,
    // liquidatorId,
    subscriptionId,
    rate,
    feeRate,
    surplus,
    tx,
  };
};

export { liquidate };
