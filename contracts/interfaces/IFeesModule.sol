// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IFeesModule {
    function initializeFeesModule(
        bytes32 gratefulFeeTreasury,
        uint256 feePercentage
    ) external;

    function getFeeTreasuryId() external view returns (bytes32);

    function getFeePercentage() external view returns (uint256);

    function getFeeRate(uint256 rate) external view returns (uint256);
}
