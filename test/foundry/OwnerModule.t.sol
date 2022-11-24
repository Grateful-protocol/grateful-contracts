// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../../contracts/modules/OwnerModule.sol";

contract LockModuleTest is Test {
    OwnerModule public ownerModule;

    function setUp() public {
        ownerModule = new OwnerModule();
        ownerModule.initializeOwnerModule(address(this));
    }

    function testOwner() public {
        address owner = ownerModule.owner();
        assertEq(owner, address(this));
    }
}
