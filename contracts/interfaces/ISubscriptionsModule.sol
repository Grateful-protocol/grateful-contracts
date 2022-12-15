// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Subscription} from "../storage/Subscription.sol";

interface ISubscriptionsModule {
    function subscribe(
        address giverProfile,
        uint256 giverTokenId,
        address creatorProfile,
        uint256 creatorTokenID,
        bytes32 vaultId,
        uint256 subscriptionRate
    ) external;

    function getSubscription(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId
    ) external pure returns (Subscription.Data memory subscription);

    function getSubscriptionFrom(
        uint256 subscriptionId
    ) external view returns (Subscription.Data memory subscription);

    function getSubscriptionRate(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId
    ) external view returns (uint256);

    function isSubscribe(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 vaultId
    ) external view returns (bool);
}
