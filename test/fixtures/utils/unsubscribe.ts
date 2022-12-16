import { System } from "../fixtures";

const unsubscribe = async (fixture: System) => {
  // Load initial fixture
  const { vaultId, subscriptionsModule, giver, creator, gratefulProfile } =
    fixture;

  const rate = await subscriptionsModule.getSubscriptionRate(
    giver.profileId,
    creator.profileId,
    vaultId
  );

  const [duration, totalRate] =
    await subscriptionsModule.getSubscriptionCurrentStatus(
      giver.profileId,
      creator.profileId,
      vaultId
    );

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
    rate,
    duration,
    totalRate,
    tx,
  };
};

export { unsubscribe };
