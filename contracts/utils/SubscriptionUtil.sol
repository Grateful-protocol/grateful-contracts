// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Balance} from "../storage/Balance.sol";
import {Subscription} from "../storage/Subscription.sol";
import {SubscriptionRegistry} from "../storage/SubscriptionRegistry.sol";
import {Fee} from "../storage/Fee.sol";
import {IGratefulSubscription} from "../interfaces/IGratefulSubscription.sol";
import {AssociatedSystem} from "@synthetixio/core-modules/contracts/storage/AssociatedSystem.sol";
import {Fee} from "../storage/Fee.sol";
import {SubscriptionRegistry} from "../storage/SubscriptionRegistry.sol";
import {SubscriptionErrors} from "../errors/SubscriptionErrors.sol";

/**
 * @title Utils for reusing subscriptions interactions.
 *
 * Use case: reusing finishing subscription logic for Subscriptions and Liquidations modules
 */
library SubscriptionUtil {
    using Balance for Balance.Data;
    using Subscription for Subscription.Data;
    using AssociatedSystem for AssociatedSystem.Data;
    using Fee for Fee.Data;
    using SubscriptionRegistry for SubscriptionRegistry.Data;

    bytes32 private constant _GRATEFUL_SUBSCRIPTION_NFT =
        "gratefulSubscriptionNft";

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
     * @dev Starts a subscription.
     *
     * This function is used from a user.
     *
     * Updates the balances flows (giver, creator and treasury).
     *
     * If the subscription between giver and creator already exist, then the subscription is
     * updated to the new rate, else the subscription is created for the first time.
     *
     * To create a new subscription means to mint a new token ID from the Grateful subscription NFT.
     */
    function startSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 subscriptionRate,
        address profileOwner
    )
        internal
        returns (uint256 subscriptionId, uint256 feeRate, uint256 totalRate)
    {
        // Calculate fee rate
        feeRate = Fee.load().getFeeRate(subscriptionRate);

        // Decrease giver flow
        totalRate = subscriptionRate + feeRate;
        Balance.load(giverId, vaultId).increaseOutflow(totalRate);

        // Increase creator flow
        Balance.load(creatorId, vaultId).increaseInflow(subscriptionRate);

        // Increase treasury flow with feeRate
        bytes32 treasuryId = Fee.load().gratefulFeeTreasury;
        Balance.load(treasuryId, vaultId).increaseInflow(feeRate);

        if (SubscriptionRegistry.load(giverId, creatorId).exists()) {
            subscriptionId = _updateSubscription(
                giverId,
                creatorId,
                vaultId,
                subscriptionRate,
                feeRate
            );
        } else {
            subscriptionId = _createSubscription(
                giverId,
                creatorId,
                vaultId,
                subscriptionRate,
                feeRate,
                profileOwner
            );
        }
    }

    /**
     * @dev Creates a subscription.
     *
     * This function is used from a user.
     *
     * Gets the next token ID from the subscription NFT.
     *
     * Saves the subscription data from this ID, and links it with the giver and creator.
     *
     * A new token ID is minted to the giver profile owner.
     */
    function _createSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 subscriptionRate,
        uint256 feeRate,
        address profileOwner
    ) private returns (uint256 subscriptionId) {
        // Get subscription ID from subscription NFT
        IGratefulSubscription gs = IGratefulSubscription(
            AssociatedSystem.load(_GRATEFUL_SUBSCRIPTION_NFT).proxy
        );
        subscriptionId = gs.getCurrentTokenId();

        // Start subscription
        Subscription.Data storage subscription = Subscription.load(
            subscriptionId
        );
        subscription.start(subscriptionRate, feeRate, creatorId, vaultId);

        // Link subscription ID with subscription data
        SubscriptionRegistry.load(giverId, creatorId).set(subscriptionId);

        // Mint subscription NFT to giver profile owner
        gs.mint(profileOwner);
    }

    /**
     * @dev Updates a subscription.
     *
     * This function is used from a user.
     *
     * Loads the subscription data from the giver and creator.
     *
     * Updates the subscription data with the new rates and vault.
     *
     * No new subscription token is minted, the already created token is reused.
     */
    function _updateSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 subscriptionRate,
        uint256 feeRate
    ) private returns (uint256 subscriptionId) {
        // Get subscription data
        subscriptionId = SubscriptionRegistry
            .load(giverId, creatorId)
            .subscriptionId;

        Subscription.Data storage subscription = Subscription.load(
            subscriptionId
        );

        // Update subscription
        subscription.update(subscriptionRate, feeRate, vaultId);
    }

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

    /**
     * @dev Validates if the creator is correct.
     *
     * - Only existing creator profile ID
     * - Giver and creator cannot be the same
     * - Creator cannot be Grateful treasury
     */
    function validateCreator(bytes32 giverId, bytes32 creatorId) internal view {
        bytes32 treasuryId = Fee.load().gratefulFeeTreasury;
        if (giverId == creatorId || creatorId == treasuryId)
            revert SubscriptionErrors.InvalidCreator();
    }
}
