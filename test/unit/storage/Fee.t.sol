// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";
import {Fee} from "../../../contracts/storage/Fee.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract FeeTest is Test {
    using Fee for Fee.Data;
    using Math for uint256;

    Fee.Data private fee;

    function setUp() public {
        fee = Fee.load();
    }

    function test_SetGratefulFeeTreasury() public {
        bytes32 treasury = bytes32("test_grateful_fee_treasury");
        fee.setGratefulFeeTreasury(treasury);
        assertEq(fee.gratefulFeeTreasury, treasury);
    }

    function test_SetFeePercentage() public {
        uint256 feePercentage = 10;
        fee.setFeePercentage(feePercentage);
        assertEq(fee.feePercentage, feePercentage);
    }

    function test_IsNotInitialized() public {
        bool initialized = fee.isInitialized();
        assertFalse(initialized);
    }

    function test_IsInitialized() public {
        // Test that the fee configuration is not initialized by default
        assertFalse(fee.isInitialized());

        // Initialize the grateful fee treasury
        bytes32 treasury = bytes32("test_grateful_fee_treasury");
        fee.setGratefulFeeTreasury(treasury);
        assertTrue(fee.isInitialized());
    }

    function test_GetFeeRate() public {
        uint256 subscriptionRate = 100;
        uint256 feePercentage = 10;
        fee.setFeePercentage(feePercentage);
        uint256 feeRate = fee.getFeeRate(subscriptionRate);
        assertEq(feeRate, 10);
    }

    function testFuzz_GetFeeRate(
        uint256 subscriptionRate,
        uint256 feePercentage
    ) public {
        vm.assume(feePercentage <= 10);

        // set fee rate
        fee.setFeePercentage(feePercentage);
        uint256 expectedFeeRate = subscriptionRate.mulDiv(feePercentage, 100);
        uint256 actualFeeRate = fee.getFeeRate(subscriptionRate);

        assertEq(actualFeeRate, expectedFeeRate);
    }
}
