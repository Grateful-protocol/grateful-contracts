// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IGratefulSubscription {
    function safeMint(address to) external;

    function getCurrentTokenId() external view returns (uint256);
}
