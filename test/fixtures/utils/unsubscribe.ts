import { System } from "../fixtures";

const unsubscribe = async (fixture: System) => {
  // Load initial fixture
  const { vaultId, subscriptionsModule, giver, creator, gratefulProfile } =
    fixture;

  const subscriptionId = await subscriptionsModule.getSubscriptionId(
    giver.profileId,
    creator.profileId,
    vaultId
  );

  const [rate, feeRate] = await subscriptionsModule.getSubscriptionRates(
    subscriptionId
  );

  const [duration, totalRate] =
    await subscriptionsModule.getSubscriptionCurrentStatus(subscriptionId);

  // User subscribe tx
  const tx = await subscriptionsModule
    .connect(giver.signer)
    .unsubscribe(
      gratefulProfile.address,
      giver.tokenId,
      gratefulProfile.address,
      creator.tokenId,
      vaultId
    );

  await tx.wait();

  return {
    ...fixture,
    subscriptionId,
    rate,
    feeRate,
    duration,
    totalRate,
    tx,
  };
};

export { unsubscribe };
