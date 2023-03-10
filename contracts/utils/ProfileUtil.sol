// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Profile} from "../storage/Profile.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ProfileErrors} from "../errors/ProfileErrors.sol";

/**
 * @title Utils for interacting with ERC721 profiles.
 */
library ProfileUtil {
    using Profile for Profile.Data;

    /**
     * @dev Returns if the spender is approved or owner for the profile.
     */
    function _isApprovedOrOwner(
        address profile,
        address spender,
        uint256 tokenId,
        address owner
    ) private view returns (bool) {
        return (spender == owner ||
            IERC721(profile).isApprovedForAll(owner, spender) ||
            IERC721(profile).getApproved(tokenId) == spender);
    }

    /**
     * @dev Returns the profile owner.
     */
    function _getOwnerOf(
        address profile,
        uint256 tokenId
    ) private view returns (address) {
        return IERC721(profile).ownerOf(tokenId);
    }

    /**
     * @dev Make system and ERC721 validations:
     *
     * Validates if the profile is allowed for the system.
     *
     * Validates if the profile token ID exists.
     *
     * Returns the profile ID if the validation is succesful.
     */
    function validateExistenceAndGetProfile(
        address profile,
        uint256 tokenId
    ) internal view returns (bytes32 profileId, address owner) {
        // Profile.Data storage store = Profile.load(profile);

        // if (!store.isAllowed()) revert ProfileErrors.InvalidProfile(); // @audit check associated systems

        owner = _getOwnerOf(profile, tokenId);

        if (owner == address(0)) revert ProfileErrors.NonExistentProfile();

        profileId = Profile.getProfileId(profile, tokenId);
    }

    /**
     * @dev Returns system and ERC721 validations:
     *
     * Validates existence. See `validateExistenceAndGetProfile`.
     *
     * Checks if sender is approved or owner.
     *
     * Returns the profile ID, owner and if sender is approved.
     */
    function getApprovedAndProfileId(
        address profile,
        uint256 tokenId,
        address sender
    )
        internal
        view
        returns (bool isApproved, bytes32 profileId, address owner)
    {
        (profileId, owner) = validateExistenceAndGetProfile(profile, tokenId);

        isApproved = _isApprovedOrOwner(profile, sender, tokenId, owner);
    }

    /**
     * @dev Make system and ERC721 validations:
     *
     * Validates existence. See `validateExistenceAndGetProfile`.
     *
     * Gets profile ID, owner and approval flag.
     *
     * Validates if sender is approved or owner.
     */
    function validateAllowanceAndGetProfile(
        address profile,
        uint256 tokenId
    )
        internal
        view
        returns (bool isApproved, bytes32 profileId, address owner)
    {
        (isApproved, profileId, owner) = getApprovedAndProfileId(
            profile,
            tokenId,
            msg.sender
        );

        if (!isApproved) revert ProfileErrors.UnauthorizedProfile();
    }
}
