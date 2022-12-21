// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

library Subscription {
    using SafeCast for uint256;

    struct Data {
        uint256 rate;
        uint176 feeRate;
        uint40 lastUpdate;
        uint40 duration;
        bytes32 creatorId;
        bytes32 vaultId;
    }

    function load(
        uint256 subscriptionId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Subscription", subscriptionId));
        assembly {
            store.slot := s
        }
    }

    function start(
        Data storage self,
        uint256 rate,
        uint256 feeRate,
        bytes32 creatorId,
        bytes32 vaultId
    ) internal {
        self.rate = rate;
        self.feeRate = feeRate.toUint176();
        self.lastUpdate = (block.timestamp).toUint40();
        self.creatorId = creatorId;
        self.vaultId = vaultId;
    }

    function update(
        Data storage self,
        uint256 rate,
        uint256 feeRate,
        bytes32 vaultId
    ) internal {
        self.rate = rate;
        self.feeRate = feeRate.toUint176();
        self.lastUpdate = (block.timestamp).toUint40();
        self.vaultId = vaultId;
    }

    function finish(Data storage self) internal {
        uint256 elapsedTime = block.timestamp - self.lastUpdate;

        self.rate = 0;
        self.feeRate = 0;
        self.lastUpdate = (block.timestamp).toUint40();
        self.duration += (elapsedTime).toUint40();
    }

    function isSubscribed(Data storage self) internal view returns (bool) {
        return self.rate != 0;
    }

    function getDuration(
        Data storage self
    ) internal view returns (uint256 duration) {
        uint256 elapsedTime = block.timestamp - self.lastUpdate;

        duration = self.duration + (elapsedTime).toUint128();
    }
}
