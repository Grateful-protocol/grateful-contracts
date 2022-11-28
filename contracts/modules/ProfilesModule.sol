// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IProfilesModule} from "../interfaces/IProfilesModule.sol";
import {ProfileStorage} from "../storage/ProfileStorage.sol";
import {OwnableMixin} from "@synthetixio/core-contracts/contracts/ownership/OwnableMixin.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract ProfilesModule is IProfilesModule, OwnableMixin {
    using ProfileStorage for ProfileStorage.Data;

    event ProfileAllowed(address indexed profile);
    event ProfileDisallowed(address indexed profile);

    function allowProfile(address profile) external override onlyOwner {
        if (profile == address(0)) revert InputErrors.ZeroAddress();

        ProfileStorage.load(profile).allow();

        emit ProfileAllowed(profile);
    }

    function disallowProfile(address profile) external override onlyOwner {
        if (profile == address(0)) revert InputErrors.ZeroAddress();

        ProfileStorage.load(profile).disallow();

        emit ProfileDisallowed(profile);
    }

    function isProfileAllowed(address profile) external view returns (bool) {
        return ProfileStorage.load(profile).allowed;
    }

    function getProfileId(address profile, uint256 tokenId)
        external
        pure
        returns (bytes32)
    {
        return ProfileStorage.getProfileId(profile, tokenId);
    }
}
