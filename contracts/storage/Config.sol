// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Config {
    struct Data {
        uint256 solvencyTimeRequired;
    }

    function load() internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Config"));
        assembly {
            store.slot := s
        }
    }

    function set(Data storage self, uint256 solvencyTime) internal {
        self.solvencyTimeRequired = solvencyTime;
    }

    function getSolvencyTimeRequired(Data storage self)
        internal
        view
        returns (uint256)
    {
        return self.solvencyTimeRequired;
    }
}
