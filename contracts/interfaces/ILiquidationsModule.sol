// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ILiquidationsModule {
    /**
     * @notice Liquidate subscription from giver to creator.
     *
     * Requirements:
     *
     * - Giver and creator cannot be the same
     * - Creator cannot be Grateful treasury
     * - Giver must be subscribed to creator
     * - Only vaults initialized into the system
     * - Giver vault balance must be liquidable (the balance to remain solvent is less then `liquidationTimeRequired`)
     * - Emits a `SubscriptionFinished` and `SubscriptionLiquidated` events
     *
     * @param giverId The giver ID from the subscription to liquidate
     * @param creatorId The creator ID from the subscription to liquidate
     * @param liquidatorId The liquidator ID to send the liquidation rewards
     *
     */
    function liquidate(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 liquidatorId
    ) external;
}
