// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {VaultsMixin} from "../mixins/VaultsMixin.sol";
import {IVaultsModule} from "../interfaces/IVaultsModule.sol";
import {OwnableMixin} from "@synthetixio/core-contracts/contracts/ownership/OwnableMixin.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {VaultErrors} from "../errors/VaultErrors.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract VaultsModule is IVaultsModule, OwnableMixin, VaultsMixin {
    event VaultAdded(bytes32 id, address impl);

    function addVault(bytes32 id, address impl) external override onlyOwner {
        if (id == bytes32(0)) revert InputErrors.ZeroId();
        if (impl == address(0)) revert InputErrors.ZeroAddress();

        if (_isVaultInitialized(id))
            revert VaultErrors.VaultAlreadyInitialized();

        uint256 decimalsNormalizer = 10**(20 - IERC4626(impl).decimals());

        _vaultsStore().vaults[id] = Vault({
            impl: impl,
            decimalsNormalizer: decimalsNormalizer
        });

        emit VaultAdded(id, impl);
    }

    function getVault(bytes32 id) external view override returns (address) {
        return _getVault(id);
    }
}
