// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";
import {ConfigModule} from "../../../contracts/modules/ConfigModule.sol";
import {InputErrors} from "../../../contracts/errors/InputErrors.sol";
import {OwnableStorage, AccessError} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";

contract ConfigModuleTest is Test {
    ConfigModule private configModule;

    bytes32 private constant _SLOT_OWNABLE_STORAGE =
        keccak256(abi.encode("io.synthetix.core-contracts.Ownable"));

    /**
     * Config Module events
     */
    event ConfigInitialized(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired
    );

    event SolvencyTimeChanged(uint256 oldSolvencyTime, uint256 newSolvencyTime);

    event LiquidationTimeChanged(
        uint256 oldLiquidationTime,
        uint256 newLiquidationTime
    );

    /**
     * Deploy module and set owner
     */
    function setUp() public {
        configModule = new ConfigModule();

        // Set this contract as owner
        vm.store(
            address(configModule),
            _SLOT_OWNABLE_STORAGE,
            bytes32(uint256(uint160(address(this))))
        );
    }

    /**
     * Initialize Config Module
     */
    function test_InitializeConfigModule() public {
        uint256 solvencyTimeRequired = 50;
        uint256 liquidationTimeRequired = 150;

        // Expect to emit ConfigInitialized event
        vm.expectEmit(false, false, false, true, address(configModule));
        emit ConfigInitialized(solvencyTimeRequired, liquidationTimeRequired);

        // Check that data is not initialized
        assertEq(configModule.getSolvencyTimeRequired(), 0);
        assertEq(configModule.getLiquidationTimeRequired(), 0);

        // Initialize module
        configModule.initializeConfigModule(
            solvencyTimeRequired,
            liquidationTimeRequired
        );

        // Check that data is initialized
        assertEq(configModule.getSolvencyTimeRequired(), solvencyTimeRequired);
        assertEq(
            configModule.getLiquidationTimeRequired(),
            liquidationTimeRequired
        );
    }

    function test_RevertWhen_InitializingWithBadSolvencyTime() public {
        vm.expectRevert(InputErrors.ZeroTime.selector);

        uint256 solvencyTimeRequired = 0;
        uint256 liquidationTimeRequired = 10;

        configModule.initializeConfigModule(
            solvencyTimeRequired,
            liquidationTimeRequired
        );
    }

    function test_RevertWhen_InitializingWithBadLiquidationTime() public {
        vm.expectRevert(InputErrors.ZeroTime.selector);

        uint256 solvencyTimeRequired = 10;
        uint256 liquidationTimeRequired = 0;

        configModule.initializeConfigModule(
            solvencyTimeRequired,
            liquidationTimeRequired
        );
    }

    function test_RevertWhen_InitializingAsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessError.Unauthorized.selector,
                address(0)
            )
        );

        uint256 solvencyTimeRequired = 50;
        uint256 liquidationTimeRequired = 150;
        configModule.initializeConfigModule(
            solvencyTimeRequired,
            liquidationTimeRequired
        );
    }

    function test_RevertWhen_InitializingTwice() public {
        uint256 solvencyTimeRequired = 50;
        uint256 liquidationTimeRequired = 150;

        // Initialize module
        configModule.initializeConfigModule(
            solvencyTimeRequired,
            liquidationTimeRequired
        );

        // Expect AlreadyInitialized error in next call
        vm.expectRevert(InputErrors.AlreadyInitialized.selector);

        // Initialize module again
        configModule.initializeConfigModule(
            solvencyTimeRequired,
            liquidationTimeRequired
        );
    }

    /**
     * Set solvency time required
     */
    function test_SetSolvencyTimeRequired() public {
        uint256 solvencyTimeRequired = 50;

        // Expect to emit SolvencyTimeChanged event
        vm.expectEmit(false, false, false, true, address(configModule));
        emit SolvencyTimeChanged(0, solvencyTimeRequired);

        // Check that data is not set
        assertEq(configModule.getSolvencyTimeRequired(), 0);

        // Set solvency time
        configModule.setSolvencyTimeRequired(solvencyTimeRequired);

        // Check that data is initialized
        assertEq(configModule.getSolvencyTimeRequired(), solvencyTimeRequired);
    }

    function test_RevertWhen_SetSolvencyTimeWithBadInput() public {
        vm.expectRevert(InputErrors.ZeroTime.selector);

        uint256 solvencyTimeRequired = 0;

        configModule.setSolvencyTimeRequired(solvencyTimeRequired);
    }

    function test_RevertWhen_SetSolvencyTimeAsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessError.Unauthorized.selector,
                address(0)
            )
        );

        uint256 solvencyTimeRequired = 50;

        configModule.setSolvencyTimeRequired(solvencyTimeRequired);
    }

    /**
     * Set liquidation time required
     */
    function test_SetLiquidationTimeRequired() public {
        uint256 liquidationTimeRequired = 50;

        // Expect to emit LiquidationTimeChanged event
        vm.expectEmit(false, false, false, true, address(configModule));
        emit LiquidationTimeChanged(0, liquidationTimeRequired);

        // Check that data is not set
        assertEq(configModule.getLiquidationTimeRequired(), 0);

        // Set liquidation time
        configModule.setLiquidationTimeRequired(liquidationTimeRequired);

        // Check that data is initialized
        assertEq(
            configModule.getLiquidationTimeRequired(),
            liquidationTimeRequired
        );
    }

    function test_RevertWhen_SetLiquidationTimeWithBadInput() public {
        vm.expectRevert(InputErrors.ZeroTime.selector);

        uint256 liquidationTimeRequired = 0;

        configModule.setLiquidationTimeRequired(liquidationTimeRequired);
    }

    function test_RevertWhen_SetLiquidationTimeAsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessError.Unauthorized.selector,
                address(0)
            )
        );

        uint256 liquidationTimeRequired = 50;

        configModule.setLiquidationTimeRequired(liquidationTimeRequired);
    }
}
