// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Config {
    struct Data {
        uint256 solvencyTimeRequired;
        uint256 liquidationTimeRequired;
        address gratefulSubscription;
    }

    function load() internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Config"));
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

    function setGratefulSubscription(
        Data storage self,
        address gratefulSubscription
    ) internal {
        self.gratefulSubscription = gratefulSubscription;
    }
}
