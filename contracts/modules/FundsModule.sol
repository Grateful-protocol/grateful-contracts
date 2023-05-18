// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IFundsModule} from "../interfaces/IFundsModule.sol";
import {VaultUtil} from "../utils/VaultUtil.sol";
import {InputErrors} from "../errors/InputErrors.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {BalanceErrors} from "../errors/BalanceErrors.sol";
import {Balance} from "../storage/Balance.sol";
import {Profile} from "../storage/Profile.sol";
import {ProfileRBAC} from "../storage/ProfileRBAC.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

/**
 * @title Module for depositing and withdrawing users funds.
 * @dev See IFundsModule.
 */
contract FundsModule is IFundsModule {
    using SafeCast for uint256;
    using Balance for Balance.Data;
    using Profile for Profile.Data;

    /// @inheritdoc	IFundsModule
    function depositFunds(
        bytes32 profileId,
        bytes32 vaultId,
        uint256 amount
    ) external {
        if (amount == 0) revert InputErrors.ZeroAmount();

        if (!VaultUtil.isVaultActive(vaultId))
            revert VaultErrors.InvalidVault();

        Profile.exists(profileId);

        uint256 shares = VaultUtil.deposit(vaultId, amount);

        Balance.load(profileId, vaultId).increase(shares);

        emit FundsDeposited(profileId, vaultId, amount, shares);
    }

    /// @inheritdoc	IFundsModule
    function withdrawFunds(
        bytes32 profileId,
        bytes32 vaultId,
        uint256 shares
    ) external {
        if (shares == 0) revert InputErrors.ZeroAmount();

        if (!VaultUtil.isVaultPaused(vaultId))
            revert VaultErrors.InvalidVault();

        Profile.loadProfileAndValidatePermission(
            profileId,
            ProfileRBAC._WITHDRAW_PERMISSION
        );

        Balance.Data storage store = Balance.load(profileId, vaultId);

        int256 balance = store.settle();
        if (balance < shares.toInt256())
            revert BalanceErrors.InsufficientBalance();

        store.decrease(shares);

        if (!store.canWithdraw()) revert BalanceErrors.InsolventUser();

        uint256 amountWithdrawn = VaultUtil.withdraw(vaultId, shares);

        emit FundsWithdrawn(profileId, vaultId, shares, amountWithdrawn);
    }
}
