// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Vault related errors.
 */
library VaultErrors {
    /**
     * @notice Error when trying to change a vault that has not been initialized.
     *
     * Cases:
     * - `VaultsModule._validateVaultPermissions()`
     *
     */
    error VaultNotInitialized();

    /**
     * @notice Error when trying to use a vault that is not active (not initialized or paused).
     *
     * Cases:
     * - `FundsModule.depositFunds()`
     * - `FundsModule.withdrawFunds()`
     * - `SubscriptionModule.subscribe()`
     *
     */
    error InvalidVault();

    /**
     * @notice Error when trying to deposit into a vault but the user has not allow the token to the system.
     *
     * Cases:
     * - `FundsModule.depositFunds()`
     *
     */
    error InsufficientAllowance();
}
