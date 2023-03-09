// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Stores the system configuration.
 */
library Config {
    bytes32 private constant _CONFIG_STORAGE_SLOT =
        keccak256(abi.encode("Config"));

    struct Data {
        /**
         * @dev Time required to remain solvent.
         *
         * This is used to know if a profile is allow to open new subscriptions or making withdrawals.
         *
         * If the profile balance does not cover this future time, it is insolvent.
         */
        uint256 solvencyTimeRequired;
        /**
         * @dev Time required to allow making liquidations.
         *
         * This is used to know if a profile is in a liquidation period.
         *
         * If the profile balance does not cover this future time, it can be liquidated.
         */
        uint256 liquidationTimeRequired;
    }

    /**
     * @dev Loads the singleton storage info about the system.
     */
    function load() internal pure returns (Data storage store) {
        bytes32 s = _CONFIG_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }

    /**
     * @dev Sets the system solvency time.
     */
    function setSolvencyTimeRequired(
        Data storage self,
        uint256 solvencyTime
    ) internal {
        self.solvencyTimeRequired = solvencyTime;
    }

    /**
     * @dev Sets the system liquidation time.
     */
    function setLiquidationTimeRequired(
        Data storage self,
        uint256 liquidationTime
    ) internal {
        self.liquidationTimeRequired = liquidationTime;
    }

    /**
     * @dev Returns if the config storage is initialized.
     */
    function isInitialized(Data storage self) internal view returns (bool) {
        return self.liquidationTimeRequired != 0;
    }
}
