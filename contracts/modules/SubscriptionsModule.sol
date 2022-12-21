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
        uint256 rate,
        uint256 feeRate
    );

    event SubscriptionFinished(
        bytes32 indexed giverId,
        bytes32 indexed creatorId,
        bytes32 indexed vaultId,
        uint256 subscriptionId,
        uint256 rate,
        uint256 feeRate
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

        if (SubscriptionId.load(giverId, creatorId).isSubscribed())
            revert SubscriptionErrors.AlreadySubscribed();

        if (!_isRateValid(vaultId, subscriptionRate))
            revert SubscriptionErrors.InvalidRate();

        uint256 rate = _getCurrentRate(vaultId, subscriptionRate);

        address profileOwner = _getOwnerOf(giverProfile, giverTokenId);

        (uint256 subscriptionId, uint256 feeRate) = _startSubscription(
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
            rate,
            feeRate
        );
    }

    function _startSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 subscriptionRate,
        address profileOwner
    ) private returns (uint256 subscriptionId, uint256 feeRate) {
        // Calculate fee rate
        feeRate = Fee.load().getFeeRate(subscriptionRate);

        // Decrease giver flow
        uint256 totalRate = subscriptionRate + feeRate;
        Balance.load(giverId, vaultId).decreaseFlow(totalRate);

        // Increase creator flow
        Balance.load(creatorId, vaultId).increaseFlow(subscriptionRate);

        // Increase treasury flow with feeRate
        bytes32 treasury = Fee.load().gratefulFeeTreasury;
        Balance.load(treasury, vaultId).increaseFlow(feeRate);

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

    function _createSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 subscriptionRate,
        uint256 feeRate,
        address profileOwner
    ) private returns (uint256 subscriptionId) {
        // Get subscription ID from subscription NFT
        GratefulSubscription gs = Config.load().getGratefulSubscription();
        subscriptionId = gs.getCurrentTokenId();

        // Start subscription
        Subscription.Data storage subscription = Subscription.load(
            subscriptionId
        );
        subscription.start(subscriptionRate, feeRate, creatorId, vaultId);

        // Link subscription ID with subscription data
        SubscriptionId.load(giverId, creatorId).set(subscriptionId);

        // Mint subscription NFT to giver profile owner
        gs.safeMint(profileOwner);
    }

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

    function unsubscribe(
        address giverProfile,
        uint256 giverTokenId,
        address creatorProfile,
        uint256 creatorTokenId
    ) external override {
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

        if (!SubscriptionId.load(giverId, creatorId).isSubscribed())
            revert SubscriptionErrors.NotSubscribed();

        (
            uint256 subscriptionId,
            uint256 rate,
            uint256 feeRate,
            bytes32 vaultId
        ) = _finishSubscription(giverId, creatorId);

        emit SubscriptionFinished(
            giverId,
            creatorId,
            vaultId,
            subscriptionId,
            rate,
            feeRate
        );
    }

    function _finishSubscription(
        bytes32 giverId,
        bytes32 creatorId
    )
        private
        returns (
            uint256 subscriptionId,
            uint256 subscriptionRate,
            uint256 feeRate,
            bytes32 vaultId
        )
    {
        // Get subscription data
        subscriptionId = SubscriptionId.load(giverId, creatorId).subscriptionId;

        Subscription.Data storage subscription = Subscription.load(
            subscriptionId
        );

        subscriptionRate = subscription.rate;
        feeRate = subscription.feeRate;
        vaultId = subscription.vaultId;

        // Increase giver flow
        uint256 totalRate = subscriptionRate + feeRate;
        Balance.load(giverId, vaultId).increaseFlow(totalRate);

        // Decrease creator flow
        Balance.load(creatorId, vaultId).decreaseFlow(subscriptionRate);

        // Decrease treasury flow with feeRate
        bytes32 treasury = Fee.load().gratefulFeeTreasury;
        Balance.load(treasury, vaultId).decreaseFlow(feeRate);

        // Finish subscription
        subscription.finish();
    }

    function getSubscription(
        uint256 subscriptionId
    ) external pure override returns (Subscription.Data memory subscription) {
        return Subscription.load(subscriptionId);
    }

    function getSubscriptionFrom(
        bytes32 giverId,
        bytes32 creatorId
    ) external view override returns (Subscription.Data memory subscription) {
        return SubscriptionId.load(giverId, creatorId).getSubscriptionData();
    }

    function getSubscriptionId(
        bytes32 giverId,
        bytes32 creatorId
    ) external view override returns (uint256) {
        return SubscriptionId.load(giverId, creatorId).subscriptionId;
    }

    function getSubscriptionRates(
        uint256 subscriptionId
    ) external view override returns (uint256, uint256) {
        return (
            Subscription.load(subscriptionId).rate,
            Subscription.load(subscriptionId).feeRate
        );
    }

    function isSubscribed(
        bytes32 giverId,
        bytes32 creatorId
    ) external view override returns (bool) {
        return SubscriptionId.load(giverId, creatorId).isSubscribed();
    }

    function getSubscriptionDuration(
        uint256 subscriptionId
    ) external view override returns (uint256) {
        return Subscription.load(subscriptionId).getDuration();
    }
}
