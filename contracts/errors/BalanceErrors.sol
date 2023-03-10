// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Balances related errors.
 */
library BalanceErrors {
    /**
     * @notice Error when a profile doesn't have enough balance to withdraw.
     *
     * Cases:
     * - `FundsModule.withdrawFunds()`
     *
     */
    error InsufficientBalance();

    /**
     * @notice Error when a profile want to subscribe or withdraw but will get insolvent.
     *
     * Cases:
     * - `FundsModule.withdrawFunds()`
     * - `SubscriptionsModule.subscribe()`
     *
     */
    error InsolventUser();

    /**
     * @notice Error when wanting to liquidate a profile subscription but is not liquidable.
     *
     * Cases:
     * - `LiquidationsModule.liquidate()`
     *
     */
    error SolventUser();
}
