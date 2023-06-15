// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

/**
 * @title Stores the subscription data for each subscription.
 *
 * A subscription ID is a token ID minted in the Grateful subscription NFT.
 *
 * A subscription between a giver and a creator is unique.
 */
library Subscription {
    using SafeCast for uint256;

    struct Data {
        /**
         * @dev The subscription rate being streamed from giver to creator.
         *
         * Rate unit is 1e-20 per second.
         */
        uint96 rate;
        /**
         * @dev The fee rate being streamed from giver to treasury.
         *
         * Fee rate unit is 1e-20 per second.
         */
        uint80 feeRate;
        /**
         * @dev The last time the subscription was updated.
         *
         * This is stored when starting, updating or finishing it.
         */
        uint40 lastUpdate;
        /**
         * @dev The subscription total duration since creation.
         */
        uint40 duration;
        /**
         * @dev The creator ID who is receiving the subscription.
         */
        bytes32 creatorId;
        /**
         * @dev The vault balance that is being used in the subscription.
         */
        bytes32 vaultId;
    }

    /**
     * @dev Loads the subscription data from a subscription ID.
     */
    function load(
        uint256 subscriptionId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Subscription", subscriptionId));
        assembly {
            store.slot := s
        }
    }

    /**
     * @dev Starts a subscription.
     *
     * This is used the first time a subscription is created.
     */
    function start(
        Data storage self,
        uint256 rate,
        uint256 feeRate,
        bytes32 creatorId,
        bytes32 vaultId
    ) internal {
        self.rate = rate.toUint96();
        self.feeRate = feeRate.toUint80();
        self.lastUpdate = (block.timestamp).toUint40();
        self.creatorId = creatorId;
        self.vaultId = vaultId;
    }

    /**
     * @dev Updates a subscription.
     *
     * This is used if the giver wants to update the rate or the vault being used.
     *
     * Also is called if restarting an already created subscription.
     */
    function update(
        Data storage self,
        uint256 rate,
        uint256 feeRate,
        bytes32 vaultId
    ) internal {
        self.rate = rate.toUint96();
        self.feeRate = feeRate.toUint80();
        self.lastUpdate = (block.timestamp).toUint40();
        self.vaultId = vaultId;
    }

    /**
     * @dev Finishes a subscription.
     *
     * This is used when the giver wants to unsubscribe.
     */
    function finish(Data storage self) internal {
        uint256 elapsedTime = block.timestamp - self.lastUpdate;

        self.rate = 0;
        self.feeRate = 0;
        self.lastUpdate = (block.timestamp).toUint40();
        self.duration += (elapsedTime).toUint40();
    }

    /**
     * @dev Returns if the subscription is active.
     */
    function isSubscribed(Data storage self) internal view returns (bool) {
        return self.rate != 0;
    }

    /**
     * @dev Returns the current subscription duration.
     *
     * It is the stored duration plus the elapsed time since last update.
     */
    function getDuration(
        Data storage self
    ) internal view returns (uint256 duration) {
        uint256 lastUpdate = self.lastUpdate;
        if (lastUpdate == 0) return 0;

        if (isSubscribed(self)) {
            uint256 elapsedTime = block.timestamp - lastUpdate;
            duration = self.duration + (elapsedTime).toUint128();
        } else {
            duration = self.duration;
        }
    }
}
