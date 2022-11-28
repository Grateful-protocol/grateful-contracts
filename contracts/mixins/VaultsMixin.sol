// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Vault} from "../storage/Vault.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";

contract VaultsMixin {
    using SafeERC20 for IERC20;
    using Vault for Vault.Data;

    /**************************************************************************
     * Vault interaction functions
     *************************************************************************/

    function _depositFunds(bytes32 vaultId, uint256 amount)
        internal
        returns (uint256 shares)
    {
        Vault.Data storage store = Vault.load(vaultId);
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
    function _checkUserAllowance(IERC4626 vault, uint256 amount) internal view {
        uint256 allowance = IERC20(vault.asset()).allowance(
            msg.sender,
            address(this)
        );

        if (allowance < amount) revert VaultErrors.InsufficientAllowance();
    }

    function _isVaultInitialized(bytes32 id) internal view returns (bool) {
        return Vault.load(id).isInitialized();
    }
}
