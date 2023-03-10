// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Module for depositing and withdrawing users funds.
 */
interface IFundsModule {
    /**************************************************************************
     * User functions
     *************************************************************************/

    /**
     * @notice Deposit funds into Grateful.
     *
     * Requirements:
     *
     * - Only profiles NFTs allowed on the system
     * - Only existing profile token ID
     * - Only vaults initialized into the system
     * - Emits `FundsDeposited` event
     *
     * @param profile The profile NFT address
     * @param tokenId The token ID from the profile NFT
     * @param vaultId The vault ID to deposit into
     * @param amount The amount of the vault asset to deposit
     */
    function depositFunds(
        address profile,
        uint256 tokenId,
        bytes32 vaultId,
        uint256 amount
    ) external;

    /**
     * @notice Withdraw funds from Grateful.
     *
     * Requirements:
     *
     * - Only profiles NFTs allowed on the system
     * - Only profile token ID owner or approved
     * - Only vaults initialized into the system
     * - Profile ID must have enough vault balance to withdraw
     * - Profile ID must have enough vault balance to remain solvent for `solvencyTimeRequired`
     * - Emits `FundsWithdrawn` event
     *
     * @param profile The profile NFT address
     * @param tokenId The token ID from the profile NFT
     * @param vaultId The vault ID to withdraw from
     * @param shares The amount of vault shares to withdraw
     */
    function withdrawFunds(
        address profile,
        uint256 tokenId,
        bytes32 vaultId,
        uint256 shares
    ) external;

    /**************************************************************************
     * Events
     *************************************************************************/

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
}
