import { ethers } from "hardhat";
import { System } from "../fixtures";

const subscribe = async (fixture: System) => {
  // Load initial fixture
  const {
    vault,
    vaultId,
    subscriptionsModule,
    giver,
    creator,
    gratefulProfile,
    gratefulSubscription,
    feesModule,
  } = fixture;

  // Set token data
  const tokenAddress = await vault.asset();
  const token = await ethers.getContractAt("ERC20", tokenAddress);
  const SUBSCRIPTION_RATE = 38580246913580; // 1e20 per month

  // Get current ID
  const subscriptionId = await gratefulSubscription.getCurrentTokenId();

  // User subscribe tx
  const tx = await subscriptionsModule
    .connect(giver.signer)
    .subscribe(
      gratefulProfile.address,
      giver.tokenId,
      gratefulProfile.address,
      creator.tokenId,
      vaultId,
      SUBSCRIPTION_RATE
    );

  await tx.wait();

  // Expected rate from vault
  const rate = await vault.convertToShares(SUBSCRIPTION_RATE);
  const feeRate = await feesModule.getFeeRate(rate);

  return {
    ...fixture,
    token,
    SUBSCRIPTION_RATE,
    rate,
    feeRate,
    subscriptionId,
    tx,
  };
};

export { subscribe };