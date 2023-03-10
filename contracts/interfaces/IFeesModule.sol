// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Module for managing fees.
 */
interface IFeesModule {
    /**************************************************************************
     * Governance functions
     *************************************************************************/

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
     * @notice Change the grateful fee treasury
     * @dev Only owner / Emits `GratefulFeeTreasuryChanged` event
     * @param newTreasury The new grateful fee treasury
     */
    function setGratefulFeeTreasury(bytes32 newTreasury) external;

    /**
     * @notice Change the fee percentage
     * @dev Only owner / Emits `FeePercentageChanged` event
     * @param newFeePercentage The new fee percentage
     */
    function setFeePercentage(uint256 newFeePercentage) external;

    /**************************************************************************
     * View functions
     *************************************************************************/

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

    /**************************************************************************
     * Events
     *************************************************************************/

    /**
     * @notice Emits the initial fees configuration
     * @param gratefulFeeTreasury The Grateful treasury profile ID
     * @param feePercentage The fee percentage to take from giver subscriptions
     */
    event FeesInitialized(bytes32 gratefulFeeTreasury, uint256 feePercentage);

    /**
     * @notice Emits the grateful fee treasury change
     * @param oldTreasury The old grateful fee treasury
     * @param newTreasury The new grateful fee treasury
     */
    event GratefulFeeTreasuryChanged(bytes32 oldTreasury, bytes32 newTreasury);

    /**
     * @notice Emits the fee percentage change
     * @param oldFeePercentage The old fee percentage
     * @param newFeePercentage The new fee percentage
     */
    event FeePercentageChanged(
        uint256 oldFeePercentage,
        uint256 newFeePercentage
    );
}
