// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IBalancesModule} from "../interfaces/IBalancesModule.sol";
import {Balance} from "../storage/Balance.sol";

/**
 * @title Module for getting balances data.
 * @dev See IBalancesModule.
 */
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
        return Balance.load(profileId, vaultId).getFlow();
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

    /// @inheritdoc	IBalancesModule
    function getBalanceCurrentData(
        bytes32 profileId,
        bytes32 vaultId
    )
        external
        view
        override
        returns (
            int256 currentBalance,
            int256 flow,
            bool liquidable,
            uint256 timeLeft
        )
    {
        Balance.Data storage balance = Balance.load(profileId, vaultId);

        currentBalance = balance.balanceOf();
        flow = balance.getFlow();
        liquidable = balance.canBeLiquidated();
        timeLeft = balance.remainingTimeToZero();
    }
}
