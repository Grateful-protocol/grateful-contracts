// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Vault} from "../storage/Vault.sol";
import {IVaultsModule} from "../interfaces/IVaultsModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract VaultsModule is IVaultsModule {
    using Vault for Vault.Data;

    event VaultAdded(bytes32 id, address impl);

    function addVault(
        bytes32 id,
        address impl,
        uint256 minRate,
        uint256 maxRate
    ) external override {
        OwnableStorage.onlyOwner();

        if (id == bytes32(0)) revert InputErrors.ZeroId();
        if (impl == address(0)) revert InputErrors.ZeroAddress();

        Vault.Data storage store = Vault.load(id);

        if (store.isInitialized()) revert VaultErrors.VaultAlreadyInitialized();

        uint256 decimalsNormalizer = 10 ** (20 - IERC4626(impl).decimals());

        store.set(impl, decimalsNormalizer, minRate, maxRate);

        // @audit emit rates?
        emit VaultAdded(id, impl);
    }

    function getVault(bytes32 id) external view override returns (address) {
        return Vault.load(id).impl;
    }
}
