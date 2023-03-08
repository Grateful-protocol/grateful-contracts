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
}
