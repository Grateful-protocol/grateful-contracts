// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Subscription} from "../storage/Subscription.sol";

interface ISubscriptionsModule {
    function subscribe(
        address giverProfile,
        uint256 giverTokenId,
        address creatorProfile,
        uint256 creatorTokenId,
        bytes32 vaultId,
        uint256 subscriptionRate
    ) external;

    function unsubscribe(
        address giverProfile,
        uint256 giverTokenId,
        address creatorProfile,
        uint256 creatorTokenId
    ) external;

    function getSubscription(
        uint256 subscriptionId
    ) external pure returns (Subscription.Data memory subscription);

    function getSubscriptionFrom(
        bytes32 giverId,
        bytes32 creatorId
    ) external view returns (Subscription.Data memory subscription);

    function getSubscriptionId(
        bytes32 giverId,
        bytes32 creatorId
    ) external view returns (uint256);

    function getSubscriptionRates(
        uint256 subscriptionId
    ) external view returns (uint256, uint256);

    function isSubscribe(
        bytes32 giverId,
        bytes32 creatorId
    ) external view returns (bool);

    function getSubscriptionDuration(
        uint256 subscriptionId
    ) external view returns (uint256);
}
