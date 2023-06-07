// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Module for managing vaults.
 */
interface IVaultsModule {
    /**************************************************************************
     * Governance functions
     *************************************************************************/

    /**
     * @notice Add vault to Grateful system.
     *
     * Requirements:
     *
     * - Only owner
     * - ERC4626 compliant vault
     * - Emits `VaultAdded` event
     *
     * @param vaultId The vault ID (any bytes32 defined by the owner)
     * @param impl The vault implementation address
     * @param minRate Minimum subscription rate allowed for this vault
     * @param maxRate Maximum subscription rate allowed for this vault
     */
    function addVault(
        bytes32 vaultId,
        address impl,
        uint256 minRate,
        uint256 maxRate
    ) external;

    /**
     * @notice Change the vault minimum rate
     * @dev Only owner / Emits `MinRateChanged` event / Vault must be initialized
     * @param vaultId The vault ID to change the minimum rate
     * @param newMinRate The new minimum rate
     */
    function setMinRate(bytes32 vaultId, uint256 newMinRate) external;

    /**
     * @notice Change the vault maximum rate
     * @dev Only owner / Emits `MaxRateChanged` event / Vault must be initialized
     * @param vaultId The vault ID to change the maximum rate
     * @param newMaxRate The new maximum rate
     */
    function setMaxRate(bytes32 vaultId, uint256 newMaxRate) external;

    /**
     * @notice Pause a vault to avoid deposits, withdrawals or subscriptions
     * @dev Only owner / Emits `VaultPaused` event / Vault must be initialized
     * @param vaultId The vault ID to pause
     */
    function pauseVault(bytes32 vaultId) external;

    /**
     * @notice Unpause a vault to allow deposits, withdrawals or subscriptions
     * @dev Only owner / Emits `VaultUnpaused` event / Vault must be initialized
     * @param vaultId The vault ID to unpause
     */
    function unpauseVault(bytes32 vaultId) external;

    /**
     * @notice Deactivate a vault to avoid new deposits or subscriptions
     * @dev Only owner / Emits `VaultDeactivated` event / Vault must be initialized
     * @param vaultId The vault ID to pause
     */
    function deactivateVault(bytes32 vaultId) external;

    /**
     * @notice Activate a vault to allow new deposits or subscriptions
     * @dev Only owner / Emits `VaultActivated` event / Vault must be initialized
     * @param vaultId The vault ID to unpause
     */
    function activateVault(bytes32 vaultId) external;

    /**************************************************************************
     * View functions
     *************************************************************************/

    /**
     * @notice Return a vault address
     * @param vaultId The vault ID from where to return the address
     * @return The vault address
     */
    function getVault(bytes32 vaultId) external view returns (address);

    /**************************************************************************
     * Events
     *************************************************************************/

    /**
     * @notice Emits the vault added data
     * @param vaultId The vault ID (any bytes32 defined by the owner)
     * @param impl The vault implementation address
     * @param minRate The vault minimum rate
     * @param maxRate The vault maximum rate
     */
    event VaultAdded(
        bytes32 indexed vaultId,
        address impl,
        uint256 minRate,
        uint256 maxRate
    );

    /**
     * @notice Emits the vault minimum rate change
     * @param vaultId The vault ID
     * @param oldMinRate The old minimum rate
     * @param newMinRate The new minimum rate
     */
    event MinRateChanged(
        bytes32 indexed vaultId,
        uint256 oldMinRate,
        uint256 newMinRate
    );

    /**
     * @notice Emits the vault maximum rate change
     * @param vaultId The vault ID
     * @param oldMaxRate The old maximum rate
     * @param newMaxRate The new maximum rate
     */
    event MaxRateChanged(
        bytes32 indexed vaultId,
        uint256 oldMaxRate,
        uint256 newMaxRate
    );

    /**
     * @notice Emits when a vault is paused
     * @param vaultId The vault ID
     */
    event VaultPaused(bytes32 indexed vaultId);

    /**
     * @notice Emits when a vault is unpaused
     * @param vaultId The vault ID
     */
    event VaultUnpaused(bytes32 indexed vaultId);

    /**
     * @notice Emits when a vault is deactivated
     * @param vaultId The vault ID
     */
    event VaultDeactivated(bytes32 indexed vaultId);

    /**
     * @notice Emits when a vault is activated
     * @param vaultId The vault ID
     */
    event VaultActivated(bytes32 indexed vaultId);
}
