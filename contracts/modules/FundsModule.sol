// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IFundsModule} from "../interfaces/IFundsModule.sol";
import {ProfilesMixin} from "../mixins/ProfilesMixin.sol";
import {VaultsMixin} from "../mixins/VaultsMixin.sol";
import {InputErrors} from "../errors/InputErrors.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {BalanceErrors} from "../errors/BalanceErrors.sol";
import {Balance} from "../storage/Balance.sol";

contract FundsModule is IFundsModule, ProfilesMixin, VaultsMixin {
    using Balance for Balance.Data;

    event FundsDeposited(
        bytes32 indexed profileId,
        bytes32 indexed vaultId,
        uint256 amount,
        uint256 shares
    );

    event FundsWithdrawn(
        bytes32 indexed profileId,
        bytes32 indexed vaultId,
        uint256 shares,
        uint256 amountWithdrawn
    );

    function depositFunds(
        address profile,
        uint256 tokenId,
        bytes32 vaultId,
        uint256 amount
    ) external override {
        if (amount == 0) revert InputErrors.ZeroAmount();

        if (!_isVaultInitialized(vaultId)) revert VaultErrors.InvalidVault();

        bytes32 profileId = _validateExistenceAndGetProfile(profile, tokenId);

        uint256 shares = _deposit(vaultId, amount);

        Balance.load(profileId, vaultId).increase(shares);

        emit FundsDeposited(profileId, vaultId, amount, shares);
    }

    function withdrawFunds(
        address profile,
        uint256 tokenId,
        bytes32 vaultId,
        uint256 shares
    ) external override {
        if (shares == 0) revert InputErrors.ZeroAmount();

        if (!_isVaultInitialized(vaultId)) revert VaultErrors.InvalidVault();

        bytes32 profileId = _validateAllowanceAndGetProfile(profile, tokenId);

        Balance.Data storage store = Balance.load(profileId, vaultId);

        int256 balance = store.settle();
        if (balance < 0 || uint256(balance) < shares)
            revert BalanceErrors.InsufficientBalance();

        store.decrease(shares);

        if (!store.canWithdraw()) revert BalanceErrors.InsolventUser();

        uint256 amountWithdrawn = _withdraw(vaultId, shares);

        emit FundsWithdrawn(profileId, vaultId, shares, amountWithdrawn);
    }
}
