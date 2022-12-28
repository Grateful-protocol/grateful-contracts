// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {GratefulSubscription} from "../nfts/GratefulSubscription.sol";

library Config {
    struct Data {
        uint256 solvencyTimeRequired;
        uint256 liquidationTimeRequired;
        GratefulSubscription gratefulSubscription;
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
        self.gratefulSubscription = GratefulSubscription(gratefulSubscription);
    }

    function getSolvencyTimeRequired(
        Data storage self
    ) internal view returns (uint256) {
        return self.solvencyTimeRequired;
    }

    function getLiquidationTimeRequired(
        Data storage self
    ) internal view returns (uint256) {
        return self.liquidationTimeRequired;
    }

    function getGratefulSubscription(
        Data storage self
    ) internal view returns (GratefulSubscription) {
        return self.gratefulSubscription;
    }
}
