// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Utils, Color} from "./RendererUtils.sol";

library ProfileRenderer {
    using Strings for uint256;

    function render(uint256 tokenId) internal pure returns (string memory) {
        return _constructTokenURI(tokenId);
    }

    function _constructTokenURI(
        uint256 tokenId
    ) internal pure returns (string memory) {
        string memory _name = _getName(tokenId);
        string memory _description = _getDescription();
        string memory _image = Base64.encode(bytes(_getSVG(tokenId)));

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
        return string(abi.encodePacked("Profile #", tokenId.toString()));
    }

    function _getDescription() private pure returns (string memory) {
        return
            string(abi.encodePacked("This NFT represents a Grateful profile"));
    }

    function _getSVG(uint256 tokenId) private pure returns (string memory) {
        (Color memory mainColor, Color memory secondaryColor) = _getColors(
            tokenId
        );

        return
            string(
                abi.encodePacked(
                    '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xhtml="http://www.w3.org/1999/xhtml" viewBox="0 0 400 400" width="400" height="400" style="background-color: ',
                    Utils.rgba(mainColor, "1"),
                    '">',
                    _getSVGBody(mainColor, secondaryColor),
                    "</svg>"
                )
            );
    }

    function _getSVGBody(
        Color memory mainColor,
        Color memory secondaryColor
    ) private pure returns (string memory) {
        return
            string(abi.encodePacked(_getMainLogo(mainColor, secondaryColor)));
    }

    function _getMainLogo(
        Color memory mainColor,
        Color memory secondaryColor
    ) private pure returns (string memory) {
        return
            string.concat(
                '<circle cx="200" cy="200" r="130" fill="',
                Utils.rgba(secondaryColor, "1"),
                '" />',
                '<path class="st4" d="M149.62,186.41c0-8.46,1.83-16.14,5.48-23.03c3.65-6.89,8.63-12.31,14.95-16.25c6.31-3.94,13.41-5.91,21.29-5.91c7.65,0,14.57,1.97,20.77,5.91c6.2,3.94,11.04,9.36,14.51,16.25c3.48,6.9,5.21,14.57,5.21,23.03c0,8.46-1.74,16.14-5.21,23.03c-3.48,6.9-8.32,12.31-14.51,16.25c-6.2,3.94-13.12,5.91-20.77,5.91c-7.88,0-14.98-1.97-21.29-5.91c-6.32-3.94-11.3-9.36-14.95-16.25C151.44,202.55,149.62,194.88,149.62,186.41z M165.78,236.13c2.78,5.91,6.78,10.6,11.99,14.08c5.21,3.48,11.12,5.22,17.73,5.22c6.14,0,11.76-1.48,16.86-4.43c5.1-2.96,9.1-6.98,11.99-12.08c2.9-5.1,4.35-10.83,4.35-17.21v-78.74h13.04v78.74c0,8.58-2.03,16.34-6.08,23.29c-4.06,6.95-9.62,12.43-16.69,16.43c-7.07,4-14.89,6-23.47,6c-9.39,0-17.73-2.35-25.03-7.04c-7.3-4.69-12.81-10.92-16.51-18.69L165.78,236.13z M163,186.41c0,6.14,1.42,11.76,4.26,16.86c2.84,5.1,6.72,9.1,11.65,11.99c4.92,2.9,10.34,4.34,16.25,4.34c6.37,0,12.11-1.45,17.21-4.34c5.1-2.9,9.1-6.89,11.99-11.99c2.9-5.1,4.35-10.72,4.35-16.86c0-6.14-1.45-11.73-4.35-16.77c-2.9-5.04-6.9-9.01-11.99-11.91c-5.1-2.9-10.84-4.35-17.21-4.35c-5.91,0-11.33,1.45-16.25,4.35c-4.93,2.9-8.81,6.87-11.65,11.91C164.42,174.68,163,180.27,163,186.41z" fill="',
                Utils.rgba(mainColor, "1"),
                '" />'
            );
    }

    function _getColors(
        uint256 tokenId
    ) private pure returns (Color memory main, Color memory secondary) {
        // Light
        Color memory ORANGE = Color(255, 100, 25);
        Color memory PINK = Color(235, 128, 181);
        Color memory YELLOW = Color(248, 219, 80);
        Color memory WHITE = Color(249, 245, 234);

        // Dark
        Color memory LIGHT_BLUE = Color(0, 107, 189);
        Color memory BLUE = Color(0, 40, 122);
        Color memory BLACK = Color(26, 26, 30);

        uint256 random = uint256(
            keccak256(abi.encodePacked("COLOR", tokenId))
        ) % 16;

        if (random == 0) return (ORANGE, BLACK);
        if (random == 1) return (BLACK, ORANGE);
        if (random == 2) return (WHITE, ORANGE);
        if (random == 3) return (ORANGE, WHITE);
        if (random == 4) return (BLUE, PINK);
        if (random == 5) return (PINK, BLUE);
        if (random == 6) return (LIGHT_BLUE, BLACK);
        if (random == 7) return (BLACK, LIGHT_BLUE);
        if (random == 8) return (ORANGE, LIGHT_BLUE);
        if (random == 9) return (LIGHT_BLUE, ORANGE);
        if (random == 10) return (YELLOW, ORANGE);
        if (random == 11) return (ORANGE, YELLOW);
        if (random == 12) return (YELLOW, PINK);
        if (random == 13) return (PINK, YELLOW);
        if (random == 14) return (LIGHT_BLUE, PINK);
        if (random == 15) return (PINK, LIGHT_BLUE);
    }
}
