// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ProfilesStorage {
    struct ProfilesStore {
        mapping(address => bool) allowedProfiles;
    }

    function _profilesStore()
        internal
        pure
        returns (ProfilesStore storage store)
    {
        assembly {
            // bytes32(uint(keccak256("io.grateful.profiles")) - 1)
            store.slot := 0x8e94ce3e9246405453eba14effe86b42c21fa3b582ba20c1c687158c699e0ebc
        }
    }
}
