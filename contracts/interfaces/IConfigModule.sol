// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Module for managing system configuration.
 */
interface IConfigModule {
    /**************************************************************************
     * Governance functions
     *************************************************************************/

    /**
     * @notice Initialize the grateful system configuration
     * @dev Only owner / Emits `ConfigInitialized` event
     * @param solvencyTimeRequired The time required to remain solvent (allow to start new susbscriptions or withdrawals)
     * @param liquidationTimeRequired The time required to avoid liquidation
     */
    function initializeConfigModule(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired
    ) external;

    /**
     * @notice Change the time required to remain solvent
     * @dev Only owner / Emits `SolvencyTimeChanged` event
     * @param newSolvencyTime The new time required to remain solvent
     */
    function setSolvencyTimeRequired(uint256 newSolvencyTime) external;

    /**
     * @notice Change the time required to avoid liquidation
     * @dev Only owner / Emits `LiquidationTimeChanged` event
     * @param newLiquidationTime The new time required to avoid liquidation
     */
    function setLiquidationTimeRequired(uint256 newLiquidationTime) external;

    /**************************************************************************
     * View functions
     *************************************************************************/

    /**
     * @notice Return the current solvency time required
     * @return Solvency time
     */
    function getSolvencyTimeRequired() external returns (uint256);

    /**
     * @notice Return the current liquidation time required
     * @return Liquidation time
     */
    function getLiquidationTimeRequired() external returns (uint256);

    /**************************************************************************
     * Events
     *************************************************************************/

    /**
     * @notice Emits the initial configuration
     * @param solvencyTimeRequired The time required to remain solvent
     * @param liquidationTimeRequired The time required to avoid liquidation
     */
    event ConfigInitialized(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired
    );

    /**
     * @notice Emits the solvency time change
     * @param oldSolvencyTime The old time required to remain solvent
     * @param newSolvencyTime The new time required to remain solvent
     */
    event SolvencyTimeChanged(uint256 oldSolvencyTime, uint256 newSolvencyTime);

    /**
     * @notice Emits the liquidation time change
     * @param oldLiquidationTime The old time required to avoid liquidation
     * @param newLiquidationTime The new time required to avoid liquidation
     */
    event LiquidationTimeChanged(
        uint256 oldLiquidationTime,
        uint256 newLiquidationTime
    );
}
