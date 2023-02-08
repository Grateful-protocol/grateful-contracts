// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Profile} from "../storage/Profile.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ProfileErrors} from "../errors/ProfileErrors.sol";

library ProfileUtil {
    using Profile for Profile.Data;

    function _exists(
        address profile,
        uint256 tokenId
    ) private view returns (bool) {
        return IERC721(profile).ownerOf(tokenId) != address(0);
    }

    function _isApprovedOrOwner(
        address profile,
        address spender,
        uint256 tokenId
    ) private view returns (bool) {
        address owner = IERC721(profile).ownerOf(tokenId);
        return (spender == owner ||
            IERC721(profile).isApprovedForAll(owner, spender) ||
            IERC721(profile).getApproved(tokenId) == spender);
    }

    function getOwnerOf(
        address profile,
        uint256 tokenId
    ) internal view returns (address) {
        return IERC721(profile).ownerOf(tokenId);
    }

    function validateExistenceAndGetProfile(
        address profile,
        uint256 tokenId
    ) internal view returns (bytes32 profileId) {
        Profile.Data storage store = Profile.load(profile);

        if (!store.isAllowed()) revert ProfileErrors.InvalidProfile();

        if (!_exists(profile, tokenId))
            revert ProfileErrors.NonExistentProfile();

        profileId = Profile.getProfileId(profile, tokenId);
    }

    function validateAllowanceAndGetProfile(
        address profile,
        uint256 tokenId
    ) internal view returns (bytes32 profileId) {
        if (!_isApprovedOrOwner(profile, msg.sender, tokenId))
            revert ProfileErrors.UnauthorizedProfile();

        profileId = validateExistenceAndGetProfile(profile, tokenId);
    }
}
