// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Module for managing profiles.
 */
interface IProfilesModule {
    /**
     * @dev Data structure for tracking each user's permissions.
     */
    struct ProfilePermissions {
        /**
         * @dev The address for which all the permissions are granted.
         */
        address user;
        /**
         * @dev The array of permissions given to the associated address.
         */
        bytes32[] permissions;
    }

    /**************************************************************************
     * User functions
     *************************************************************************/

    /**
     * @notice Create a new profile
     * @dev Mint a Grateful Profile NFT / Emits `ProfileCreated` event
     * @param to The address to mint the profile NFT
     * @param salt The salt for creating a specific profile ID
     */
    function createProfile(address to, bytes32 salt) external;

    /**
     * @notice Grants `permission` to `user` for profile `profileId`.
     *
     * Requirements:
     *
     * - `msg.sender` must own the profile token with ID `profileId` or have the "admin" permission.
     * - Emits a `PermissionGranted` event.
     *
     * @param profileId The id of the profile that granted the permission.
     * @param permission The bytes32 identifier of the permission.
     * @param user The target address that received the permission.
     */
    function grantPermission(
        bytes32 profileId,
        bytes32 permission,
        address user
    ) external;

    /**
     * @notice Revokes `permission` from `user` for profile `profileId`.
     *
     * Requirements:
     *
     * - `msg.sender` must own the profile token with ID `profileId` or have the "admin" permission.
     * - Emits a `PermissionRevoked` event.
     *
     * @param profileId The id of the profile that revoked the permission.
     * @param permission The bytes32 identifier of the permission.
     * @param user The target address that no longer has the permission.
     */
    function revokePermission(
        bytes32 profileId,
        bytes32 permission,
        address user
    ) external;

    /**
     * @notice Revokes `permission` from `msg.sender` for profile `profileId`.
     *
     * Emits a `PermissionRevoked` event.
     *
     * @param profileId The id of the profile whose permission was renounced.
     * @param permission The bytes32 identifier of the permission.
     */
    function renouncePermission(bytes32 profileId, bytes32 permission) external;

    /**************************************************************************
     * Profile functions
     *************************************************************************/

    /**
     * @notice Called by GratefulProfile to notify the system when the profile token is transferred.
     *
     * Requirements:
     *
     * - `msg.sender` must be the profile token.
     *
     * @dev Resets user permissions and assigns ownership of the profile token to the new holder.
     * @param to The new holder of the profile NFT.
     * @param tokenId The token ID of the profile that was just transferred.
     */
    function notifyProfileTransfer(address to, uint256 tokenId) external;

    /**************************************************************************
     * View functions
     *************************************************************************/

    /**
     * @notice Returns the address for the Grateful profile used by the module.
     * @return profileNftToken The address of the profile token.
     */
    function getGratefulProfileAddress() external view returns (address);

    /**
     * @notice Returns an array of `ProfilePermission` for the provided `profileId`.
     * @param profileId The id of the profile whose permissions are being retrieved.
     * @return profilePerms An array of ProfilePermission objects describing the permissions granted to the profile.
     */
    function getProfilePermissions(
        bytes32 profileId
    ) external view returns (ProfilePermissions[] memory profilePerms);

    /**
     * @notice Returns `true` if `user` has been granted `permission` for profile `profileId`.
     * @param profileId The id of the profile whose permission is being queried.
     * @param permission The bytes32 identifier of the permission.
     * @param user The target address whose permission is being queried.
     * @return hasPermission A boolean with the response of the query.
     */
    function hasPermission(
        bytes32 profileId,
        bytes32 permission,
        address user
    ) external view returns (bool);

    /**
     * @notice Returns `true` if `target` is authorized to `permission` for profile `profileId`.
     * @param profileId The id of the profile whose permission is being queried.
     * @param permission The bytes32 identifier of the permission.
     * @param user The target address whose permission is being queried.
     * @return isAuthorized A boolean with the response of the query.
     */
    function isAuthorized(
        bytes32 profileId,
        bytes32 permission,
        address user
    ) external view returns (bool);

    /**
     * @notice Returns the address that owns a given profile, as recorded by the system.
     * @param profileId The profile id whose owner is being retrieved.
     * @return owner The owner of the given profile id.
     */
    function getProfileOwner(bytes32 profileId) external view returns (address);

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
    ) external view returns (bytes32);

    /**************************************************************************
     * Events
     *************************************************************************/

    /**
     * @notice Emits the new profile created
     * @param owner The new profile owner address
     * @param profileAddress The Grateful Profile NFT address
     * @param tokenId The Grateful Profile NFT token ID minted
     * @param profileId The profile ID
     */
    event ProfileCreated(
        address indexed owner,
        address indexed profileAddress,
        uint256 tokenId,
        bytes32 profileId
    );

    /**
     * @notice Emitted when `user` is granted `permission` by `sender` for profile `profileId`.
     * @param profileId The id of the profile that granted the permission.
     * @param permission The bytes32 identifier of the permission.
     * @param user The target address to whom the permission was granted.
     * @param sender The Address that granted the permission.
     */
    event PermissionGranted(
        bytes32 indexed profileId,
        bytes32 indexed permission,
        address indexed user,
        address sender
    );

    /**
     * @notice Emitted when `user` has `permission` renounced or revoked by `sender` for profile `profileId`.
     * @param profileId The id of the profile that has had the permission revoked.
     * @param permission The bytes32 identifier of the permission.
     * @param user The target address for which the permission was revoked.
     * @param sender The address that revoked the permission.
     */
    event PermissionRevoked(
        bytes32 indexed profileId,
        bytes32 indexed permission,
        address indexed user,
        address sender
    );
}
