// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Subscription} from "./Subscription.sol";

/**
 * @title Stores the relation from a giver/creator to a subscription ID.
 */
library SubscriptionRegistry {
    using Subscription for Subscription.Data;

    struct Data {
        /**
         * @dev The subscription ID that represents the subscription from giver to creator.
         *
         * A subscription ID is a token ID minted in the Grateful subscription NFT.
         *
         * A subscription ID between a giver and a creator is unique.
         */
        uint256 subscriptionId;
    }

    /**
     * @dev Loads the subscription ID from the giver/creator tuple.
     */
    function load(
        bytes32 giverId,
        bytes32 creatorId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(
            abi.encode("SubscriptionRegistry", giverId, creatorId)
        );
        assembly {
            store.slot := s
        }
    }

    /**
     * @dev Sets the subscription ID.
     */
    function set(Data storage self, uint256 subscriptionId) internal {
        self.subscriptionId = subscriptionId;
    }

    /**
     * @dev Gets the subscription data stored in the subscription storage.
     */
    function getSubscriptionData(
        Data storage self
    ) internal view returns (Subscription.Data storage subscriptionData) {
        return Subscription.load(self.subscriptionId);
    }

    /**
     * @dev Returns if the subscription is active.
     */
    function isSubscribed(Data storage self) internal view returns (bool) {
        return Subscription.load(self.subscriptionId).isSubscribed();
    }

    /**
     * @dev Returns if the subscription already exists.
     */
    function exists(Data storage self) internal view returns (bool) {
        return self.subscriptionId != 0;
    }
}
