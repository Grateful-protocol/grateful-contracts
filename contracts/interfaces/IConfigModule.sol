// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IConfigModule {
    function initializeConfigModule(
        uint256 solvencyTimeRequired,
        address gratefulSubscription
    ) external;
}
