import { System } from "../fixtures";
import { advanceTime } from "./advanceTime";
import { subscribe } from "./subscribe";

const update = async (fixture: System) => {
  // Load initial fixture
  const { subscriptionsModule, giver, creator, gratefulProfile } = fixture;

  const subscriptionId = await subscriptionsModule.getSubscriptionId(
    giver.profileId,
    creator.profileId
  );

  const duration = await subscriptionsModule.getSubscriptionDuration(
    subscriptionId
  );

  await advanceTime(fixture);
  const { tx, rate, feeRate } = await subscribe(fixture);

  return {
    ...fixture,
    subscriptionId,
    rate,
    feeRate,
    duration,
    tx,
  };
};

export { update };
