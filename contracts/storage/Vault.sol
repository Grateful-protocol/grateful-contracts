// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Vault {
    struct Data {
        // address proxy;
        address impl;
        uint256 decimalsNormalizer;
        uint256 minRate;
        uint256 maxRate;
        bool paused;
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
        uint256 decimalsNormalizer,
        uint256 minRate,
        uint256 maxRate
    ) internal {
        self.impl = impl;
        self.decimalsNormalizer = decimalsNormalizer;
        self.minRate = minRate;
        self.maxRate = maxRate;
    }

    function setMinRate(Data storage self, uint256 minRate) internal {
        self.minRate = minRate;
    }

    function setMaxRate(Data storage self, uint256 maxRate) internal {
        self.maxRate = maxRate;
    }

    function pause(Data storage self) internal {
        self.paused = true;
    }

    function unpause(Data storage self) internal {
        self.paused = false;
    }

    function getVault(Data storage self) internal view returns (address) {
        return self.impl;
    }

    function isInitialized(Data storage self) internal view returns (bool) {
        return self.impl != address(0);
    }

    function isActive(Data storage self) internal view returns (bool) {
        return self.impl != address(0) && !self.paused;
    }

    function isRateValid(
        Data storage self,
        uint256 rate
    ) internal view returns (bool) {
        return (rate >= self.minRate) && (rate <= self.maxRate);
    }
}
