// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Vault {
    struct Data {
        // address proxy;
        address impl;
        uint256 decimalsNormalizer;
    }

    function load(bytes32 id) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Vault", id));
        assembly {
            store.slot := s
        }
    }

    function set(
        Data storage self,
        address impl,
        uint256 decimalsNormalizer
    ) internal {
        self.impl = impl;
        self.decimalsNormalizer = decimalsNormalizer;
    }

    function getVault(Data storage self) internal view returns (address) {
        return self.impl;
    }

    function isInitialized(Data storage self) internal view returns (bool) {
        return self.impl != address(0);
    }
}
