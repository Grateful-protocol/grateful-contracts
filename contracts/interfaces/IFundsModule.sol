// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IFundsModule {
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
}
