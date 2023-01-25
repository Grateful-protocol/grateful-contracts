// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IConfigModule {
    /**
     * @notice Initialize the grateful system configuration
     * @dev Only owner / Emits `ConfigInitialized` event
     * @param solvencyTimeRequired The time required to remain solvent (allow to start new susbscriptions or withdrawals)
     * @param liquidationTimeRequired The time required to avoid liquidation ()
     * @param gratefulSubscription The Grateful Subscription NFT address
     */
    function initializeConfigModule(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired,
        address gratefulSubscription
    ) external;

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

    /**
     * @notice Return the current Grateful Subscription NFT address
     * @return Grateful Subscription NFT address
     */
    function getGratefulSubscription() external returns (address);
}
