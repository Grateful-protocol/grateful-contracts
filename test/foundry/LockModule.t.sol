// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../../contracts/modules/LockModule.sol";

contract LockModuleTest is Test {
    LockModule public lock;
    uint256 immutable UNLOCK_TIME = block.timestamp + 1;

    function setUp() public {
        lock = new LockModule();
        lock.initialize(UNLOCK_TIME);
    }

    function testOwner() public {
        address owner = lock.getOwner();
        assertEq(owner, address(this));
    }

    function testUnlockTime() public {
        uint256 unlockTime = lock.getUnlockTime();
        assertEq(unlockTime, UNLOCK_TIME);
    }
}
