import { System } from "../fixtures";

const unsubscribe = async (fixture: System) => {
  // Load initial fixture
  const { subscriptionsModule, giver, creator, gratefulProfile } = fixture;

  const subscriptionId = await subscriptionsModule.getSubscriptionId(
    giver.profileId,
    creator.profileId
  );

  const [rate, feeRate] = await subscriptionsModule.getSubscriptionRates(
    subscriptionId
  );

  const duration = await subscriptionsModule.getSubscriptionDuration(
    subscriptionId
  );

  // User subscribe tx
  const tx = await subscriptionsModule
    .connect(giver.signer)
    .unsubscribe(
      gratefulProfile.address,
      giver.tokenId,
      gratefulProfile.address,
      creator.tokenId
    );

  await tx.wait();

  return {
    ...fixture,
    subscriptionId,
    rate,
    feeRate,
    duration,
    tx,
  };
};

export { unsubscribe };
