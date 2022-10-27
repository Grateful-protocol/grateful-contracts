//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IProfilesModule {
    function setAllowedProfile(address profile, bool allowed) external;
}
