// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IGratefulSubscription} from "../../interfaces/IGratefulSubscription.sol";
import {NftModule} from "@synthetixio/core-modules/contracts/modules/NftModule.sol";
import {ERC721} from "@synthetixio/core-contracts/contracts/token/ERC721.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {SubscriptionNft} from "../../storage/SubscriptionNft.sol";

contract GratefulSubscription is IGratefulSubscription, ERC721 {
    using SubscriptionNft for SubscriptionNft.Data;

    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        string memory uri
    ) public override {
        OwnableStorage.onlyOwner();

        SubscriptionNft.load().incrementCounter();

        _initialize(tokenName, tokenSymbol, uri);
    }

    function mint(address to) external override {
        OwnableStorage.onlyOwner();

        SubscriptionNft.Data storage store = SubscriptionNft.load();

        uint256 tokenId = store.tokenIdCounter;
        store.incrementCounter();

        _mint(to, tokenId);
    }

    function getCurrentTokenId() external view override returns (uint256) {
        return SubscriptionNft.load().tokenIdCounter;
    }
}
