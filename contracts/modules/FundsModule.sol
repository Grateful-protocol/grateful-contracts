// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IFundsModule} from "../interfaces/IFundsModule.sol";
import {ProfilesMixin} from "../mixins/ProfilesMixin.sol";
import {BalancesMixin} from "../mixins/BalancesMixin.sol";
import {VaultsMixin} from "../mixins/VaultsMixin.sol";
import {InputErrors} from "../errors/InputErrors.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";

contract FundsModule is
    IFundsModule,
    ProfilesMixin,
    VaultsMixin,
    BalancesMixin
{
    event FundsDeposited(
        bytes32 indexed profileId,
        bytes32 indexed vaultId,
        uint256 amount,
        uint256 shares
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

        uint256 shares = _depositFunds(vaultId, amount);

        _increaseProfileBalance(profileId, vaultId, shares);

        emit FundsDeposited(profileId, vaultId, amount, shares);
    }
}
