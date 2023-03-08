// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IProfilesModule {
    /**************************************************************************
     * User functions
     *************************************************************************/

    /**
     * @notice Create a new profile
     * @dev Mint a Grateful Profile NFT / Emits `ProfileCreated` event
     * @param to The address to mint the profile NFT
     */
    function createProfile(address to) external;

    /**************************************************************************
     * Governance functions
     *************************************************************************/

    /**
     * @notice Allow profile NFT to be used on Grateful
     * @dev Only owner / Emits `ProfileAllowed` event
     * @param profile The profile NFT address to allow
     */
    function allowProfile(address profile) external;

    /**
     * @notice Disallow profile NFT to be used on Grateful
     * @dev Only owner / Emits `ProfileDisallowed` event
     * @param profile The profile NFT address to disallow
     */
    function disallowProfile(address profile) external;

    /**************************************************************************
     * View functions
     *************************************************************************/

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

    /**
     * @notice Return if the sender is approved or owner to the profile token ID, and also return the profile ID
     * @param profile The profile NFT address
     * @param tokenId The token ID from the profile NFT
     * @param sender The address to check wether if it is approved or owner
     * @return isApproved If it is approved or owner
     * @return profileId The profile ID
     */
    function getApprovedAndProfileId(
        address profile,
        uint256 tokenId,
        address sender
    ) external view returns (bool isApproved, bytes32 profileId);

    /**************************************************************************
     * Events
     *************************************************************************/

    /**
     * @notice Emits the new profile created
     * @param owner The new profile owner address
     * @param tokenId The Grateful Profile NFT token ID minted
     */
    event ProfileCreated(address indexed owner, uint256 tokenId);

    /**
     * @notice Emits the profile allowed
     * @param profile The profile address that was allowed
     */
    event ProfileAllowed(address indexed profile);

    /**
     * @notice Emits the profile disallowed
     * @param profile The profile address that was disallowed
     */
    event ProfileDisallowed(address indexed profile);
}
