// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ISubscriptionsModule} from "../interfaces/ISubscriptionsModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {Subscription} from "../storage/Subscription.sol";

library SubscriptionRenderer {
    using Subscription for Subscription.Data;
    using Strings for uint256;

    uint256 constant MONTH_SECONDS = 30 days;

    struct Color {
        uint256 red;
        uint256 green;
        uint256 blue;
    }

    function render(uint256 tokenId) internal view returns (string memory) {
        address system = OwnableStorage.load().owner;

        Subscription.Data memory subscription = ISubscriptionsModule(system)
            .getSubscription(tokenId);

        uint256 currentDuration = _getCurrentDuration(
            subscription.duration,
            subscription.lastUpdate
        );

        return _constructTokenURI(tokenId, subscription, currentDuration);
    }

    function _getCurrentDuration(
        uint256 duration,
        uint256 lastUpdate
    ) private view returns (uint256) {
        uint256 elapsedTime = block.timestamp - lastUpdate;

        return duration + elapsedTime;
    }

    function _constructTokenURI(
        uint256 tokenId,
        Subscription.Data memory subscription,
        uint256 duration
    ) internal view returns (string memory) {
        string memory _name = _getName(tokenId);
        string memory _description = _getDescription(subscription, duration);
        string memory _image = Base64.encode(bytes(_getSVG(tokenId, duration)));

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

    function _getName(uint256 tokenId) private pure returns (string memory) {
        return string(abi.encodePacked("Subscription #", tokenId.toString()));
    }

    function _getDescription(
        Subscription.Data memory subscription,
        uint256 duration
    ) private view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "This NFT represents a subscription",
                    "\\n",
                    "Status: ",
                    _getStatus(subscription.rate),
                    "\\n",
                    "Since: ",
                    _getSince(duration),
                    "\\n",
                    "Durration: ",
                    duration.toString(),
                    "\\n",
                    "Creator: https://imgrateful.io/profile/",
                    subscription.creatorId
                )
            );
    }

    function _getStatus(uint256 rate) private pure returns (string memory) {
        return rate > 0 ? "Active" : "Inactive";
    }

    function _getSince(uint256 duration) private view returns (string memory) {
        uint256 creation = block.timestamp - duration;
        return creation.toString();
    }

    function _getSVG(
        uint256 tokenId,
        uint256 duration
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xhtml="http://www.w3.org/1999/xhtml" viewBox="0 0 300 300" width="300" height="300">',
                    _getSVGBody(tokenId, duration),
                    "</svg>"
                )
            );
    }

    function _getSVGBody(
        uint256 tokenId,
        uint256 duration
    ) private pure returns (string memory) {
        (Color memory mainColor, Color memory secondaryColor) = _getColors(
            tokenId
        );

        string memory gradient = _getGradient(
            tokenId,
            mainColor,
            secondaryColor
        );

        uint256 cicles = duration / MONTH_SECONDS;
        uint256 length = duration - (MONTH_SECONDS * cicles);

        uint256 percentage = (length * 100) / MONTH_SECONDS;
        uint256 size = percentage + 70;

        return
            string(
                abi.encodePacked(
                    _getMainDotStyle(size, gradient),
                    _getMainDotBody()
                )
            );
    }

    function _getMainDotStyle(
        uint256 size,
        string memory gradient
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<style>.dot{position: absolute;top: 50%;left: 50%;transform: translate(-50%, -50%);width: ",
                    _uint2str(size),
                    "px;height: ",
                    _uint2str(size),
                    "px;filter: blur(0.5rem);background: ",
                    gradient,
                    "border-radius: 50%;animation: animate-pulse 2s linear infinite;}",
                    _getKeyframes(size),
                    "}</style>"
                )
            );
    }

    function _getMainDotBody() private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<foreignObject x="0" y="0" width="100%" height="100%">'
                    '<xhtml:div class="dot"></xhtml:div>',
                    "</foreignObject>"
                )
            );
    }

    function _getColors(
        uint256 tokenId
    ) private pure returns (Color memory main, Color memory secondary) {
        // Light
        Color memory ORANGE = Color(255, 100, 25);
        Color memory PINK = Color(235, 128, 181);
        Color memory YELLOW = Color(248, 219, 80);

        // Dark
        Color memory LIGHT_BLUE = Color(0, 107, 189);
        Color memory BLUE = Color(0, 40, 122);

        uint256 random = uint256(
            keccak256(abi.encodePacked("COLOR", tokenId))
        ) % 8;

        if (random == 0) return (ORANGE, PINK);
        if (random == 1) return (ORANGE, YELLOW);
        if (random == 2) return (PINK, ORANGE);
        if (random == 3) return (PINK, YELLOW);
        if (random == 4) return (YELLOW, ORANGE);
        if (random == 5) return (YELLOW, PINK);
        if (random == 6) return (LIGHT_BLUE, BLUE);
        if (random == 7) return (BLUE, LIGHT_BLUE);
    }

    function _getGradient(
        uint256 tokenId,
        Color memory mainColor,
        Color memory secondaryColor
    ) private pure returns (string memory) {
        uint256 random = uint256(
            keccak256(abi.encodePacked("GRADIENT", tokenId))
        ) % 10;

        if (random >= 3) {
            return _getRadialGradient(tokenId, mainColor, secondaryColor);
        } else {
            return _getLinearGradient(tokenId, mainColor, secondaryColor);
        }
    }

    function _getRadialGradient(
        uint256 tokenId,
        Color memory mainColor,
        Color memory secondaryColor
    ) private pure returns (string memory) {
        uint256 percentage = uint256(
            keccak256(abi.encodePacked("PERCENTAGE", tokenId))
        ) % 25;

        return
            string.concat(
                "radial-gradient(",
                _rgba(secondaryColor, "1"),
                _uint2str(percentage),
                "%, ",
                _rgba(secondaryColor, "0.7"),
                _uint2str(percentage + 10),
                "%, ",
                _rgba(mainColor, "1"),
                _uint2str(percentage + 20),
                "%, ",
                _rgba(mainColor, "0.5"),
                _uint2str(percentage + 35),
                "%, rgba(255, 255, 255, 1) 75%);"
            );
    }

    function _getLinearGradient(
        uint256 tokenId,
        Color memory mainColor,
        Color memory secondaryColor
    ) private pure returns (string memory) {
        uint256 degree = uint256(
            keccak256(abi.encodePacked("DEGREE", tokenId))
        ) % 360;

        return
            string.concat(
                "linear-gradient(",
                _uint2str(degree),
                "deg,",
                _rgba(secondaryColor, "1"),
                " 15%, ",
                _rgba(secondaryColor, "1"),
                " 25%, ",
                _rgba(mainColor, "1"),
                " 75%, ",
                _rgba(mainColor, "1"),
                " 100%);filter: blur(1rem);"
            );
    }

    function _getKeyframes(uint256 size) private pure returns (string memory) {
        string memory keyframes = string.concat(
            "@keyframes animate-pulse {50% {width: ",
            _uint2str((size * 11) / 10),
            "px;height: ",
            _uint2str((size * 11) / 10),
            "px;}"
        );

        return keyframes;
    }

    function _rgba(
        Color memory color,
        string memory _a
    ) private pure returns (string memory) {
        return
            string.concat(
                "rgba(",
                _uint2str(color.red),
                ",",
                _uint2str(color.green),
                ",",
                _uint2str(color.blue),
                ",",
                _a,
                ")"
            );
    }

    function _uint2str(
        uint256 _i
    ) private pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
