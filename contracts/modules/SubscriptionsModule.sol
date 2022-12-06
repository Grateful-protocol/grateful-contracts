// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ISubscriptionsModule} from "../interfaces/ISubscriptionsModule.sol";
import {ProfilesMixin} from "../mixins/ProfilesMixin.sol";
import {VaultsMixin} from "../mixins/VaultsMixin.sol";
import {SubscriptionErrors} from "../errors/SubscriptionErrors.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {BalanceErrors} from "../errors/BalanceErrors.sol";
import {Balance} from "../storage/Balance.sol";
import {Subscription} from "../storage/Subscription.sol";
import {SubscriptionId} from "../storage/SubscriptionId.sol";
import {Config} from "../storage/Config.sol";
import {GratefulSubscription} from "../nfts/GratefulSubscription.sol";

contract SubscriptionsModule is
    ISubscriptionsModule,
    ProfilesMixin,
    VaultsMixin
{
    using Balance for Balance.Data;
    using Subscription for Subscription.Data;
    using SubscriptionId for SubscriptionId.Data;
    using Config for Config.Data;

    event SubscriptionCreated(
        bytes32 indexed giverId,
        bytes32 indexed creatorId,
        bytes32 indexed vaultId,
        uint256 subscriptionId,
        uint256 rate
    );

    function subscribe(
        address giverProfile,
        uint256 giverTokenId,
        address creatorProfile,
        uint256 creatorTokenId,
        bytes32 vaultId,
        uint256 subscriptionRate
    ) external override {
        if (!_isVaultInitialized(vaultId)) revert VaultErrors.InvalidVault();

        bytes32 giverId = _validateAllowanceAndGetProfile(
            giverProfile,
            giverTokenId
        );

        bytes32 creatorId = _validateExistenceAndGetProfile(
            creatorProfile,
            creatorTokenId
        );

        // @audit || creatorId == gratefulFeeTreasury
        if (giverId == creatorId) revert SubscriptionErrors.InvalidCreator();

        if (!Subscription.load(giverId, creatorId, vaultId).isSubscribe())
            revert SubscriptionErrors.AlreadySubscribed();

        if (!_isRateValid(vaultId, subscriptionRate))
            revert SubscriptionErrors.InvalidRate();

        uint256 rate = _getCurrentRate(vaultId, subscriptionRate);

        address profileOwner = _getOwnerOf(giverProfile, giverTokenId);

        uint256 subscriptionId = _startSubscription(
            giverId,
            creatorId,
            vaultId,
            rate,
            profileOwner
        );

        if (!Balance.load(giverId, vaultId).canStartSubscription())
            revert BalanceErrors.InsolventUser();

        emit SubscriptionCreated(
            giverId,
            creatorId,
            vaultId,
            subscriptionId,
            rate
        );
    }

    function _startSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 subscriptionRate,
        address profileOwner
    ) private returns (uint256 subscriptionId) {
        // Decrease giver flow
        Balance.load(giverId, vaultId).decreaseFlow(subscriptionRate);

        // Increase creator flow
        Balance.load(creatorId, vaultId).increaseFlow(subscriptionRate);

        // @audit Increase treasury flow with feeRate

        // Get subscription ID from subscription NFT
        GratefulSubscription gs = Config.load().getGratefulSubscription();
        subscriptionId = gs.getCurrentTokenId();

        // Start subscription
        Subscription.Data storage subscription = Subscription.load(
            giverId,
            creatorId,
            vaultId
        );
        subscription.start(subscriptionRate, giverId, creatorId);

        // Link subscription ID with subscription data
        SubscriptionId.load(subscriptionId).set(subscription);

        // Mint subscription NFT to giver profile owner
        gs.safeMint(profileOwner);
    }
}
