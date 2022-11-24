// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract VaultsStorage {
    struct Vault {
        // address proxy;
        address impl;
        uint256 decimalsNormalizer;
    }

    struct VaultsStore {
        mapping(bytes32 => Vault) vaults;
    }

    function _vaultsStore() internal pure returns (VaultsStore storage store) {
        assembly {
            // bytes32(uint(keccak256("io.grateful.vaults")) - 1)
            store.slot := 0xbd805175f2f074dfc6c7b38846407aab59d7a7ec645faad8753de6944638cab5
        }
    }
}
