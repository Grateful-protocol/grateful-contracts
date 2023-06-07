// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Vault} from "../storage/Vault.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";

/**
 * @title Utils for interacting with ERC4626 vaults.
 */
library VaultUtil {
    using SafeERC20 for IERC20;
    using Vault for Vault.Data;

    /**************************************************************************
     * Vault interaction functions
     *************************************************************************/

    /**
     * @dev Makes a user deposit into a vault.
     *
     * The vault must be a ERC4626.
     *
     * The `amount` corresponds to vault assets. The `shares` to vault shares.
     *
     * The user must have allowed the amount of the vault asset to the system.
     *
     * The assets are first transfer to the system and the system makes the deposit.
     *
     * The vault shares are normalized to 20 decimals after the deposit is made.
     */
    function deposit(
        bytes32 vaultId,
        uint256 amount
    ) internal returns (uint256 shares) {
        Vault.Data storage vaultData = Vault.load(vaultId);
        IERC4626 vault = IERC4626(vaultData.impl);

        _checkUserAllowance(vault, amount);

        IERC20(vault.asset()).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        shares =
            vault.deposit({assets: amount, receiver: address(this)}) *
            vaultData.decimalsNormalizer;
    }

    /**
     * @dev Makes a user withdrawal from a vault.
     *
     * The vault must be a ERC4626.
     *
     * The `shares` corresponds to vault shares. The `amountWithdrawn` to vault assets.
     *
     * The assets are directly transferred to the user.
     *
     * The user shares are normalized to original decimals before the redeem is made.
     */
    function withdraw(
        bytes32 vaultId,
        uint256 shares
    ) internal returns (uint256 amountWithdrawn) {
        Vault.Data storage vaultData = Vault.load(vaultId);
        IERC4626 vault = IERC4626(vaultData.impl);

        uint256 normalizedShares = shares / vaultData.decimalsNormalizer;

        amountWithdrawn = vault.redeem({
            shares: normalizedShares,
            receiver: msg.sender,
            owner: address(this)
        });
    }

    function approve(bytes32 vaultId) internal {
        Vault.Data storage vaultData = Vault.load(vaultId);
        IERC4626 vault = IERC4626(vaultData.impl);

        IERC20(vault.asset()).approve(address(vault), type(uint256).max);
    }

    /**************************************************************************
     * View functions
     *************************************************************************/
    /**
     * @dev Checks user allowande to the system.
     *
     * The allowance check is made with the vault asset.
     */
    function _checkUserAllowance(IERC4626 vault, uint256 amount) private view {
        uint256 allowance = IERC20(vault.asset()).allowance(
            msg.sender,
            address(this)
        );

        if (allowance < amount) revert VaultErrors.InsufficientAllowance();
    }

    /**
     * @dev Returns if a vault is active.
     */
    function isVaultActive(bytes32 vaultId) internal view returns (bool) {
        return Vault.load(vaultId).isActive();
    }

    /**
     * @dev Returns if a vault is paused.
     */
    function isVaultPaused(bytes32 vaultId) internal view returns (bool) {
        return Vault.load(vaultId).isPaused();
    }

    /**
     * @dev Returns if a subscription rate is valid.
     */
    function isRateValid(
        bytes32 vaultId,
        uint256 rate
    ) internal view returns (bool) {
        return Vault.load(vaultId).isRateValid(rate);
    }

    /**
     * @dev Converts the rate from assets to shares.
     *
     * Receives a subscription rate denominated in assets.
     *
     * Returns a subscription rate denominated in shares.
     *
     * This is used because the relation between asset/share in a vault is changing.
     */
    function getCurrentRate(
        bytes32 vaultId,
        uint256 subscriptionRate
    ) internal view returns (uint256) {
        Vault.Data storage vaultData = Vault.load(vaultId);
        IERC4626 vault = IERC4626(vaultData.impl);

        return vault.convertToShares(subscriptionRate);
    }
}
