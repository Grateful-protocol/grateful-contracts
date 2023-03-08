// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IFundsModule} from "../interfaces/IFundsModule.sol";
import {ProfileUtil} from "../utils/ProfileUtil.sol";
import {VaultUtil} from "../utils/VaultUtil.sol";
import {InputErrors} from "../errors/InputErrors.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {BalanceErrors} from "../errors/BalanceErrors.sol";
import {Balance} from "../storage/Balance.sol";

/**
 * @title Module for depositing and withdrawing users funds.
 * @dev See IFundsModule.
 */
contract FundsModule is IFundsModule {
    using Balance for Balance.Data;

    /// @inheritdoc	IFundsModule
    function depositFunds(
        address profile,
        uint256 tokenId,
        bytes32 vaultId,
        uint256 amount
    ) external override {
        if (amount == 0) revert InputErrors.ZeroAmount();

        if (!VaultUtil.isVaultActive(vaultId))
            revert VaultErrors.InvalidVault();

        (bytes32 profileId, ) = ProfileUtil.validateExistenceAndGetProfile(
            profile,
            tokenId
        );

        uint256 shares = VaultUtil.deposit(vaultId, amount);

        Balance.load(profileId, vaultId).increase(shares);

        emit FundsDeposited(profileId, vaultId, amount, shares);
    }

    /// @inheritdoc	IFundsModule
    function withdrawFunds(
        address profile,
        uint256 tokenId,
        bytes32 vaultId,
        uint256 shares
    ) external override {
        if (shares == 0) revert InputErrors.ZeroAmount();

        if (!VaultUtil.isVaultActive(vaultId))
            revert VaultErrors.InvalidVault();

        (, bytes32 profileId, ) = ProfileUtil.validateAllowanceAndGetProfile(
            profile,
            tokenId
        );

        Balance.Data storage store = Balance.load(profileId, vaultId);

        int256 balance = store.settle();
        if (balance < 0 || uint256(balance) < shares)
            revert BalanceErrors.InsufficientBalance();

        store.decrease(shares);

        if (!store.canWithdraw()) revert BalanceErrors.InsolventUser();

        uint256 amountWithdrawn = VaultUtil.withdraw(vaultId, shares);

        emit FundsWithdrawn(profileId, vaultId, shares, amountWithdrawn);
    }
}
