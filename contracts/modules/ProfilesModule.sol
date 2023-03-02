// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IProfilesModule} from "../interfaces/IProfilesModule.sol";
import {Profile} from "../storage/Profile.sol";
import {ProfileUtil} from "../utils/ProfileUtil.sol";
import {GratefulProfile} from "./associated-systems/GratefulProfile.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {AssociatedSystem} from "@synthetixio/core-modules/contracts/storage/AssociatedSystem.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract ProfilesModule is IProfilesModule {
    using Profile for Profile.Data;
    using AssociatedSystem for AssociatedSystem.Data;

    bytes32 private constant _GRATEFUL_PROFILE_NFT = "gratefulProfileNft";

    /// @inheritdoc	IProfilesModule
    function createProfile(address to) external override {
        GratefulProfile profile = GratefulProfile(
            AssociatedSystem.load(_GRATEFUL_PROFILE_NFT).proxy // @audit const name
        );

        uint256 tokenId = profile.totalSupply() + 1;

        profile.mint(to, tokenId);

        emit ProfileCreated(to, tokenId);
    }

    /// @inheritdoc	IProfilesModule
    function allowProfile(address profile) external override {
        OwnableStorage.onlyOwner();

        if (profile == address(0)) revert InputErrors.ZeroAddress();

        Profile.load(profile).allow();

        emit ProfileAllowed(profile);
    }

    /// @inheritdoc	IProfilesModule
    function disallowProfile(address profile) external override {
        OwnableStorage.onlyOwner();

        if (profile == address(0)) revert InputErrors.ZeroAddress();

        Profile.load(profile).disallow();

        emit ProfileDisallowed(profile);
    }

    /// @inheritdoc	IProfilesModule
    function isProfileAllowed(address profile) external view returns (bool) {
        return Profile.load(profile).allowed;
    }

    /// @inheritdoc	IProfilesModule
    function getProfileId(
        address profile,
        uint256 tokenId
    ) external pure returns (bytes32) {
        return Profile.getProfileId(profile, tokenId);
    }

    /// @inheritdoc	IProfilesModule
    function getApprovedAndProfileId(
        address profile,
        uint256 tokenId,
        address sender
    ) external view returns (bool isApproved, bytes32 profileId) {
        return ProfileUtil.getApprovedAndProfileId(profile, tokenId, sender);
    }
}
