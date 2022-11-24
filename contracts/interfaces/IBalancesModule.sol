// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IBalancesModule {
    function balanceOf(bytes32 profileId, bytes32 vaultId)
        external
        view
        returns (int256);
}
