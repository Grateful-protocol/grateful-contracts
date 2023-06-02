// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Balance} from "../storage/Balance.sol";
import {Subscription} from "../storage/Subscription.sol";
import {SubscriptionRegistry} from "../storage/SubscriptionRegistry.sol";
import {Fee} from "../storage/Fee.sol";

/**
 * @title Utils for reusing subscriptions interactions.
 *
 * Use case: reusing finishing subscription logic for Subscriptions and Liquidations modules
 */
library SubscriptionUtil {
    using Balance for Balance.Data;
    using Subscription for Subscription.Data;

    /**
     * @notice Emits the data from the finished subscription
     * @param giverId The ID from the profile that was subscribed
     * @param creatorId The ID from the profile that was receiving the subscription
     * @param vaultId The vault being used in the subscription
     * @param subscriptionId The subscription ID from the Grateful Subscription NFT
     * @param rate The subscription rate that was going to the creator (1e-20/second)
     * @param feeRate The fee rate that was going to the treasury (1e-20/second)
     */
    event SubscriptionFinished(
        bytes32 indexed giverId,
        bytes32 indexed creatorId,
        bytes32 indexed vaultId,
        uint256 subscriptionId,
        uint256 rate,
        uint256 feeRate
    );

    /**
     * @dev Finishes a subscription.
     *
     * This function is used from user or liquidator.
     *
     * Updates the balances flows (giver, creator and treasury).
     *
     * Updates the subscription state to be finished.
     *
     * Emit a event with the subscription data.
     */
    function finishSubscription(
        bytes32 giverId,
        bytes32 creatorId
    )
        internal
        returns (
            uint256 subscriptionId,
            uint256 subscriptionRate,
            uint256 feeRate,
            bytes32 vaultId
        )
    {
        // Get subscription data
        subscriptionId = SubscriptionRegistry
            .load(giverId, creatorId)
            .subscriptionId;

        Subscription.Data storage subscription = Subscription.load(
            subscriptionId
        );

        subscriptionRate = subscription.rate;
        feeRate = subscription.feeRate;
        vaultId = subscription.vaultId;

        // Increase giver flow
        uint256 totalRate = subscriptionRate + feeRate;
        Balance.load(giverId, vaultId).decreaseOutflow(totalRate);

        // Decrease creator flow
        Balance.load(creatorId, vaultId).decreaseInflow(subscriptionRate);

        // Decrease treasury flow with feeRate
        bytes32 treasuryId = Fee.load().gratefulFeeTreasury;
        Balance.load(treasuryId, vaultId).decreaseInflow(feeRate);

        // Finish subscription
        subscription.finish();

        // Emit event
        emit SubscriptionFinished(
            giverId,
            creatorId,
            vaultId,
            subscriptionId,
            subscriptionRate,
            feeRate
        );
    }
}
