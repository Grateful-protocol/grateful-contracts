// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IBalancesModule} from "../interfaces/IBalancesModule.sol";
import {Balance} from "../storage/Balance.sol";

contract BalancesModule is IBalancesModule {
    using Balance for Balance.Data;

    /// @inheritdoc	IBalancesModule
    function balanceOf(
        bytes32 profileId,
        bytes32 vaultId
    ) external view override returns (int256) {
        return Balance.load(profileId, vaultId).balanceOf();
    }

    /// @inheritdoc	IBalancesModule
    function getFlow(
        bytes32 profileId,
        bytes32 vaultId
    ) external view override returns (int256) {
        return Balance.load(profileId, vaultId).flow;
    }

    /// @inheritdoc	IBalancesModule
    function canBeLiquidated(
        bytes32 profileId,
        bytes32 vaultId
    ) external view override returns (bool) {
        return Balance.load(profileId, vaultId).canBeLiquidated();
    }

    /// @inheritdoc	IBalancesModule
    function getRemainingTimeToZero(
        bytes32 profileId,
        bytes32 vaultId
    ) external view override returns (uint256) {
        return Balance.load(profileId, vaultId).remainingTimeToZero();
    }
}
