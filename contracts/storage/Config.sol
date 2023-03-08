// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Config {
    bytes32 private constant CONFIG_STORAGE_SLOT =
        keccak256(abi.encode("Config"));

    struct Data {
        uint256 solvencyTimeRequired;
        uint256 liquidationTimeRequired;
    }

    function load() internal pure returns (Data storage store) {
        bytes32 s = CONFIG_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }

    function setSolvencyTimeRequired(
        Data storage self,
        uint256 solvencyTime
    ) internal {
        self.solvencyTimeRequired = solvencyTime;
    }

    function setLiquidationTimeRequired(
        Data storage self,
        uint256 liquidationTime
    ) internal {
        self.liquidationTimeRequired = liquidationTime;
    }

    function isInitialized(Data storage self) internal view returns (bool) {
        return self.liquidationTimeRequired != 0;
    }
}
