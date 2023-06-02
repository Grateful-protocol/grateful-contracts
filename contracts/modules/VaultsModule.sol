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
        bytes32 id,
        address impl,
        uint256 minRate,
        uint256 maxRate
    ) external override {
        OwnableStorage.onlyOwner();

        if (id == bytes32(0)) revert InputErrors.ZeroId();
        if (impl == address(0)) revert InputErrors.ZeroAddress();

        Vault.Data storage vault = Vault.load(id);

        if (vault.isInitialized()) revert InputErrors.AlreadyInitialized();

        uint256 decimalsNormalizer = 10 ** (20 - IERC4626(impl).decimals());

        vault.set(impl, decimalsNormalizer, minRate, maxRate);

        VaultUtil.approve(id);

        emit VaultAdded(id, impl, minRate, maxRate);
    }

    function _validateVaultPermissions(bytes32 id) private view {
        OwnableStorage.onlyOwner();

        if (!Vault.load(id).isInitialized())
            revert VaultErrors.VaultNotInitialized();
    }

    /// @inheritdoc IVaultsModule
    function setMinRate(bytes32 id, uint256 newMinRate) external override {
        _validateVaultPermissions(id);

        Vault.Data storage vault = Vault.load(id);
        uint256 oldMinRate = vault.minRate;
        vault.setMinRate(newMinRate);

        emit MinRateChanged(id, oldMinRate, newMinRate);
    }

    /// @inheritdoc IVaultsModule
    function setMaxRate(bytes32 id, uint256 newMaxRate) external override {
        _validateVaultPermissions(id);

        Vault.Data storage vault = Vault.load(id);
        uint256 oldMaxRate = vault.maxRate;
        vault.setMaxRate(newMaxRate);

        emit MaxRateChanged(id, oldMaxRate, newMaxRate);
    }

    /// @inheritdoc IVaultsModule
    function deactivateVault(bytes32 id) external override {
        _validateVaultPermissions(id);

        Vault.load(id).deactivate();

        emit VaultDeactivated(id);
    }

    /// @inheritdoc IVaultsModule
    function activateVault(bytes32 id) external override {
        _validateVaultPermissions(id);

        Vault.load(id).activate();

        emit VaultActivated(id);
    }

    /// @inheritdoc IVaultsModule
    function pauseVault(bytes32 id) external override {
        _validateVaultPermissions(id);

        Vault.load(id).pause();

        emit VaultPaused(id);
    }

    /// @inheritdoc IVaultsModule
    function unpauseVault(bytes32 id) external override {
        _validateVaultPermissions(id);

        Vault.load(id).unpause();

        emit VaultUnpaused(id);
    }

    /// @inheritdoc IVaultsModule
    function getVault(bytes32 id) external view override returns (address) {
        return Vault.load(id).impl;
    }
}
