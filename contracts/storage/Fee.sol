// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

library Fee {
    using Math for uint256;

    bytes32 private constant _FEE_STORAGE_SLOT = keccak256(abi.encode("Fee"));

    struct Data {
        bytes32 gratefulFeeTreasury;
        uint256 feePercentage;
    }

    function load() internal pure returns (Data storage store) {
        bytes32 s = _FEE_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }

    function setGratefulFeeTreasury(
        Data storage self,
        bytes32 gratefulFeeTreasury
    ) internal {
        self.gratefulFeeTreasury = gratefulFeeTreasury;
    }

    function setFeePercentage(
        Data storage self,
        uint256 feePercentage
    ) internal {
        self.feePercentage = feePercentage;
    }

    function isInitialized(Data storage self) internal view returns (bool) {
        return self.gratefulFeeTreasury != bytes32(0);
    }

    function getFeeRate(
        Data storage self,
        uint256 subscriptionRate
    ) internal view returns (uint256) {
        return subscriptionRate.mulDiv(self.feePercentage, 100);
    }
}
