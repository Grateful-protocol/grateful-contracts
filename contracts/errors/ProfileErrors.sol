// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Profile related errors.
 */
library ProfileErrors {
    /**
     * @notice Error when providing a profile address that is not allowed by the system.
     *
     * Thrown in:
     * - `ProfileUtil.validateExistenceAndGetProfile()`
     *
     * Cases:
     * - `FundsModule.depositFunds()`
     * - `SubscriptionsModule.subscribe()`
     * - `SubscriptionsModule.unsubscribe()`
     *
     */
    error InvalidProfile();

    /**
     * @notice Error when a token ID from a profile has no owner.
     *
     * Thrown in:
     * - `ProfileUtil.validateExistenceAndGetProfile()`
     *
     * Cases:
     * - `FundsModule.depositFunds()`
     * - `SubscriptionsModule.subscribe()`
     * - `SubscriptionsModule.unsubscribe()`
     *
     */
    error NonExistentProfile();

    /**
     * @notice Error when a user is not approved or owner for a profile token ID.
     *
     * Thrown in:
     * - `ProfileUtil.validateAllowanceAndGetProfile()`
     *
     * Cases:
     * - `FundsModule.withdrawFunds()`
     * - `SubscriptionsModule.subscribe()`
     * - `SubscriptionsModule.unsubscribe()`
     *
     */
    error UnauthorizedProfile();

    /**
     * @notice Thrown when a profile attempts to renounce a permission that it didn't have.
     *
     * Cases:
     * - `ProfilesModules.renouncePermission()`
     *
     */
    error PermissionNotGranted();

    /**
     * @dev Thrown when the given target address does not have the given permission with the given profile.
     *
     * Thrown in:
     * - `Profile.loadProfileAndValidatePermission()`
     *
     * Cases:
     * - `FundsModule.withdrawFunds()`
     * - `SubscriptionsModule.subscribe()`
     * - `SubscriptionsModule.unsubscribe()`
     *
     */
    error PermissionDenied();

    /**
     * @dev Thrown when a profile cannot be found.
     *
     * Thrown in:
     * - `Profile.exists()`
     *
     * Cases:
     * - `FundsModule.depositFunds()`
     * - `SubscriptionsModule.subscribe()`
     * - `SubscriptionsModule.unsubscribe()`
     *
     */
    error ProfileNotFound();

    /**
     * @dev Thrown when a permission specified by a user does not exist or is invalid.
     *
     * Cases:
     *  - `ProfilesModules.grantPermission()`
     *
     */
    error InvalidPermission();

    /**
     * @notice Thrown when the profile interacting with the system is expected to be the associated profile token, but is not.
     *
     * Cases:
     * - `ProfilesModules.notifyProfileTransfer()`
     *
     */
    error OnlyGratefulProfileProxy();

    /**
     * @notice Thrown when trying to create a profile with a salt that was already used.
     *
     * Cases:
     * - `ProfilesModules.createProfile()`
     *
     */
    error ProfileAlreadyCreated();
}
