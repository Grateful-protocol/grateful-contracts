// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IProfilesModule} from "../interfaces/IProfilesModule.sol";
import {ProfilesMixin} from "../mixins/ProfilesMixin.sol";
import {OwnableMixin} from "@synthetixio/core-contracts/contracts/ownership/OwnableMixin.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract ProfilesModule is IProfilesModule, OwnableMixin, ProfilesMixin {
    event ProfileAllowed(address indexed profile);
    event ProfileDisallowed(address indexed profile);

    function allowProfile(address profile) external override onlyOwner {
        if (profile == address(0)) revert InputErrors.ZeroAddress();

        _profilesStore().allowedProfiles[profile] = true;

        emit ProfileAllowed(profile);
    }

    function disallowProfile(address profile) external override onlyOwner {
        if (profile == address(0)) revert InputErrors.ZeroAddress();

        _profilesStore().allowedProfiles[profile] = false;

        emit ProfileDisallowed(profile);
    }

    function isProfileAllowed(address profile) external view returns (bool) {
        return _isProfileAllowed(profile);
    }
}
