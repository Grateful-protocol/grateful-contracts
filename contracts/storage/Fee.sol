// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title Stores the system fees configuration.
 *
 * There can only be one fee treasury.
 */
library Fee {
    using Math for uint256;

    bytes32 private constant _FEE_STORAGE_SLOT = keccak256(abi.encode("Fee"));

    struct Data {
        /**
         * @dev Treasury ID where to receive the fees.
         *
         * The treasury must be a grateful profile because the fees are treated like a subscription.
         */
        bytes32 gratefulFeeTreasury;
        /**
         * @dev Fee percentage to be taken from a subscription rate.
         *
         * Can be zero if wanted.
         */
        uint256 feePercentage;
    }

    /**
     * @dev Loads the singleton storage info about the fees.
     */
    function load() internal pure returns (Data storage store) {
        bytes32 s = _FEE_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }

    /**
     * @dev Sets the grateful fee treasury where fees are collected.
     */
    function setGratefulFeeTreasury(
        Data storage self,
        bytes32 gratefulFeeTreasury
    ) internal {
        self.gratefulFeeTreasury = gratefulFeeTreasury;
    }

    /**
     * @dev Sets the fee percentage taken from the rate subscription.
     */
    function setFeePercentage(
        Data storage self,
        uint256 feePercentage
    ) internal {
        self.feePercentage = feePercentage;
    }

    /**
     * @dev Returns if the fee storage is initialized.
     */
    function isInitialized(Data storage self) internal view returns (bool) {
        return self.gratefulFeeTreasury != bytes32(0);
    }

    /**
     * @dev Returns the fee rate from a subscription rate.
     *
     * The fee rate is calculated as a percentage from the `subscriptionRate`.
     *
     * feeRate = (subscriptionRate * feePercentage) / 100
     */
    function getFeeRate(
        Data storage self,
        uint256 subscriptionRate
    ) internal view returns (uint256) {
        return subscriptionRate.mulDiv(self.feePercentage, 100);
    }
}
