// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

library Subscription {
    using SafeCast for uint256;

    struct Data {
        uint256 rate;
        uint256 feeRate;
        uint128 lastUpdate;
        uint128 duration;
        uint256 totalRate;
    }

    function load(
        uint256 subscriptionId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Subscription", subscriptionId));
        assembly {
            store.slot := s
        }
    }

    function start(Data storage self, uint256 rate, uint256 feeRate) internal {
        self.rate = rate;
        self.feeRate = feeRate;
        self.lastUpdate = (block.timestamp).toUint128();
    }

    function finish(Data storage self) internal {
        uint256 elapsedTime = block.timestamp - self.lastUpdate;
        uint256 accumulatedRate = self.rate * elapsedTime;

        self.rate = 0;
        self.feeRate = 0;
        self.lastUpdate = (block.timestamp).toUint128();
        self.duration += (elapsedTime).toUint128();
        self.totalRate += accumulatedRate;
    }

    function isSubscribe(Data storage self) internal view returns (bool) {
        return self.rate != 0;
    }

    function getCurrentStatus(
        Data storage self
    ) internal view returns (uint256 duration, uint256 totalRate) {
        uint256 elapsedTime = block.timestamp - self.lastUpdate;
        uint256 accumulatedRate = self.rate * elapsedTime;

        duration = self.duration + (elapsedTime).toUint128();
        totalRate = self.totalRate + accumulatedRate;
    }
}
