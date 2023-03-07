// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IGratefulSubscription {
    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        string memory uri
    ) external;

    function mint(address to) external;

    function getCurrentTokenId() external view returns (uint256);
}
