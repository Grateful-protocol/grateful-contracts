//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IProfilesModule {
    function allowProfile(address profile) external;

    function disallowProfile(address profile) external;

    function isProfileAllowed(address profile) external view returns (bool);
}
