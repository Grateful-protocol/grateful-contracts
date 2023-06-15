// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ISubscriptionsModule} from "../interfaces/ISubscriptionsModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {Subscription} from "../storage/Subscription.sol";
import {Utils, Color} from "./RendererUtils.sol";

library SubscriptionRenderer {
    using Subscription for Subscription.Data;
    using Strings for uint256;

    uint256 constant MONTH_SECONDS = 30 days;

    function render(uint256 tokenId) internal view returns (string memory) {
        address system = OwnableStorage.load().owner;

        Subscription.Data memory subscription = ISubscriptionsModule(system)
            .getSubscription(tokenId);

        uint256 currentDuration = _getCurrentDuration(
            subscription.rate,
            subscription.duration,
            subscription.lastUpdate
        );

        return _constructTokenURI(tokenId, subscription, currentDuration);
    }

    function _getCurrentDuration(
        uint256 rate,
        uint256 duration,
        uint256 lastUpdate
    ) private view returns (uint256) {
        if (lastUpdate == 0) return 0;

        if (rate != 0) {
            uint256 elapsedTime = block.timestamp - lastUpdate;
            return duration + elapsedTime;
        } else {
            return duration;
        }
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
                    "Duration: ",
                    _getDuration(duration),
                    "\\n"
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

    function _getDuration(
        uint256 duration
    ) private pure returns (string memory) {
        uint256 durationDays = duration / 1 days;
        return string(abi.encodePacked(durationDays.toString(), " days"));
    }

    function _getSVG(
        uint256 tokenId,
        uint256 duration
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xhtml="http://www.w3.org/1999/xhtml" viewBox="0 0 400 400" width="400" height="400">',
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
                    _getMainDotBody(),
                    _getMonthsDots(cicles),
                    _getYearsDots(cicles, gradient)
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
                    Utils.uint2str(size),
                    "px;height: ",
                    Utils.uint2str(size),
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

    function _getMonthsDots(
        uint256 cicles
    ) private pure returns (string memory) {
        string memory dots = string.concat(
            "<style>.monthDot{position: absolute;top: 42.5px;left: 42.5px;width: 5px; height: 5px; border-radius: 50%;} .darkDot{background: rgba(0, 40, 122); opacity: 0.8;} .lightDot{background: rgba(255, 100, 25);}</style>"
        );

        uint256 yearsCicles = cicles / 12;
        cicles = cicles - (yearsCicles * 12);

        for (uint i = 1; i <= 12; i++) {
            (string memory x, string memory y) = _getXY(i);
            string memory background = i - 1 > cicles ? "darkDot" : "lightDot";
            dots = string.concat(
                dots,
                '<foreignObject x="',
                x,
                '" y="',
                y,
                '" width="100px" height="100px">'
                '<xhtml:div class="monthDot ',
                background,
                '"></xhtml:div>',
                "</foreignObject>"
            );
        }

        return dots;
    }

    function _getYearsDots(
        uint256 cicles,
        string memory gradient
    ) private pure returns (string memory) {
        string memory yearsDots = string.concat(
            "<style>.yearDot{position: absolute;top: 45px;left: 50px;width: 40px; height: 40px;background: ",
            gradient,
            ";filter: blur(0.4rem);border-radius: 50%;}</style>"
        );

        uint256 yearsCicles = cicles / 12;

        yearsDots = yearsCicles >= 1
            ? string.concat(
                yearsDots,
                '<foreignObject x="260" y="0" width="100px" height="100px">'
                '<xhtml:div class="yearDot"></xhtml:div>',
                "</foreignObject>"
            )
            : "";

        return yearsDots;
    }

    function _getColors(
        uint256 tokenId
    ) private pure returns (Color memory main, Color memory secondary) {
        Color memory ORANGE = Color(255, 100, 25);
        Color memory PINK = Color(235, 128, 181);
        Color memory YELLOW = Color(248, 219, 80);

        uint256 random = uint256(
            keccak256(abi.encodePacked("COLOR", tokenId))
        ) % 6;

        if (random == 0) return (ORANGE, PINK);
        if (random == 1) return (ORANGE, YELLOW);
        if (random == 2) return (PINK, ORANGE);
        if (random == 3) return (PINK, YELLOW);
        if (random == 4) return (YELLOW, ORANGE);
        if (random == 5) return (YELLOW, PINK);
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
                Utils.rgba(secondaryColor, "1"),
                Utils.uint2str(percentage),
                "%, ",
                Utils.rgba(secondaryColor, "0.7"),
                Utils.uint2str(percentage + 10),
                "%, ",
                Utils.rgba(mainColor, "1"),
                Utils.uint2str(percentage + 20),
                "%, ",
                Utils.rgba(mainColor, "0.5"),
                Utils.uint2str(percentage + 35),
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
                Utils.uint2str(degree),
                "deg,",
                Utils.rgba(secondaryColor, "1"),
                " 15%, ",
                Utils.rgba(secondaryColor, "1"),
                " 25%, ",
                Utils.rgba(mainColor, "1"),
                " 75%, ",
                Utils.rgba(mainColor, "1"),
                " 100%);filter: blur(1rem);"
            );
    }

    function _getKeyframes(uint256 size) private pure returns (string memory) {
        string memory keyframes = string.concat(
            "@keyframes animate-pulse {50% {width: ",
            Utils.uint2str((size * 11) / 10),
            "px;height: ",
            Utils.uint2str((size * 11) / 10),
            "px;}"
        );

        return keyframes;
    }

    function _getXY(
        uint256 index
    ) private pure returns (string memory x, string memory y) {
        if (index == 1) return ("215", "45");
        if (index == 2) return ("260", "90");
        if (index == 3) return ("280", "155");
        if (index == 4) return ("260", "215");
        if (index == 5) return ("215", "260");
        if (index == 6) return ("155", "280");
        if (index == 7) return ("95", "260");
        if (index == 8) return ("50", "215");
        if (index == 9) return ("30", "155");
        if (index == 10) return ("50", "90");
        if (index == 11) return ("95", "45");
        if (index == 12) return ("155", "30");
    }
}
