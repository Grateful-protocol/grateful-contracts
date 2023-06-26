// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ILiquidationsModule} from "../interfaces/ILiquidationsModule.sol";
import {SubscriptionUtil} from "../utils/SubscriptionUtil.sol";
import {SubscriptionErrors} from "../errors/SubscriptionErrors.sol";
import {BalanceErrors} from "../errors/BalanceErrors.sol";
import {Balance} from "../storage/Balance.sol";
import {SubscriptionRegistry} from "../storage/SubscriptionRegistry.sol";
import {Subscription} from "../storage/Subscription.sol";
import {Fee} from "../storage/Fee.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";

/**
 * @title Module for liquidating unsolvent suscriptions.
 * @dev See ILiquidationsModule.
 */
contract LiquidationsModule is ILiquidationsModule {
    using SignedMath for int256;
    using Balance for Balance.Data;
    using SubscriptionRegistry for SubscriptionRegistry.Data;
    using Subscription for Subscription.Data;
    using Fee for Fee.Data;

    /// @inheritdoc	ILiquidationsModule
    function liquidate(bytes32 giverId, bytes32 creatorId) external override {
        SubscriptionUtil.validateCreator(giverId, creatorId);

        SubscriptionRegistry.Data storage subscription = SubscriptionRegistry
            .load(giverId, creatorId);

        if (!subscription.isSubscribed())
            revert SubscriptionErrors.NotSubscribed();

        bytes32 vaultId = subscription.getSubscriptionData().vaultId;

        if (!Balance.load(giverId, vaultId).canBeLiquidated())
            revert BalanceErrors.SolventUser();

        (uint256 subscriptionId, , , uint256 surplus) = _liquidateSubscription(
            giverId,
            creatorId,
            vaultId
        );

        emit SubscriptionLiquidated(
            giverId,
            creatorId,
            msg.sender,
            vaultId,
            subscriptionId,
            surplus
        );
    }

    /**
     * @dev Liquidate a subscription.
     *
     * Calls the finishSubscription function.
     *
     * Calls settleLostBalance function for compensating balance if the giver balance went negative.
     */
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
        int256 flow = Balance.load(giverId, vaultId).getFlow();

        // Finish subscription
        (subscriptionId, subscriptionRate, feeRate, ) = SubscriptionUtil
            .finishSubscription(giverId, creatorId);

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

    /**
     * @dev Compensate lost balances.
     *
     * This function is used when the subscription was not liquidated during the liquidation period.
     *
     * Due to this, the giver balance is now negative and the creator/treasury balance is incorrectly increased.
     *
     * Calculate the surplus in each case and settle the correct balance.
     *
     * The giver balance must end in zero.
     */
    function _settleLostBalance(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId,
        uint256 rate,
        uint256 feeRate,
        int256 flow
    ) private returns (uint256 surplus) {
        Balance.Data storage giverBalance = Balance.load(giverId, vaultId);

        // Get absolute values
        uint256 absoluteBalance = giverBalance.balanceOf().abs();
        uint256 totalFlow = flow.abs();

        // Decrease creator balance surplus
        uint256 subscriptionRateSurplus = (rate * absoluteBalance) / totalFlow;
        Balance.load(creatorId, vaultId).decrease(subscriptionRateSurplus);

        // Decrease treasury balance surplus
        uint256 feeRateSurplus = (feeRate * absoluteBalance) / totalFlow;
        bytes32 treasuryId = Fee.load().gratefulFeeTreasury;
        Balance.load(treasuryId, vaultId).decrease(feeRateSurplus);

        // Increase giver balance total surplus
        surplus = ((rate + feeRate) * absoluteBalance) / totalFlow;
        giverBalance.increase(surplus);

        assert(giverBalance.balanceOf() == 0);
    }
}
