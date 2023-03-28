// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ISubscriptionsModule} from "../interfaces/ISubscriptionsModule.sol";
import {SubscriptionUtil} from "../utils/SubscriptionUtil.sol";
import {VaultUtil} from "../utils/VaultUtil.sol";
import {SubscriptionErrors} from "../errors/SubscriptionErrors.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {BalanceErrors} from "../errors/BalanceErrors.sol";
import {Balance} from "../storage/Balance.sol";
import {Subscription} from "../storage/Subscription.sol";
import {SubscriptionId} from "../storage/SubscriptionId.sol";
import {Fee} from "../storage/Fee.sol";
import {IGratefulSubscription} from "../interfaces/IGratefulSubscription.sol";
import {AssociatedSystem} from "@synthetixio/core-modules/contracts/storage/AssociatedSystem.sol";
import {Profile} from "../storage/Profile.sol";
import {ProfileRBAC} from "../storage/ProfileRBAC.sol";

/**
 * @title Module for starting and finishing subscriptions.
 * @dev See ISubscriptionsModule.
 */
contract SubscriptionsModule is ISubscriptionsModule {
    using Balance for Balance.Data;
    using Subscription for Subscription.Data;
    using SubscriptionId for SubscriptionId.Data;
    using Fee for Fee.Data;
    using AssociatedSystem for AssociatedSystem.Data;
    using Profile for Profile.Data;

    bytes32 private constant _GRATEFUL_SUBSCRIPTION_NFT =
        "gratefulSubscriptionNft";

    /// @inheritdoc ISubscriptionsModule
    function subscribe(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 subscriptionRate
    ) external {
        if (!VaultUtil.isVaultActive(vaultId))
            revert VaultErrors.InvalidVault();

        Profile.Data storage profile = Profile.loadProfileAndValidatePermission(
            giverId,
            ProfileRBAC._SUBSCRIBE_PERMISSION
        );

        address owner = profile.rbac.owner;

        Profile.exists(creatorId);

        bytes32 treasury = Fee.load().gratefulFeeTreasury;
        if (giverId == creatorId || creatorId == treasury)
            revert SubscriptionErrors.InvalidCreator();

        if (SubscriptionId.load(giverId, creatorId).isSubscribed())
            revert SubscriptionErrors.AlreadySubscribed();

        if (!VaultUtil.isRateValid(vaultId, subscriptionRate))
            revert SubscriptionErrors.InvalidRate();

        uint256 rate = VaultUtil.getCurrentRate(vaultId, subscriptionRate);

        (uint256 subscriptionId, uint256 feeRate, ) = _startSubscription(
            giverId,
            creatorId,
            vaultId,
            rate,
            owner
        );

        if (!Balance.load(giverId, vaultId).canStartSubscription())
            revert BalanceErrors.InsolventUser();

        emit SubscriptionStarted(
            giverId,
            creatorId,
            vaultId,
            subscriptionId,
            rate,
            feeRate
        );
    }

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
    function _startSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 subscriptionRate,
        address profileOwner
    )
        private
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
        bytes32 treasury = Fee.load().gratefulFeeTreasury;
        Balance.load(treasury, vaultId).increaseInflow(feeRate);

        if (SubscriptionId.load(giverId, creatorId).exists()) {
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
        SubscriptionId.load(giverId, creatorId).set(subscriptionId);

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
        subscriptionId = SubscriptionId.load(giverId, creatorId).subscriptionId;

        Subscription.Data storage subscription = Subscription.load(
            subscriptionId
        );

        // Update subscription
        subscription.update(subscriptionRate, feeRate, vaultId);
    }

    /// @inheritdoc ISubscriptionsModule
    function unsubscribe(bytes32 giverId, bytes32 creatorId) external {
        Profile.loadProfileAndValidatePermission(
            giverId,
            ProfileRBAC._UNSUBSCRIBE_PERMISSION
        );

        Profile.exists(creatorId);

        bytes32 treasury = Fee.load().gratefulFeeTreasury;
        if (giverId == creatorId || creatorId == treasury)
            revert SubscriptionErrors.InvalidCreator();

        if (!SubscriptionId.load(giverId, creatorId).isSubscribed())
            revert SubscriptionErrors.NotSubscribed();

        SubscriptionUtil.finishSubscription(giverId, creatorId);
    }

    /// @inheritdoc ISubscriptionsModule
    function getSubscription(
        uint256 subscriptionId
    ) external pure override returns (Subscription.Data memory subscription) {
        return Subscription.load(subscriptionId);
    }

    /// @inheritdoc ISubscriptionsModule
    function getSubscriptionFrom(
        bytes32 giverId,
        bytes32 creatorId
    ) external view override returns (Subscription.Data memory subscription) {
        return SubscriptionId.load(giverId, creatorId).getSubscriptionData();
    }

    /// @inheritdoc ISubscriptionsModule
    function getSubscriptionId(
        bytes32 giverId,
        bytes32 creatorId
    ) external view override returns (uint256) {
        return SubscriptionId.load(giverId, creatorId).subscriptionId;
    }

    /// @inheritdoc ISubscriptionsModule
    function getSubscriptionRates(
        uint256 subscriptionId
    ) external view override returns (uint256, uint256) {
        return (
            Subscription.load(subscriptionId).rate,
            Subscription.load(subscriptionId).feeRate
        );
    }

    /// @inheritdoc ISubscriptionsModule
    function isSubscribed(
        bytes32 giverId,
        bytes32 creatorId
    ) external view override returns (bool) {
        return SubscriptionId.load(giverId, creatorId).isSubscribed();
    }

    /// @inheritdoc ISubscriptionsModule
    function getSubscriptionDuration(
        uint256 subscriptionId
    ) external view override returns (uint256) {
        return Subscription.load(subscriptionId).getDuration();
    }
}
