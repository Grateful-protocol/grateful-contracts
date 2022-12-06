// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISubscriptionsModule {
    function subscribe(
        address giverProfile,
        uint256 giverTokenId,
        address creatorProfile,
        uint256 creatorTokenID,
        bytes32 vaultId,
        uint256 subscriptionRate
    ) external;
}
