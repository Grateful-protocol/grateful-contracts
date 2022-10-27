// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IProfilesModule} from "../interfaces/IProfilesModule.sol";
import {ProfilesMixin} from "../mixins/ProfilesMixin.sol";
import {OwnableMixin} from "@synthetixio/core-contracts/contracts/ownership/OwnableMixin.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract ProfilesModule is IProfilesModule, OwnableMixin, ProfilesMixin {
    event ProfileAllowed(address indexed profile, bool allowed);

    function setAllowedProfile(address profile, bool allowed)
        external
        override
        onlyOwner
    {
        if (profile == address(0)) revert InputErrors.ZeroAddress();

        _profilesStore().allowedProfiles[profile] = allowed;

        emit ProfileAllowed(profile, allowed);
    }
}
