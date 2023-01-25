// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {MainCoreModule} from "../../contracts/modules/CoreModule.sol";

contract OwnerModuleTest is Test {
    MainCoreModule public coreModule;

    function setUp() public {
        coreModule = new MainCoreModule();
        coreModule.initializeOwnerModule(address(this));
    }

    function testOwner() public {
        address owner = coreModule.owner();
        assertEq(owner, address(this));
    }
}
