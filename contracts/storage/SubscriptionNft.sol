// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Stores the data of the Grateful subscription NFT.
 */
library SubscriptionNft {
    bytes32 private constant _SUBSCRIPTION_NFT_STORAGE_SLOT =
        keccak256(abi.encode("SubscriptionNft"));

    struct Data {
        /**
         * @dev The current token ID from the NFT.
         *
         * This is then used as a subscription ID.
         */
        uint256 tokenIdCounter;
    }

    /**
     * @dev Loads the singleton storage info about the Grateful subscription NFT.
     */
    function load() internal pure returns (Data storage store) {
        bytes32 s = _SUBSCRIPTION_NFT_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }

    /**
     * @dev Increments the current token ID counter.
     */
    function incrementCounter(Data storage self) internal {
        self.tokenIdCounter++;
    }
}
