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
import {Fee} from "../storage/Fee.sol";
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
    using Fee for Fee.Data;

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

        bytes32 treasury = Fee.load().gratefulFeeTreasury;
        if (giverId == creatorId || creatorId == treasury)
            revert SubscriptionErrors.InvalidCreator();

        if (Subscription.load(giverId, creatorId, vaultId).isSubscribe())
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
        // Calculate fee rate
        uint256 feeRate = Fee.load().getFeeRate(subscriptionRate);

        // Decrease giver flow
        uint256 totalRate = subscriptionRate + feeRate;
        Balance.load(giverId, vaultId).decreaseFlow(totalRate);

        // Increase creator flow
        Balance.load(creatorId, vaultId).increaseFlow(subscriptionRate);

        // Increase treasury flow with feeRate
        bytes32 treasury = Fee.load().gratefulFeeTreasury;
        Balance.load(treasury, vaultId).increaseFlow(feeRate);

        // Get subscription ID from subscription NFT
        GratefulSubscription gs = Config.load().getGratefulSubscription();
        subscriptionId = gs.getCurrentTokenId();

        // Start subscription
        Subscription.Data storage subscription = Subscription.load(
            giverId,
            creatorId,
            vaultId
        );
        subscription.start(subscriptionRate, feeRate);

        // Link subscription ID with subscription data
        bytes32 subscriptionHash = Subscription.hash(
            giverId,
            creatorId,
            vaultId
        );
        SubscriptionId.load(subscriptionId).set(subscriptionHash);

        // Mint subscription NFT to giver profile owner
        gs.safeMint(profileOwner);
    }

    function getSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId
    ) external pure override returns (Subscription.Data memory subscription) {
        return Subscription.load(giverId, creatorId, vaultId);
    }

    function getSubscriptionFrom(
        uint256 subscriptionId
    ) external view override returns (Subscription.Data memory subscription) {
        return SubscriptionId.load(subscriptionId).getSubscriptionData();
    }

    function getSubscriptionRate(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId
    ) external view override returns (uint256) {
        return Subscription.load(giverId, creatorId, vaultId).rate;
    }

    function isSubscribe(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId
    ) external view override returns (bool) {
        return Subscription.load(giverId, creatorId, vaultId).isSubscribe();
    }
}
