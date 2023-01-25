// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Subscription} from "../storage/Subscription.sol";

interface ISubscriptionsModule {
    /**
     * @notice Start subscription from giver to creator.
     *
     * Requirements:
     *
     * - Only profiles NFTs allowed on the system
     * - Only giver profile token ID owner or approved
     * - Only existing creator profile token ID
     * - Giver and creator cannot be the same
     * - Creator cannot be Grateful treasury
     * - Giver cannot be already subscribed to creator
     * - Only vaults initialized into the system
     * - Rate must be valid (between min and max vault rate)
     * - Subscription NFT will be minted to current giver profile owner
     * - Giver profile ID must have enough vault balance to start a subscription
     * - Giver profile ID must have enough vault balance to remain solvent for `solvencyTimeRequired` after subscription starts
     * - Emits a `SubscriptionStarted` event
     *
     * @param giverProfile The giver profile NFT address
     * @param giverTokenId The giver token ID from the giver profile NFT
     * @param creatorProfile The creator profile NFT address
     * @param creatorTokenId The creator token ID from the creator profile NFT
     * @param vaultId The vault ID from where start the subscription
     * @param subscriptionRate The subscription rate from giver balance to creator balance (1e-20/second)
     *
     */
    function subscribe(
        address giverProfile,
        uint256 giverTokenId,
        address creatorProfile,
        uint256 creatorTokenId,
        bytes32 vaultId,
        uint256 subscriptionRate
    ) external;

    /**
     * @notice End subscription from giver to creator.
     *
     * Requirements:
     *
     * - Only profiles NFTs allowed on the system
     * - Only giver profile token ID owner or approved
     * - Only existing creator profile token ID
     * - Giver and creator cannot be the same
     * - Creator cannot be Grateful treasury
     * - Giver must be subscribed to creator
     * - Emits `SubscriptionFinished` event
     *
     * @param giverProfile The giver profile NFT address
     * @param giverTokenId The giver token ID from the giver profile NFT
     * @param creatorProfile The creator profile NFT address
     * @param creatorTokenId The creator token ID from the creator profile NFT
     */
    function unsubscribe(
        address giverProfile,
        uint256 giverTokenId,
        address creatorProfile,
        uint256 creatorTokenId
    ) external;

    /**
     * @notice Return subscription data from a subscription ID
     * @dev The subscription ID is a token ID from the Grateful Subcription NFT
     * @param subscriptionId The ID from where return the subscription data
     * @return subscription The subscription struct data
     */
    function getSubscription(
        uint256 subscriptionId
    ) external pure returns (Subscription.Data memory subscription);

    /**
     * @notice Return subscription data from giver and creator IDs
     * @param giverId The ID from where the subscription was created
     * @param creatorId The ID from whom is receiving the subscription
     * @return subscription The subscription struct data
     */
    function getSubscriptionFrom(
        bytes32 giverId,
        bytes32 creatorId
    ) external view returns (Subscription.Data memory subscription);

    /**
     * @notice Return the subscription ID from giver and creator IDs
     * @param giverId The ID from where the subscription was created
     * @param creatorId The ID from whom is receiving the subscription
     * @return The subscription ID
     */
    function getSubscriptionId(
        bytes32 giverId,
        bytes32 creatorId
    ) external view returns (uint256);

    /**
     * @notice Return the subscription and fee rates from a subscription ID
     * @param subscriptionId The ID from where return the subscription data
     * @return Subscription rate and fee rate
     */
    function getSubscriptionRates(
        uint256 subscriptionId
    ) external view returns (uint256, uint256);

    /**
     * @notice Return if a subscription is active from giver to creator
     * @param giverId The ID from where the subscription was created
     * @param creatorId The ID from whom is receiving the subscription
     * @return Subscribed flag
     */
    function isSubscribed(
        bytes32 giverId,
        bytes32 creatorId
    ) external view returns (bool);

    /**
     * @notice Return the total subscription duration since it was created
     * @param subscriptionId The ID from where return the subscription data
     * @return The current duration
     */
    function getSubscriptionDuration(
        uint256 subscriptionId
    ) external view returns (uint256);
}
