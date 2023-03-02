// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library SubscriptionNft {
    struct Data {
        uint256 tokenIdCounter;
    }

    function load() internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("SubscriptionNft"));
        assembly {
            store.slot := s
        }
    }

    function incrementCounter(Data storage self) internal {
        self.tokenIdCounter++;
    }
}
