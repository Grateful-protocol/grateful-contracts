// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Subscription} from "./Subscription.sol";

library SubscriptionId {
    struct Data {
        Subscription.Data subscriptionData;
    }

    function load(
        uint256 subscriptionId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("SubscriptionId", subscriptionId));
        assembly {
            store.slot := s
        }
    }

    function set(
        Data storage self,
        Subscription.Data storage subscriptionData
    ) internal {
        self.subscriptionData = subscriptionData;
    }
}
