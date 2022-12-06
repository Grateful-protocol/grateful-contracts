// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IVaultsModule {
    function addVault(
        bytes32 id,
        address impl,
        uint256 minRate,
        uint256 maxRate
    ) external;

    function getVault(bytes32 id) external view returns (address);
}
