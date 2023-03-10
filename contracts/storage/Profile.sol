// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ProfileRBAC} from "./ProfileRBAC.sol";
import {ProfileErrors} from "../errors/ProfileErrors.sol";

/**
 * @title Object for tracking profiles with access control.
 */
library Profile {
    using ProfileRBAC for ProfileRBAC.Data;

    struct Data {
        /**
         * @dev Hash identifier for the profile. Must be unique.
         */
        bytes32 id;
        /**
         * @dev Role based access control data for the profile.
         */
        ProfileRBAC.Data rbac;
    }

    /**
     * @dev Returns the profile stored at the specified profile id.
     */
    function load(bytes32 id) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Profile", id));
        assembly {
            store.slot := s
        }
    }

    /**
     * @dev Creates a profile for the given id, and associates it to the given owner.
     *
     * Note: Will not fail if the profile already exists, and if so, will overwrite the existing owner.
     * Whatever calls this internal function must first check that the profile doesn't exist before re-creating it.
     */
    function create(
        bytes32 id,
        address owner
    ) internal returns (Data storage profile) {
        profile = load(id);

        profile.id = id;
        profile.rbac.owner = owner;
    }

    /**
     * @dev Reverts if the profile does not exist with appropriate error. Otherwise, returns the profile.
     */
    function exists(bytes32 id) internal view returns (Data storage profile) {
        Data storage p = load(id);
        if (p.rbac.owner == address(0)) {
            revert ProfileErrors.ProfileNotFound();
        }

        return p;
    }

    /**
     * @dev Loads the Profile object for the specified profileId,
     * and validates that sender has the specified permission. These
     * are different actions but they are merged in a single function
     * because loading a profile and checking for a permission is a very
     * common use case in other parts of the code.
     */
    function loadProfileAndValidatePermission(
        bytes32 profileId,
        bytes32 permission
    ) internal view returns (Data storage profile) {
        profile = load(profileId);

        if (!profile.rbac.authorized(permission, msg.sender)) {
            revert ProfileErrors.PermissionDenied();
        }
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
