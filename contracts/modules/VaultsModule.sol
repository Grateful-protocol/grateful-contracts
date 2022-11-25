// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {VaultStorage} from "../storage/VaultStorage.sol";
import {IVaultsModule} from "../interfaces/IVaultsModule.sol";
import {OwnableMixin} from "@synthetixio/core-contracts/contracts/ownership/OwnableMixin.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract VaultsModule is IVaultsModule, OwnableMixin {
    using VaultStorage for VaultStorage.Data;

    event VaultAdded(bytes32 id, address impl);

    function addVault(bytes32 id, address impl) external override onlyOwner {
        if (id == bytes32(0)) revert InputErrors.ZeroId();
        if (impl == address(0)) revert InputErrors.ZeroAddress();

        VaultStorage.Data storage store = VaultStorage.load(id);

        if (store.isVaultInitialized())
            revert VaultErrors.VaultAlreadyInitialized();

        uint256 decimalsNormalizer = 10**(20 - IERC4626(impl).decimals());

        store.set(impl, decimalsNormalizer);

        emit VaultAdded(id, impl);
    }

    function getVault(bytes32 id) external view override returns (address) {
        return VaultStorage.load(id).impl;
    }
}
