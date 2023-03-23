// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";
import {Config} from "../../../contracts/storage/Config.sol";

contract ConfigTest is Test {
    using Config for Config.Data;

    Config.Data private config;

    function setUp() public {
        config = Config.load();
    }

    function test_SolvencyTimeRequired() public {
        config.setSolvencyTimeRequired(50);
        assertEq(config.solvencyTimeRequired, 50);
    }

    function test_LiquidationTimeRequired() public {
        config.setLiquidationTimeRequired(150);
        assertEq(config.liquidationTimeRequired, 150);
    }

    function test_IsInitialized() public {
        // Test that the configuration is not initialized by default
        assertFalse(config.isInitialized());

        // Initialize the liquidation time
        config.setLiquidationTimeRequired(150);
        assertTrue(config.isInitialized());
    }
}
