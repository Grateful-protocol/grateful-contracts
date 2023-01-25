// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IProfilesModule {
    /**
     * @notice Allow profile NFT to be used on Grateful
     * @dev Only owner
     * @param profile The profile NFT address to allow
     */
    function allowProfile(address profile) external;

    /**
     * @notice Disallow profile NFT to be used on Grateful
     * @dev Only owner
     * @param profile The profile NFT address to disallow
     */
    function disallowProfile(address profile) external;

    /**
     * @notice Return if a profile is allowed
     * @return Allowed flag
     */
    function isProfileAllowed(address profile) external view returns (bool);

    /**
     * @notice Return a profile ID
     * @dev The profile ID is a hash from the profile address and the token ID
     * @param profile The profile NFT address
     * @param tokenId The token ID from the profile NFT
     * @return The profile ID
     */
    function getProfileId(
        address profile,
        uint256 tokenId
    ) external pure returns (bytes32);
}
