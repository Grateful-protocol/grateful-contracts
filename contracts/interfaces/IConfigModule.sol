// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IConfigModule {
    function initializeConfigModule(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired,
        address gratefulSubscription
    ) external;

    function getSolvencyTimeRequired() external returns (uint256);

    function getLiquidationTimeRequired() external returns (uint256);

    function getGratefulSubscription() external returns (address);
}
