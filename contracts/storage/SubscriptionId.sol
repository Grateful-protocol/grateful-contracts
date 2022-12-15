// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Subscription} from "./Subscription.sol";

library SubscriptionId {
    using Subscription for Subscription.Data;

    struct Data {
        bytes32 subscriptionHash;
    }

    function load(
        uint256 subscriptionId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("SubscriptionId", subscriptionId));
        assembly {
            store.slot := s
        }
    }

    function set(Data storage self, bytes32 subscriptionHash) internal {
        self.subscriptionHash = subscriptionHash;
    }

    function getSubscriptionData(
        Data storage self
    ) internal view returns (Subscription.Data memory subscriptionData) {
        return Subscription.load(self.subscriptionHash);
    }
}
