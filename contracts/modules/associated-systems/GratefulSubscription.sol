// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IGratefulSubscription} from "../../interfaces/IGratefulSubscription.sol";
import {NftModule} from "@synthetixio/core-modules/contracts/modules/NftModule.sol";
import {ERC721} from "@synthetixio/core-contracts/contracts/token/ERC721.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {SubscriptionNft} from "../../storage/SubscriptionNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title Module with ERC721 logic for the grateful subscription.
 * @dev See IGratefulSubscription
 */
contract GratefulSubscription is IGratefulSubscription, ERC721 {
    using SubscriptionNft for SubscriptionNft.Data;

    /// @inheritdoc	IGratefulSubscription
    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        string memory uri
    ) public override {
        OwnableStorage.onlyOwner();

        SubscriptionNft.load().incrementCounter();

        _initialize(tokenName, tokenSymbol, uri);
    }

    /// @inheritdoc	IGratefulSubscription
    function mint(address to) external override {
        OwnableStorage.onlyOwner();

        SubscriptionNft.Data storage store = SubscriptionNft.load();

        uint256 tokenId = store.tokenIdCounter;
        store.incrementCounter();

        _mint(to, tokenId);
    }

    /// @inheritdoc	IGratefulSubscription
    function getCurrentTokenId() external view override returns (uint256) {
        return SubscriptionNft.load().tokenIdCounter;
    }

    function tokenURI(
        uint256 tokenId
    ) external view virtual override returns (string memory) {
        string memory _image = Base64.encode(bytes(_generateImage()));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "Grateful Protocol Subscription",
                                '", "description":"',
                                "This NFT represents a subscription from giver to creator",
                                '", "image": "data:image/svg+xml;base64,',
                                _image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function _generateImage() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xhtml="http://www.w3.org/1999/xhtml" viewBox="0 0 300 300" width="300" height="300">',
                    "<style>.pulse{position: absolute;top: 50%;left: 50%;transform: translate(-50%, -50%);width: 3.125rem;height: 3.125rem;background: linear-gradient(90deg, #ff6419 0%, #fa6b3e 36.98%, #ef7a93 74.48%, #eb80b5 100%);filter: blur(0.6rem);border-radius: 50%;animation: animate-pulse 1s linear infinite;}@keyframes animate-pulse {0% {box-shadow: 0 0 0 0 rgba(255, 109, 74, 0.7), 0 0 0 0 rgba(255, 109, 74, 0.7);}40% {box-shadow: 0 0 0 3.125rem rgba(255, 109, 74, 0), 0 0 0 0 rgba(255, 109, 74, 0.7);}80% {box-shadow: 0 0 0 3.125rem rgba(255, 109, 74, 0), 0 0 0 1.875rem rgba(255, 109, 74, 0);}100% {box-shadow: 0 0 0 0 rgba(255, 109, 74, 0), 0 0 0 1.875rem rgba(255, 109, 74, 0);}}</style>",
                    '<foreignObject x="0" y="0" width="100%" height="100%">'
                    '<xhtml:div class="pulse"></xhtml:div>',
                    "</foreignObject>",
                    "</svg>"
                )
            );
    }
}
