// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library VaultErrors {
    error VaultAlreadyInitialized();
    error VaultNotInitialized();
    error InvalidVault();
    error InsufficientAllowance();
}
