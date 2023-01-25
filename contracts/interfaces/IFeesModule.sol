// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IFeesModule {
    /**
     * @notice Initialize the grateful system fees
     * @dev Only owner / Emits `FeesInitialized` event
     * @param gratefulFeeTreasury The Grateful treasury profile ID
     * @param feePercentage The fee percentage to take from giver subscriptions
     */
    function initializeFeesModule(
        bytes32 gratefulFeeTreasury,
        uint256 feePercentage
    ) external;

    /**
     * @notice Return the current Grateful treasury profile ID
     * @return Treasury profile ID
     */
    function getFeeTreasuryId() external view returns (bytes32);

    /**
     * @notice Return the current fee percentage
     * @return Fee percentage
     */
    function getFeePercentage() external view returns (uint256);

    /**
     * @notice Return the current fee rate from a subscription rate
     * @param rate The subscription rate to take fee from
     * @return Fee rate
     */
    function getFeeRate(uint256 rate) external view returns (uint256);
}
