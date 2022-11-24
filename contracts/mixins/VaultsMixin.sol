// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {VaultsStorage} from "../storage/VaultsStorage.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";

contract VaultsMixin is VaultsStorage {
    using SafeERC20 for IERC20;

    /**************************************************************************
     * Vault interaction functions
     *************************************************************************/

    function _depositFunds(bytes32 vaultId, uint256 amount)
        internal
        returns (uint256 shares)
    {
        Vault storage store = _vaultsStore().vaults[vaultId];
        IERC4626 vault = IERC4626(store.impl);

        _checkUserAllowance(vault, amount);

        IERC20(vault.asset()).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        IERC20(vault.asset()).approve(address(vault), amount);

        shares =
            vault.deposit(amount, address(this)) *
            store.decimalsNormalizer;
    }

    /**************************************************************************
     * View functions
     *************************************************************************/

    function _isVaultInitialized(bytes32 id) internal view returns (bool) {
        return _vaultsStore().vaults[id].impl != address(0);
    }

    function _getVault(bytes32 id) internal view returns (address) {
        return _vaultsStore().vaults[id].impl;
    }

    function _checkUserAllowance(IERC4626 vault, uint256 amount) internal view {
        uint256 allowance = IERC20(vault.asset()).allowance(
            msg.sender,
            address(this)
        );

        if (allowance < amount) revert VaultErrors.InsufficientAllowance();
    }
}
