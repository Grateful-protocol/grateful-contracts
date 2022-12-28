// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ILiquidationsModule} from "../interfaces/ILiquidationsModule.sol";
import {SubscriptionsMixin} from "../mixins/SubscriptionsMixin.sol";
import {SubscriptionErrors} from "../errors/SubscriptionErrors.sol";
import {BalanceErrors} from "../errors/BalanceErrors.sol";
import {Balance} from "../storage/Balance.sol";
import {SubscriptionId} from "../storage/SubscriptionId.sol";
import {Subscription} from "../storage/Subscription.sol";
import {Fee} from "../storage/Fee.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";

contract LiquidationsModule is ILiquidationsModule, SubscriptionsMixin {
    using SignedMath for int256;
    using Balance for Balance.Data;
    using SubscriptionId for SubscriptionId.Data;
    using Subscription for Subscription.Data;
    using Fee for Fee.Data;

    event SubscriptionLiquidated(
        bytes32 indexed giverId,
        bytes32 indexed creatorId,
        bytes32 indexed liquidatorId,
        bytes32 vaultId,
        uint256 subscriptionId,
        uint256 reward,
        uint256 surplus
    );

    function liquidate(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 liquidatorId
    ) external override {
        bytes32 treasury = Fee.load().gratefulFeeTreasury;
        if (giverId == creatorId || creatorId == treasury)
            revert SubscriptionErrors.InvalidCreator();

        if (!SubscriptionId.load(giverId, creatorId).isSubscribed())
            revert SubscriptionErrors.NotSubscribed();

        bytes32 vaultId = SubscriptionId
            .load(giverId, creatorId)
            .getSubscriptionData()
            .vaultId;

        if (!Balance.load(giverId, vaultId).canBeLiquidated())
            revert BalanceErrors.SolventUser();

        (
            uint256 subscriptionId,
            uint256 subscriptionRate,
            uint256 feeRate,
            uint256 surplus
        ) = _liquidateSubscription(giverId, creatorId, vaultId);

        emit SubscriptionFinished(
            giverId,
            creatorId,
            vaultId,
            subscriptionId,
            subscriptionRate,
            feeRate
        );

        emit SubscriptionLiquidated(
            giverId,
            creatorId,
            liquidatorId,
            vaultId,
            subscriptionId,
            0,
            surplus
        );
    }

    function _liquidateSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId
    )
        private
        returns (
            uint256 subscriptionId,
            uint256 subscriptionRate,
            uint256 feeRate,
            uint256 surplus
        )
    {
        // Get current flow
        int256 flow = Balance.load(giverId, vaultId).flow;

        // Finish subscription
        (subscriptionId, subscriptionRate, feeRate, ) = _finishSubscription(
            giverId,
            creatorId
        );

        // Check if balance is negative and compensate if necessary
        if (Balance.load(giverId, vaultId).isNegative()) {
            surplus = _settleLostBalance(
                giverId,
                creatorId,
                vaultId,
                subscriptionRate,
                feeRate,
                flow
            );
        }
    }

    function _settleLostBalance(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 rate,
        uint256 feeRate,
        int256 flow
    ) private returns (uint256 surplus) {
        // Get absolute values
        uint256 absoluteBalance = Balance
            .load(giverId, vaultId)
            .balanceOf()
            .abs();

        uint256 totalFlow = flow.abs();

        // Decrease creator balance surplus
        uint256 subscriptionRateSurplus = (rate * absoluteBalance) / totalFlow;
        Balance.load(creatorId, vaultId).decrease(subscriptionRateSurplus);

        // Decrease treasury balance surplus
        uint256 feeRateSurplus = (feeRate * absoluteBalance) / totalFlow;
        bytes32 treasury = Fee.load().gratefulFeeTreasury;
        Balance.load(treasury, vaultId).decrease(feeRateSurplus);

        // Increase giver balance total surplus
        surplus = ((rate + feeRate) * absoluteBalance) / totalFlow;
        Balance.load(giverId, vaultId).increase(subscriptionRateSurplus);
    }
}
