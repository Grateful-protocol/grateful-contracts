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
import {SubscriptionRegistry} from "../storage/SubscriptionRegistry.sol";
import {Profile} from "../storage/Profile.sol";
import {ProfileRBAC} from "../storage/ProfileRBAC.sol";

/**
 * @title Module for starting and finishing subscriptions.
 * @dev See ISubscriptionsModule.
 */
contract SubscriptionsModule is ISubscriptionsModule {
    using Balance for Balance.Data;
    using Subscription for Subscription.Data;
    using SubscriptionRegistry for SubscriptionRegistry.Data;
    using Profile for Profile.Data;

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

        SubscriptionUtil.validateCreator(giverId, creatorId);

        if (SubscriptionRegistry.load(giverId, creatorId).isSubscribed())
            revert SubscriptionErrors.AlreadySubscribed();

        if (!VaultUtil.isRateValid(vaultId, subscriptionRate))
            revert SubscriptionErrors.InvalidRate();

        uint256 rate = VaultUtil.getCurrentRate(vaultId, subscriptionRate);

        (uint256 subscriptionId, uint256 feeRate, ) = SubscriptionUtil
            .startSubscription(giverId, creatorId, vaultId, rate, owner);

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

    /// @inheritdoc ISubscriptionsModule
    function unsubscribe(bytes32 giverId, bytes32 creatorId) external {
        Profile.loadProfileAndValidatePermission(
            giverId,
            ProfileRBAC._UNSUBSCRIBE_PERMISSION
        );

        Profile.exists(creatorId);

        SubscriptionUtil.validateCreator(giverId, creatorId);

        if (!SubscriptionRegistry.load(giverId, creatorId).isSubscribed())
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
        return
            SubscriptionRegistry.load(giverId, creatorId).getSubscriptionData();
    }

    /// @inheritdoc ISubscriptionsModule
    function getSubscriptionId(
        bytes32 giverId,
        bytes32 creatorId
    ) external view override returns (uint256) {
        return SubscriptionRegistry.load(giverId, creatorId).subscriptionId;
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
        return SubscriptionRegistry.load(giverId, creatorId).isSubscribed();
    }

    /// @inheritdoc ISubscriptionsModule
    function getSubscriptionDuration(
        uint256 subscriptionId
    ) external view override returns (uint256) {
        return Subscription.load(subscriptionId).getDuration();
    }
}
