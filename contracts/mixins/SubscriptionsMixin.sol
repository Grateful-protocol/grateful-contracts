// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Balance} from "../storage/Balance.sol";
import {Subscription} from "../storage/Subscription.sol";
import {SubscriptionId} from "../storage/SubscriptionId.sol";
import {Fee} from "../storage/Fee.sol";

contract SubscriptionsMixin {
    using Balance for Balance.Data;
    using Subscription for Subscription.Data;

    event SubscriptionFinished(
        bytes32 indexed giverId,
        bytes32 indexed creatorId,
        bytes32 indexed vaultId,
        uint256 subscriptionId,
        uint256 rate,
        uint256 feeRate
    );

    function _finishSubscription(
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
}
