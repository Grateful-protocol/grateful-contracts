// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";
import {FeesModule} from "../../../contracts/modules/FeesModule.sol";
import {InputErrors} from "../../../contracts/errors/InputErrors.sol";
import {OwnableStorage, AccessError} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";

contract FeesModuleTest is Test {
    FeesModule private feesModule;

    bytes32 private constant _SLOT_OWNABLE_STORAGE =
        keccak256(abi.encode("io.synthetix.core-contracts.Ownable"));

    /**
     * Fees Module events
     */
    event FeesInitialized(bytes32 gratefulFeeTreasury, uint256 feePercentage);

    event GratefulFeeTreasuryChanged(bytes32 oldTreasury, bytes32 newTreasury);

    event FeePercentageChanged(
        uint256 oldFeePercentage,
        uint256 newFeePercentage
    );

    /**
     * Deploy module and set owner
     */
    function setUp() public {
        feesModule = new FeesModule();

        // Set this contract as owner
        vm.store(
            address(feesModule),
            _SLOT_OWNABLE_STORAGE,
            bytes32(uint256(uint160(address(this))))
        );
    }

    /**
     * Initialize Fees Module
     */
    function test_InitializeFeesModule() public {
        bytes32 gratefulFeeTreasury = bytes32("test_gratefulFeeTreasury");
        uint256 feePercentage = 4;

        // Expect to emit FeesInitialized event
        vm.expectEmit(false, false, false, true, address(feesModule));
        emit FeesInitialized(gratefulFeeTreasury, feePercentage);

        // Check that data is not initialized
        assertEq(feesModule.getFeeTreasuryId(), 0);
        assertEq(feesModule.getFeePercentage(), 0);

        // Initialize module
        feesModule.initializeFeesModule(gratefulFeeTreasury, feePercentage);

        // Check that data is initialized
        assertEq(feesModule.getFeeTreasuryId(), gratefulFeeTreasury);
        assertEq(feesModule.getFeePercentage(), feePercentage);
    }

    function test_RevertWhen_InitializingWithBadTreasuryId() public {
        vm.expectRevert(InputErrors.ZeroId.selector);

        bytes32 gratefulFeeTreasury = bytes32(0);
        uint256 feePercentage = 4;

        feesModule.initializeFeesModule(gratefulFeeTreasury, feePercentage);
    }

    function test_RevertWhen_InitializingAsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessError.Unauthorized.selector,
                address(0)
            )
        );

        bytes32 gratefulFeeTreasury = bytes32("test_gratefulFeeTreasury");
        uint256 feePercentage = 4;
        feesModule.initializeFeesModule(gratefulFeeTreasury, feePercentage);
    }

    function test_RevertWhen_InitializingTwice() public {
        bytes32 gratefulFeeTreasury = bytes32("test_gratefulFeeTreasury");
        uint256 feePercentage = 4;

        // Initialize module
        feesModule.initializeFeesModule(gratefulFeeTreasury, feePercentage);

        // Expect AlreadyInitialized error in next call
        vm.expectRevert(InputErrors.AlreadyInitialized.selector);

        // Initialize module again
        feesModule.initializeFeesModule(gratefulFeeTreasury, feePercentage);
    }

    /**
     * Set grateful fee treasury
     */
    function test_SetGratefulFeeTreasury() public {
        bytes32 gratefulFeeTreasury = bytes32("test_gratefulFeeTreasury");

        // Expect to emit GratefulFeeTreasuryChanged event
        vm.expectEmit(false, false, false, true, address(feesModule));
        emit GratefulFeeTreasuryChanged(0, gratefulFeeTreasury);

        // Check that data is not set
        assertEq(feesModule.getFeeTreasuryId(), 0);

        // Set grateful treasury ID
        feesModule.setGratefulFeeTreasury(gratefulFeeTreasury);

        // Check that data is initialized
        assertEq(feesModule.getFeeTreasuryId(), gratefulFeeTreasury);
    }

    function test_RevertWhen_SetGratefulFeeTreasuryWithBadInput() public {
        vm.expectRevert(InputErrors.ZeroId.selector);

        bytes32 gratefulFeeTreasury = bytes32(0);

        feesModule.setGratefulFeeTreasury(gratefulFeeTreasury);
    }

    function test_RevertWhen_SetGratefulFeeTreasuryAsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessError.Unauthorized.selector,
                address(0)
            )
        );

        bytes32 gratefulFeeTreasury = bytes32("test_gratefulFeeTreasury");

        feesModule.setGratefulFeeTreasury(gratefulFeeTreasury);
    }

    /**
     * Set fee percentage
     */
    function test_SetFeePercentage() public {
        uint256 feePercentage = 4;

        // Expect to emit FeePercentageChanged event
        vm.expectEmit(false, false, false, true, address(feesModule));
        emit FeePercentageChanged(0, feePercentage);

        // Check that data is not set
        assertEq(feesModule.getFeePercentage(), 0);

        // Set fee percentage
        feesModule.setFeePercentage(feePercentage);

        // Check that data is initialized
        assertEq(feesModule.getFeePercentage(), feePercentage);
    }

    function test_RevertWhen_SetFeePercentageAsNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert(
            abi.encodeWithSelector(
                AccessError.Unauthorized.selector,
                address(0)
            )
        );

        uint256 feePercentage = 4;

        feesModule.setFeePercentage(feePercentage);
    }

    /**
     * Get fee rate
     */
    function test_GetFeeRate() public {
        uint256 feePercentage = 4;
        feesModule.setFeePercentage(feePercentage);

        uint256 rate = 38580246913580;
        uint256 actualRate = feesModule.getFeeRate(rate);
        uint256 expectedRate = (rate * 4) / 100;

        assertEq(actualRate, expectedRate);
    }
}
