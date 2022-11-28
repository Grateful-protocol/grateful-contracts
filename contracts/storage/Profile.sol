// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library Profile {
    struct Data {
        bool allowed;
    }

    function load(address profile) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Profile", profile));
        assembly {
            store.slot := s
        }
    }

    function allow(Data storage self) internal {
        self.allowed = true;
    }

    function disallow(Data storage self) internal {
        self.allowed = false;
    }

    function isAllowed(Data storage self) internal view returns (bool) {
        return self.allowed;
    }

    function getProfileId(address profile, uint256 tokenId)
        internal
        pure
        returns (bytes32 profileId)
    {
        profileId = keccak256(abi.encode(profile, tokenId));
    }
}
