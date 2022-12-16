// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Subscription} from "./Subscription.sol";

library SubscriptionId {
    using Subscription for Subscription.Data;

    struct Data {
        uint256 subscriptionId;
    }

    function load(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(
            abi.encode("SubscriptionId", giverId, creatorId, vaultId)
        );
        assembly {
            store.slot := s
        }
    }

    function set(Data storage self, uint256 subscriptionId) internal {
        self.subscriptionId = subscriptionId;
    }

    function getSubscriptionData(
        Data storage self
    ) internal view returns (Subscription.Data storage subscriptionData) {
        return Subscription.load(self.subscriptionId);
    }

    function isSubscribe(Data storage self) internal view returns (bool) {
        return Subscription.load(self.subscriptionId).isSubscribe();
    }
}
