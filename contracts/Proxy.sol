// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {UUPSProxyWithOwner} from "@synthetixio/core-contracts/contracts/proxy/UUPSProxyWithOwner.sol";

contract Proxy is UUPSProxyWithOwner {
    constructor(
        address firstImplementation,
        address initialOwner
    ) UUPSProxyWithOwner(firstImplementation, initialOwner) {}
}
