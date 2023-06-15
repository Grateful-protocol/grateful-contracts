// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Stores the vaults data used by the system.
 */
library Vault {
    struct Data {
        /**
         * @dev The vault address.
         *
         * Must be an ERC4626.
         */
        address impl;
        /**
         * @dev The extra decimals to be used to normalize all vaults.
         *
         * Normalized vaults have 20 decimals.
         *
         * This is used to minimize precision errors.
         */
        uint256 decimalsNormalizer;
        /**
         * @dev The minimum rate accepted by the vault.
         *
         * It is verified when a subcription is starting.
         */
        uint256 minRate;
        /**
         * @dev The maximum rate accepted by the vault.
         *
         * It is verified when a subcription is starting.
         */
        uint256 maxRate;
        /**
         * @dev Flag to pause the vault.
         */
        bool paused;
        /**
         * @dev Flag to deactivate the vault.
         */
        bool deactivated;
    }

    /**
     * @dev Loads the configuration for a vault.
     *
     * Vault ID is setup when initializing a vault.
     */
    function load(bytes32 vaultId) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Vault", vaultId));
        assembly {
            store.slot := s
        }
    }

    /**
     * @dev Sets the data for a vault.
     */
    function set(
        Data storage self,
        address impl,
        uint256 decimalsNormalizer,
        uint256 minRate,
        uint256 maxRate
    ) internal {
        self.impl = impl;
        self.decimalsNormalizer = decimalsNormalizer;
        self.minRate = minRate;
        self.maxRate = maxRate;
    }

    /**
     * @dev Sets the minimum rate for a vault.
     */
    function setMinRate(Data storage self, uint256 minRate) internal {
        self.minRate = minRate;
    }

    /**
     * @dev Sets the maximum rate for a vault.
     */
    function setMaxRate(Data storage self, uint256 maxRate) internal {
        self.maxRate = maxRate;
    }

    /**
     * @dev Pauses a vault.
     */
    function pause(Data storage self) internal {
        self.paused = true;
    }

    /**
     * @dev Unpauses a vault.
     */
    function unpause(Data storage self) internal {
        self.paused = false;
    }

    /**
     * @dev Deactivates a vault.
     */
    function deactivate(Data storage self) internal {
        self.deactivated = true;
    }

    /**
     * @dev Activates a vault.
     */
    function activate(Data storage self) internal {
        self.deactivated = false;
    }

    /**
     * @dev Returns if a vault has been initialized.
     */
    function isInitialized(Data storage self) internal view returns (bool) {
        return self.impl != address(0);
    }

    /**
     * @dev Returns if a vault is active to be used.
     */
    function isActive(Data storage self) internal view returns (bool) {
        return self.impl != address(0) && !self.paused && !self.deactivated;
    }

    /**
     * @dev Returns if a vault is paused.
     */
    function isPaused(Data storage self) internal view returns (bool) {
        return self.impl != address(0) && self.paused;
    }

    /**
     * @dev Returns if a subscription rate is valid for the current vault.
     */
    function isRateValid(
        Data storage self,
        uint256 rate
    ) internal view returns (bool) {
        return (rate >= self.minRate) && (rate <= self.maxRate);
    }
}
