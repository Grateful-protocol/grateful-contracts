import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySystemFixture } from "../../../fixtures/fixtures";
import { ethers } from "hardhat";

describe("Multicall - Deposit and subscribe", () => {
  const depositAndSubscribeFixture = async () => {
    const fixture = await loadFixture(deploySystemFixture);

    // Load initial fixture
    const {
      vault,
      vaultId,
      fundsModule,
      giver,
      creator,
      balancesModule,
      multicallModule,
      gratefulSubscription,
      feesModule,
    } = fixture;

    // Set token data
    const tokenAddress = await vault.asset();
    const token = await ethers.getContractAt("ERC20", tokenAddress);
    const decimals = await token.decimals();
    const DEPOSIT_AMOUNT = ethers.utils.parseUnits("10", decimals);

    // User token balance before depositing
    const balanceBefore = await token.balanceOf(giver.address);
    const gratefulBalanceBefore = await balancesModule.balanceOf(
      giver.profileId,
      vaultId
    );

    // Approve token to grateful contract
    await token
      .connect(giver.signer)
      .approve(fundsModule.address, DEPOSIT_AMOUNT);

    // Expected shares to be minted before depositing
    const DECIMALS_DIVISOR = 10 ** (20 - decimals);
    const previewDeposit = await vault.previewDeposit(DEPOSIT_AMOUNT);
    const expectedShares = previewDeposit.mul(DECIMALS_DIVISOR);

    // Set subscription data
    const SUBSCRIPTION_RATE = 38580246913580; // 1e20 per month

    // Get current ID
    const subscriptionId = await gratefulSubscription.getCurrentTokenId();

    // Encode deposit and subscribe txs
    const ABI = [
      "function depositFunds(bytes32,bytes32,uint256)",
      "function subscribe(bytes32,bytes32,bytes32,uint256)",
    ];
    const iface = new ethers.utils.Interface(ABI);
    const depositTx = iface.encodeFunctionData("depositFunds", [
      giver.profileId,
      vaultId,
      DEPOSIT_AMOUNT,
    ]);
    const subscribeTx = iface.encodeFunctionData("subscribe", [
      giver.profileId,
      creator.profileId,
      vaultId,
      SUBSCRIPTION_RATE,
    ]);

    // User deposit tx
    const tx = await multicallModule
      .connect(giver.signer)
      .multicall([depositTx, subscribeTx]);

    await tx.wait();

    // Expected rate from vault
    const rate = await vault.convertToShares(SUBSCRIPTION_RATE);
    const feeRate = await feesModule.getFeeRate(rate);

    return {
      ...fixture,
      token,
      DEPOSIT_AMOUNT,
      balanceBefore,
      gratefulBalanceBefore,
      expectedShares,
      rate,
      feeRate,
      subscriptionId,
      tx,
    };
  };

  it("Should update token balances correctly", async () => {
    const { token, giver, balanceBefore, DEPOSIT_AMOUNT } = await loadFixture(
      depositAndSubscribeFixture
    );

    expect(await token.balanceOf(giver.address)).to.be.equal(
      balanceBefore.sub(DEPOSIT_AMOUNT)
    );
  });

  it("Should update user balance correctly", async () => {
    const { balancesModule, giver, vaultId, expectedShares } =
      await loadFixture(depositAndSubscribeFixture);

    expect(
      await balancesModule.balanceOf(giver.profileId, vaultId)
    ).to.be.equal(expectedShares);
  });

  it("Should emit a FundsDeposited event", async () => {
    const { tx, DEPOSIT_AMOUNT, fundsModule, giver, vaultId, expectedShares } =
      await loadFixture(depositAndSubscribeFixture);

    await expect(tx)
      .to.emit(fundsModule, "FundsDeposited")
      .withArgs(giver.profileId, vaultId, DEPOSIT_AMOUNT, expectedShares);
  });

  it("Should return the right subscription data", async () => {
    const { subscriptionsModule, giver, creator, vaultId, rate, feeRate } =
      await loadFixture(depositAndSubscribeFixture);

    // Get last timestamp
    const timestamp = await time.latest();

    // Get subscription struct
    const subscription = await subscriptionsModule.getSubscriptionFrom(
      giver.profileId,
      creator.profileId
    );

    // Assert each subscription element
    expect(subscription.rate).to.be.equal(rate);
    expect(subscription.feeRate).to.be.equal(feeRate);
    expect(subscription.lastUpdate).to.be.equal(timestamp);
    expect(subscription.duration).to.be.equal(0);
    expect(subscription.creatorId).to.be.equal(creator.profileId);
    expect(subscription.vaultId).to.be.equal(vaultId);
  });

  it("Should return the right subscription rates", async () => {
    const { subscriptionsModule, subscriptionId, rate, feeRate } =
      await loadFixture(depositAndSubscribeFixture);

    const [currentRate, currentFeeRate] =
      await subscriptionsModule.getSubscriptionRates(subscriptionId);

    expect(currentRate).to.be.equal(rate);
    expect(currentFeeRate).to.be.equal(feeRate);
  });

  it("Should return the right giver flow", async () => {
    const { balancesModule, giver, vaultId, rate, feeRate } = await loadFixture(
      depositAndSubscribeFixture
    );

    // Negative flow because balance is decreasing
    const flow = -rate.add(feeRate);

    expect(await balancesModule.getFlow(giver.profileId, vaultId)).to.be.equal(
      flow
    );
  });

  it("Should return the right creator flow", async () => {
    const { balancesModule, creator, vaultId, rate } = await loadFixture(
      depositAndSubscribeFixture
    );

    expect(
      await balancesModule.getFlow(creator.profileId, vaultId)
    ).to.be.equal(rate);
  });

  it("Should return the right treasury flow", async () => {
    const { balancesModule, treasuryId, vaultId, feeRate } = await loadFixture(
      depositAndSubscribeFixture
    );

    expect(await balancesModule.getFlow(treasuryId, vaultId)).to.be.equal(
      feeRate
    );
  });

  it("Should return that the user is subscribed to the creator", async () => {
    const { subscriptionsModule, giver, creator } = await loadFixture(
      depositAndSubscribeFixture
    );

    expect(
      await subscriptionsModule.isSubscribed(giver.profileId, creator.profileId)
    ).to.equal(true);
  });

  it("Should emit a SubscriptionStarted event", async () => {
    const {
      tx,
      subscriptionsModule,
      giver,
      creator,
      vaultId,
      rate,
      feeRate,
      subscriptionId,
    } = await loadFixture(depositAndSubscribeFixture);

    await expect(tx)
      .to.emit(subscriptionsModule, "SubscriptionStarted")
      .withArgs(
        giver.profileId,
        creator.profileId,
        vaultId,
        subscriptionId,
        rate,
        feeRate
      );
  });
});
