// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ProfilesStorage} from "../storage/ProfilesStorage.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ProfileErrors} from "../errors/ProfileErrors.sol";

contract ProfilesMixin is ProfilesStorage {
    function _exists(address profile, uint256 tokenId)
        private
        view
        returns (bool)
    {
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

    function _getOwnerOf(address profile, uint256 tokenId)
        internal
        view
        returns (address)
    {
        return IERC721(profile).ownerOf(tokenId);
    }

    function _getProfileId(address profile, uint256 tokenId)
        internal
        pure
        returns (bytes32 profileId)
    {
        profileId = keccak256(abi.encode(profile, tokenId));
    }

    function _isProfileAllowed(address profile) internal view returns (bool) {
        return _profilesStore().allowedProfiles[profile];
    }

    function _validateExistenceAndGetProfile(address profile, uint256 tokenId)
        internal
        view
        returns (bytes32 profileId)
    {
        if (!_isProfileAllowed(profile)) revert ProfileErrors.InvalidProfile();

        if (!_exists(profile, tokenId))
            revert ProfileErrors.NonExistentProfile();

        profileId = _getProfileId(profile, tokenId);
    }

    function _validateAllowanceAndGetProfile(address profile, uint256 tokenId)
        internal
        view
        returns (bytes32 profileId)
    {
        if (!_isApprovedOrOwner(profile, msg.sender, tokenId))
            revert ProfileErrors.UnauthorizedProfile();

        profileId = _validateExistenceAndGetProfile(profile, tokenId);
    }
}
