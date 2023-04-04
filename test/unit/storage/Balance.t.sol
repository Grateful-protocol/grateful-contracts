// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";
import {Balance} from "../../../contracts/storage/Balance.sol";

contract BalanceTest is Test {
    using Balance for Balance.Data;

    Balance.Data private balance;

    bytes32 constant PROFILE_ID = bytes32("test_profileId");
    bytes32 constant VAULT_ID = bytes32("test_vaultId");

    function setUp() public {
        balance = Balance.load(PROFILE_ID, VAULT_ID);
    }

    function test_Increase() public {
        assertEq(balance.balance, 0);

        uint256 amount = 100;
        balance.increase(amount);

        assertEq(balance.balance, 100);
    }

    function test_Decrease() public {
        assertEq(balance.balance, 0);

        uint256 amount = 100;
        balance.decrease(amount);

        assertEq(balance.balance, -100);
    }
}
