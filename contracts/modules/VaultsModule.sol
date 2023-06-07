// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Vault} from "../storage/Vault.sol";
import {IVaultsModule} from "../interfaces/IVaultsModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {InputErrors} from "../errors/InputErrors.sol";
import {VaultUtil} from "../utils/VaultUtil.sol";

/**
 * @title Module for managing vaults.
 * @dev See IVaultsModule.
 */
contract VaultsModule is IVaultsModule {
    using Vault for Vault.Data;

    /// @inheritdoc IVaultsModule
    function addVault(
        bytes32 vaultId,
        address impl,
        uint256 minRate,
        uint256 maxRate
    ) external override {
        OwnableStorage.onlyOwner();

        if (vaultId == bytes32(0)) revert InputErrors.ZeroId();
        if (impl == address(0)) revert InputErrors.ZeroAddress();

        Vault.Data storage vault = Vault.load(vaultId);

        if (vault.isInitialized()) revert InputErrors.AlreadyInitialized();

        uint256 decimalsNormalizer = 10 ** (20 - IERC4626(impl).decimals());

        vault.set(impl, decimalsNormalizer, minRate, maxRate);

        VaultUtil.approve(vaultId);

        emit VaultAdded(vaultId, impl, minRate, maxRate);
    }

    function _validateVaultPermissions(bytes32 vaultId) private view {
        OwnableStorage.onlyOwner();

        if (!Vault.load(vaultId).isInitialized())
            revert VaultErrors.VaultNotInitialized();
    }

    /// @inheritdoc IVaultsModule
    function setMinRate(bytes32 vaultId, uint256 newMinRate) external override {
        _validateVaultPermissions(vaultId);

        Vault.Data storage vault = Vault.load(vaultId);
        uint256 oldMinRate = vault.minRate;
        vault.setMinRate(newMinRate);

        emit MinRateChanged(vaultId, oldMinRate, newMinRate);
    }

    /// @inheritdoc IVaultsModule
    function setMaxRate(bytes32 vaultId, uint256 newMaxRate) external override {
        _validateVaultPermissions(vaultId);

        Vault.Data storage vault = Vault.load(vaultId);
        uint256 oldMaxRate = vault.maxRate;
        vault.setMaxRate(newMaxRate);

        emit MaxRateChanged(vaultId, oldMaxRate, newMaxRate);
    }

    /// @inheritdoc IVaultsModule
    function deactivateVault(bytes32 vaultId) external override {
        _validateVaultPermissions(vaultId);

        Vault.load(vaultId).deactivate();

        emit VaultDeactivated(vaultId);
    }

    /// @inheritdoc IVaultsModule
    function activateVault(bytes32 vaultId) external override {
        _validateVaultPermissions(vaultId);

        Vault.load(vaultId).activate();

        emit VaultActivated(vaultId);
    }

    /// @inheritdoc IVaultsModule
    function pauseVault(bytes32 vaultId) external override {
        _validateVaultPermissions(vaultId);

        Vault.load(vaultId).pause();

        emit VaultPaused(vaultId);
    }

    /// @inheritdoc IVaultsModule
    function unpauseVault(bytes32 vaultId) external override {
        _validateVaultPermissions(vaultId);

        Vault.load(vaultId).unpause();

        emit VaultUnpaused(vaultId);
    }

    /// @inheritdoc IVaultsModule
    function getVault(
        bytes32 vaultId
    ) external view override returns (address) {
        return Vault.load(vaultId).impl;
    }
}
