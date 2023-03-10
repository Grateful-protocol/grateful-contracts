// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IProfilesModule} from "../interfaces/IProfilesModule.sol";
import {Profile} from "../storage/Profile.sol";
import {ProfileRBAC} from "../storage/ProfileRBAC.sol";
import {INftModule} from "@synthetixio/core-modules/contracts/interfaces/INftModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {AssociatedSystem} from "@synthetixio/core-modules/contracts/storage/AssociatedSystem.sol";
import {SetUtil} from "@synthetixio/core-contracts/contracts/utils/SetUtil.sol";
import {InputErrors} from "../errors/InputErrors.sol";
import {ProfileErrors} from "../errors/ProfileErrors.sol";

/**
 * @title Module for managing profiles.
 * @dev See IProfilesModule.
 */
contract ProfilesModule is IProfilesModule {
    using SetUtil for SetUtil.AddressSet;
    using SetUtil for SetUtil.Bytes32Set;
    using Profile for Profile.Data;
    using ProfileRBAC for ProfileRBAC.Data;
    using AssociatedSystem for AssociatedSystem.Data;

    bytes32 private constant _GRATEFUL_PROFILE_NFT = "gratefulProfileNft";

    /// @inheritdoc	IProfilesModule
    function createProfile(address to) external override {
        address profileAddress = getGratefulProfileAddress();
        INftModule profile = INftModule(profileAddress);

        uint256 tokenId = profile.totalSupply() + 1;
        bytes32 profileId = Profile.getProfileId(profileAddress, tokenId);

        Profile.create(profileId, to);

        profile.safeMint(to, tokenId, "");

        emit ProfileCreated(to, profileAddress, tokenId, profileId);
    }

    /// @inheritdoc	IProfilesModule
    function notifyProfileTransfer(
        address to,
        uint256 tokenId
    ) external override {
        _onlyGratefulProfile();

        address profileAddress = getGratefulProfileAddress();
        bytes32 profileId = Profile.getProfileId(profileAddress, tokenId);

        Profile.Data storage profile = Profile.load(profileId);

        address[] memory permissionedAddresses = profile
            .rbac
            .permissionAddresses
            .values();

        for (uint i = 0; i < permissionedAddresses.length; i++) {
            profile.rbac.revokeAllPermissions(permissionedAddresses[i]);
        }

        profile.rbac.setOwner(to);
    }

    /// @inheritdoc	IProfilesModule
    function grantPermission(
        bytes32 profileId,
        bytes32 permission,
        address user
    ) external override {
        ProfileRBAC.isPermissionValid(permission);

        Profile.Data storage profile = Profile.loadProfileAndValidatePermission(
            profileId,
            ProfileRBAC._ADMIN_PERMISSION
        );

        profile.rbac.grantPermission(permission, user);

        emit PermissionGranted(profileId, permission, user, msg.sender);
    }

    /// @inheritdoc	IProfilesModule
    function revokePermission(
        bytes32 profileId,
        bytes32 permission,
        address user
    ) external override {
        Profile.Data storage profile = Profile.loadProfileAndValidatePermission(
            profileId,
            ProfileRBAC._ADMIN_PERMISSION
        );

        profile.rbac.revokePermission(permission, user);

        emit PermissionRevoked(profileId, permission, user, msg.sender);
    }

    /// @inheritdoc	IProfilesModule
    function renouncePermission(
        bytes32 profileId,
        bytes32 permission
    ) external override {
        if (!Profile.load(profileId).rbac.hasPermission(permission, msg.sender))
            revert ProfileErrors.PermissionNotGranted();

        Profile.load(profileId).rbac.revokePermission(permission, msg.sender);

        emit PermissionRevoked(profileId, permission, msg.sender, msg.sender);
    }

    /// @inheritdoc	IProfilesModule
    function getGratefulProfileAddress()
        public
        view
        override
        returns (address)
    {
        return AssociatedSystem.load(_GRATEFUL_PROFILE_NFT).proxy;
    }

    /// @inheritdoc	IProfilesModule
    function getProfilePermissions(
        bytes32 profileId
    )
        external
        view
        override
        returns (ProfilePermissions[] memory profilePerms)
    {
        ProfileRBAC.Data storage profileRbac = Profile.load(profileId).rbac;

        uint256 allPermissionsLength = profileRbac.permissionAddresses.length();
        profilePerms = new ProfilePermissions[](allPermissionsLength);
        for (uint256 i = 1; i <= allPermissionsLength; i++) {
            address permissionAddress = profileRbac.permissionAddresses.valueAt(
                i
            );
            profilePerms[i - 1] = ProfilePermissions({
                user: permissionAddress,
                permissions: profileRbac.permissions[permissionAddress].values()
            });
        }
    }

    /// @inheritdoc	IProfilesModule
    function hasPermission(
        bytes32 profileId,
        bytes32 permission,
        address user
    ) public view override returns (bool) {
        return Profile.load(profileId).rbac.hasPermission(permission, user);
    }

    /// @inheritdoc	IProfilesModule
    function isAuthorized(
        bytes32 profileId,
        bytes32 permission,
        address user
    ) public view override returns (bool) {
        return Profile.load(profileId).rbac.authorized(permission, user);
    }

    /// @inheritdoc	IProfilesModule
    function getProfileOwner(
        bytes32 profileId
    ) public view override returns (address) {
        return Profile.load(profileId).rbac.owner;
    }

    /// @inheritdoc	IProfilesModule
    function getProfileId(
        address profile,
        uint256 tokenId
    ) external pure override returns (bytes32) {
        return Profile.getProfileId(profile, tokenId);
    }

    function _onlyGratefulProfile() private view {
        if (msg.sender != address(getGratefulProfileAddress())) {
            revert ProfileErrors.OnlyGratefulProfileProxy();
        }
    }
}
