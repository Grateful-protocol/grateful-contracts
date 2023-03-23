// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Stores the data of the Grateful subscription NFT.
 */
library ProfileNft {
    struct Data {
        /**
         * @dev Hash identifier for the profile. Must be unique.
         */
        bytes32 profileId;
    }

    function load(
        address profile,
        uint256 tokenId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("ProfileNft", profile, tokenId));
        assembly {
            store.slot := s
        }
    }

    function set(Data storage self, bytes32 profileId) internal {
        self.profileId = profileId;
    }
}
