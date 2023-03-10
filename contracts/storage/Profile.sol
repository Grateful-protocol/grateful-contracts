// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Stores the system profiles configuration.
 */
library Profile {
    struct Data {
        /**
         * @dev Flag to check if a profile NFT is allowed to interact with the system.
         */
        bool allowed;
    }

    /**
     * @dev Loads the configuration for a profile NFT address.
     */
    function load(address profile) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Profile", profile));
        assembly {
            store.slot := s
        }
    }

    /**
     * @dev Allows a profile to interact with the system.
     */
    function allow(Data storage self) internal {
        self.allowed = true;
    }

    /**
     * @dev Disallows a profile from interacting with the system.
     */
    function disallow(Data storage self) internal {
        self.allowed = false;
    }

    /**
     * @dev Returns if a profile is allowed to interact with the system.
     */
    function isAllowed(Data storage self) internal view returns (bool) {
        return self.allowed;
    }

    /**
     * @dev Returns a profile ID.
     *
     * It is the hash from the profile NFT address and a token ID.
     *
     * It must be unique for the system.
     */
    function getProfileId(
        address profile,
        uint256 tokenId
    ) internal pure returns (bytes32 profileId) {
        profileId = keccak256(abi.encode(profile, tokenId));
    }
}
