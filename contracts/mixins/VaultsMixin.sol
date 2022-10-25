// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {VaultsStorage} from "../storage/VaultsStorage.sol";

contract VaultsMixin is VaultsStorage {
    function _isVaultInitialized(bytes32 id) internal view returns (bool) {
        return _vaultsStore().vaults[id].impl != address(0);
    }

    function _getVault(bytes32 id) internal view returns (address) {
        return _vaultsStore().vaults[id].impl;
    }
}
