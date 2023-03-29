// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {ISubscriptionsModule} from "../interfaces/ISubscriptionsModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {Subscription} from "../storage/Subscription.sol";

library SubscriptionRenderer {
    using Subscription for Subscription.Data;

    function render(uint256 tokenId) internal view returns (string memory) {
        address system = OwnableStorage.load().owner;

        Subscription.Data memory subscription = ISubscriptionsModule(system)
            .getSubscription(tokenId);

        return _constructTokenURI(tokenId, subscription);
    }

    function _constructTokenURI(
        uint256 tokenId,
        Subscription.Data memory subscription
    ) internal pure returns (string memory) {
        string memory _name = _generateName(tokenId, subscription);
        string memory _description = _generateDescription(subscription);
        string memory _image = Base64.encode(
            bytes(_generateImage(subscription))
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                _name,
                                '", "description":"',
                                _description,
                                '", "image": "data:image/svg+xml;base64,',
                                _image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function _generateName(
        uint256 tokenId,
        Subscription.Data memory subscription
    ) private pure returns (string memory) {
        return string(abi.encodePacked("Grateful Subscription #", tokenId));
    }

    function _generateDescription(
        Subscription.Data memory subscription
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "This NFT represents a subscription from giver to creator"
                )
            );
    }

    function _generateImage(
        Subscription.Data memory subscription
    ) private pure returns (string memory) {
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
