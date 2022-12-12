// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IFeesModule {
    function initializeFeesModule(
        bytes32 gratefulFeeTreasury,
        uint256 feePercentage
    ) external;
}
