// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Fee {
    bytes32 private constant FEE_STORAGE_SLOT = keccak256(abi.encode("Fee"));

    struct Data {
        bytes32 gratefulFeeTreasury;
        uint256 feePercentage;
    }

    function load() internal pure returns (Data storage store) {
        bytes32 s = FEE_STORAGE_SLOT;
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

    function getFeeRate(
        Data storage self,
        uint256 subscriptionRate
    ) internal view returns (uint256) {
        return (subscriptionRate * self.feePercentage) / 100;
    }
}
