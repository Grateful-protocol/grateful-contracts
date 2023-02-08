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

    /**************************************************************************
     * Events
     *************************************************************************/

    /**
     * @notice Emits the data from the liquidated subscription
     * @param giverId The ID from the profile that was subscribed
     * @param creatorId The ID from the profile that was receiving the subscription
     * @param liquidatorId The ID from the profile that liquidated the subscription
     * @param vaultId The vault being used in the subscription
     * @param subscriptionId The subscription ID from the Grateful Subscription NFT
     * @param reward The reward that the liquidator receive
     * @param surplus The surplus from the balance that was compensated (if any)
     */
    event SubscriptionLiquidated(
        bytes32 indexed giverId,
        bytes32 indexed creatorId,
        bytes32 indexed liquidatorId,
        bytes32 vaultId,
        uint256 subscriptionId,
        uint256 reward,
        uint256 surplus
    );

    // Note: Duplicated event until library events are exportable (https://github.com/ethereum/solidity/pull/10996)
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
}
