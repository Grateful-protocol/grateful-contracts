// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IVaultsModule {
    /**
     * @notice Add vault to Grateful system.
     *
     * Requirements:
     *
     * - Only owner
     * - ERC4626 compliant vault
     * - Emits `VaultAdded` event
     *
     * @param id The vault ID (any bytes32 defined by the owner)
     * @param impl The vault implementation address
     * @param minRate Minimum subscription rate allowed for this vault
     * @param maxRate Maximum subscription rate allowed for this vault
     */
    function addVault(
        bytes32 id,
        address impl,
        uint256 minRate,
        uint256 maxRate
    ) external;

    /**
     * @notice Return a vault address
     * @param id The vault ID from where to return the address
     * @return The vault address
     */
    function getVault(bytes32 id) external view returns (address);
}
