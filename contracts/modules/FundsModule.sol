// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IFundsModule} from "../interfaces/IFundsModule.sol";
import {ProfileUtil} from "../utils/ProfileUtil.sol";
import {VaultUtil} from "../utils/VaultUtil.sol";
import {InputErrors} from "../errors/InputErrors.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {BalanceErrors} from "../errors/BalanceErrors.sol";
import {Balance} from "../storage/Balance.sol";

contract FundsModule is IFundsModule {
    using Balance for Balance.Data;

    /**
     * @notice Emits the funds deposited from a profile into a vault
     * @param profileId The profile ID that made the deposit
     * @param vaultId The vault that the deposit where made into
     * @param amount The vault asset amount that was deposited
     * @param shares The shares minted from the vault (normalized to 20 decimals)
     */
    event FundsDeposited(
        bytes32 indexed profileId,
        bytes32 indexed vaultId,
        uint256 amount,
        uint256 shares
    );

    /**
     * @notice Emits the funds withdrawn from a profile from a vault
     * @param profileId The profile ID that made the withdrawal
     * @param vaultId The vault that received the withdrawal
     * @param shares The vault shares amount that were withdrawn
     * @param amountWithdrawn The vault asset amount that was withdrawn
     */
    event FundsWithdrawn(
        bytes32 indexed profileId,
        bytes32 indexed vaultId,
        uint256 shares,
        uint256 amountWithdrawn
    );

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

        bytes32 profileId = ProfileUtil.validateExistenceAndGetProfile(
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

        bytes32 profileId = ProfileUtil.validateAllowanceAndGetProfile(
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
