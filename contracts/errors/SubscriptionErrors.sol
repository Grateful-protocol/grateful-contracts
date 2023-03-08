// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Subscriptions related errors.
 */
library SubscriptionErrors {
    /**
     * @notice Error when providing a creator that is similar to the giver or the treasury ID.
     *
     * Cases:
     * - `LiquidationsModule.liquidate()`
     * - `SubscriptionsModule.subscribe()`
     * - `SubscriptionsModule.unsubscribe()`
     *
     */
    error InvalidCreator();

    /**
     * @notice Error when providing a subscription rate that is not valid for the selected vault.
     *
     * Cases:
     * - `SubscriptionsModule.subscribe()`
     *
     */
    error InvalidRate();

    /**
     * @notice Error when trying to subscribe to a creator that already has an open subscription from the giver.
     *
     * Cases:
     * - `SubscriptionsModule.subscribe()`
     *
     */
    error AlreadySubscribed();

    /**
     * @notice Error when trying to unsubscribe from a creator that not has an open subscription from the giver.
     *
     * Cases:
     * - `LiquidationsModule.liquidate()`
     * - `SubscriptionsModule.unsubscribe()`
     *
     */
    error NotSubscribed();
}
