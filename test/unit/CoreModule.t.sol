// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";
import {MainCoreModule} from "../../contracts/modules/CoreModule.sol";

contract CoreModuleTest is Test {
    MainCoreModule public coreModule;

    function setUp() public {
        coreModule = new MainCoreModule();
    }

    function testOwner() public {
        address owner = coreModule.owner();
        assertEq(owner, address(0));
    }
}
