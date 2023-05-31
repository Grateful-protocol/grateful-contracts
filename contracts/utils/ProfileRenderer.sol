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
            string(
                abi.encodePacked(
                    _getFirstText(secondaryColor),
                    _getMainLogo(mainColor, secondaryColor),
                    _getFinalText(secondaryColor)
                )
            );
    }

    function _getFirstText(
        Color memory color
    ) private pure returns (string memory) {
        return
            string.concat(
                '<path class="st4" d="M190.15,22.41v13.82h-1.8v-6.26h-7.04v6.26h-1.8V22.41h1.8v6.07h7.04v-6.07H190.15z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M203.47,31.48h-8.68c0.07,1.07,0.43,1.91,1.1,2.51c0.67,0.6,1.48,0.9,2.43,0.9c0.78,0,1.43-0.18,1.95-0.54c0.52-0.36,0.89-0.85,1.1-1.46h1.94c-0.29,1.04-0.87,1.89-1.74,2.55s-1.96,0.98-3.25,0.98c-1.03,0-1.95-0.23-2.77-0.69c-0.81-0.46-1.45-1.12-1.91-1.97c-0.46-0.85-0.69-1.84-0.69-2.96c0-1.12,0.22-2.11,0.67-2.95c0.45-0.85,1.08-1.5,1.89-1.95c0.81-0.46,1.75-0.68,2.81-0.68c1.03,0,1.94,0.22,2.74,0.67s1.4,1.07,1.83,1.85c0.43,0.79,0.64,1.68,0.64,2.67C203.53,30.73,203.51,31.09,203.47,31.48z M201.21,28.23c-0.3-0.5-0.72-0.87-1.24-1.13c-0.52-0.26-1.1-0.39-1.73-0.39c-0.91,0-1.69,0.29-2.33,0.87c-0.64,0.58-1.01,1.39-1.1,2.42h6.86C201.67,29.32,201.51,28.73,201.21,28.23z"  fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M215.66,25.37l-6.54,15.98h-1.86l2.14-5.23l-4.38-10.75h2l3.41,8.8l3.37-8.8H215.66z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M218.44,35.99c-0.24-0.24-0.36-0.53-0.36-0.87s0.12-0.63,0.36-0.87c0.24-0.24,0.53-0.36,0.87-0.36c0.33,0,0.61,0.12,0.84,0.36c0.23,0.24,0.35,0.53,0.35,0.87s-0.12,0.63-0.35,0.87c-0.23,0.24-0.51,0.36-0.84,0.36C218.97,36.35,218.68,36.23,218.44,35.99z M220.2,22.41l-0.22,9.91h-1.51l-0.22-9.91H220.2z" fill="',
                Utils.rgba(color, "1"),
                '"/>'
            );
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

    function _getFinalText(
        Color memory color
    ) private pure returns (string memory) {
        return
            string.concat(
                '<path class="st4" d="M134.68,358.41l-4.5,8.6v5.21h-1.8v-5.21l-4.52-8.6h2l3.41,7l3.41-7H134.68z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M138.96,371.72c-0.83-0.46-1.47-1.12-1.94-1.97s-0.7-1.84-0.7-2.96c0-1.11,0.24-2.09,0.72-2.94c0.48-0.85,1.14-1.51,1.97-1.96c0.83-0.46,1.76-0.68,2.8-0.68s1.96,0.23,2.8,0.68c0.83,0.46,1.49,1.11,1.97,1.95s0.72,1.83,0.72,2.95c0,1.12-0.25,2.11-0.74,2.96c-0.5,0.85-1.17,1.51-2.01,1.97c-0.85,0.46-1.78,0.69-2.82,0.69C140.7,372.41,139.78,372.18,138.96,371.72z M143.55,370.37c0.57-0.3,1.03-0.76,1.38-1.37c0.35-0.61,0.53-1.35,0.53-2.22s-0.17-1.61-0.52-2.22c-0.34-0.61-0.79-1.06-1.35-1.36c-0.56-0.3-1.16-0.45-1.8-0.45c-0.66,0-1.27,0.15-1.81,0.45c-0.55,0.3-0.99,0.75-1.32,1.36c-0.33,0.61-0.5,1.35-0.5,2.22c0,0.89,0.16,1.63,0.49,2.24c0.32,0.61,0.76,1.06,1.3,1.36c0.54,0.3,1.14,0.45,1.78,0.45C142.37,370.83,142.98,370.67,143.55,370.37z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M159.7,361.37v10.86h-1.8v-1.61c-0.34,0.55-0.82,0.99-1.44,1.3c-0.61,0.31-1.29,0.47-2.03,0.47c-0.85,0-1.61-0.17-2.28-0.53c-0.67-0.35-1.21-0.88-1.6-1.58c-0.39-0.7-0.58-1.55-0.58-2.56v-6.36h1.78v6.13c0,1.07,0.27,1.89,0.81,2.47c0.54,0.58,1.28,0.86,2.22,0.86c0.96,0,1.73-0.3,2.28-0.89c0.56-0.59,0.83-1.46,0.83-2.6v-5.97H159.7z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M176.46,361.7c0.66,0.35,1.18,0.88,1.56,1.58c0.38,0.7,0.56,1.55,0.56,2.56v6.4h-1.78v-6.15c0-1.08-0.27-1.91-0.81-2.49c-0.54-0.58-1.28-0.86-2.22-0.86c-0.95,0-1.71,0.3-2.27,0.89c-0.56,0.59-0.84,1.46-0.84,2.6v6.01h-1.8v-14.67h1.8v5.35c0.36-0.55,0.85-0.98,1.48-1.29c0.63-0.3,1.33-0.46,2.11-0.46C175.06,361.17,175.8,361.35,176.46,361.7z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M181.93,363.84c0.45-0.84,1.07-1.49,1.85-1.95c0.79-0.46,1.66-0.69,2.63-0.69c0.95,0,1.78,0.21,2.48,0.61c0.7,0.41,1.22,0.93,1.57,1.55v-1.98h1.82v10.86h-1.82v-2.02c-0.36,0.63-0.89,1.16-1.6,1.58c-0.71,0.42-1.53,0.62-2.47,0.62c-0.96,0-1.84-0.24-2.62-0.71c-0.78-0.48-1.39-1.14-1.84-2c-0.45-0.86-0.67-1.84-0.67-2.93C181.26,365.65,181.48,364.68,181.93,363.84z M189.96,364.64c-0.33-0.61-0.78-1.07-1.34-1.4c-0.56-0.32-1.18-0.49-1.85-0.49c-0.67,0-1.29,0.16-1.84,0.48c-0.56,0.32-1,0.78-1.33,1.39c-0.33,0.61-0.5,1.32-0.5,2.14c0,0.83,0.17,1.56,0.5,2.17c0.33,0.61,0.77,1.08,1.33,1.41c0.55,0.32,1.17,0.49,1.84,0.49c0.67,0,1.29-0.16,1.85-0.49c0.56-0.32,1.01-0.79,1.34-1.41c0.33-0.62,0.5-1.33,0.5-2.15S190.29,365.25,189.96,364.64z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M199.77,370.57l3.37-9.2h1.92l-4.26,10.86h-2.1l-4.26-10.86h1.94L199.77,370.57z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M217.1,367.48h-8.68c0.07,1.07,0.43,1.91,1.1,2.51c0.67,0.6,1.48,0.9,2.43,0.9c0.78,0,1.43-0.18,1.95-0.54c0.52-0.36,0.89-0.85,1.1-1.46h1.94c-0.29,1.04-0.87,1.89-1.74,2.55c-0.87,0.65-1.96,0.98-3.25,0.98c-1.03,0-1.95-0.23-2.77-0.69c-0.81-0.46-1.45-1.12-1.91-1.97s-0.69-1.84-0.69-2.96c0-1.12,0.22-2.11,0.67-2.95c0.45-0.85,1.08-1.5,1.89-1.95s1.75-0.68,2.81-0.68c1.03,0,1.94,0.22,2.74,0.67s1.4,1.07,1.83,1.85c0.43,0.79,0.64,1.68,0.64,2.67C217.16,366.73,217.14,367.09,217.1,367.48z M214.84,364.23c-0.3-0.5-0.72-0.87-1.24-1.13c-0.52-0.26-1.1-0.39-1.73-0.39c-0.91,0-1.69,0.29-2.33,0.87c-0.64,0.58-1.01,1.39-1.1,2.42h6.86C215.3,365.32,215.14,364.73,214.84,364.23z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M225.63,363.84c0.45-0.84,1.07-1.49,1.85-1.95c0.79-0.46,1.66-0.69,2.63-0.69c0.95,0,1.78,0.21,2.48,0.61c0.7,0.41,1.22,0.93,1.57,1.55v-1.98h1.82v10.86h-1.82v-2.02c-0.36,0.63-0.89,1.16-1.6,1.58c-0.71,0.42-1.53,0.62-2.47,0.62c-0.97,0-1.84-0.24-2.62-0.71c-0.78-0.48-1.39-1.14-1.84-2c-0.45-0.86-0.67-1.84-0.67-2.93C224.95,365.65,225.18,364.68,225.63,363.84z M233.65,364.64c-0.33-0.61-0.78-1.07-1.34-1.4c-0.56-0.32-1.18-0.49-1.85-0.49c-0.67,0-1.29,0.16-1.84,0.48s-1,0.78-1.33,1.39c-0.33,0.61-0.5,1.32-0.5,2.14c0,0.83,0.17,1.56,0.5,2.17c0.33,0.61,0.77,1.08,1.33,1.41c0.56,0.32,1.17,0.49,1.84,0.49c0.67,0,1.29-0.16,1.85-0.49c0.56-0.32,1.01-0.79,1.34-1.41c0.33-0.62,0.5-1.33,0.5-2.15S233.98,365.25,233.65,364.64z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M252.06,361.8c0.71,0.41,1.23,0.93,1.58,1.55v-1.98h1.82v11.1c0,0.99-0.21,1.87-0.63,2.65c-0.42,0.77-1.03,1.38-1.81,1.81c-0.79,0.44-1.7,0.65-2.75,0.65c-1.43,0-2.62-0.34-3.57-1.01s-1.51-1.59-1.69-2.76h1.78c0.2,0.66,0.61,1.19,1.23,1.6c0.62,0.4,1.37,0.61,2.24,0.61c0.99,0,1.8-0.31,2.43-0.93c0.63-0.62,0.94-1.49,0.94-2.62v-2.28c-0.36,0.63-0.89,1.16-1.59,1.59s-1.52,0.63-2.46,0.63c-0.97,0-1.84-0.24-2.63-0.71c-0.79-0.48-1.4-1.14-1.85-2c-0.45-0.86-0.67-1.84-0.67-2.93c0-1.11,0.22-2.08,0.67-2.92c0.45-0.84,1.07-1.49,1.85-1.95c0.79-0.46,1.66-0.69,2.63-0.69C250.53,361.19,251.36,361.4,252.06,361.8z M253.14,364.64c-0.33-0.61-0.78-1.07-1.34-1.4c-0.56-0.32-1.18-0.49-1.85-0.49c-0.67,0-1.29,0.16-1.84,0.48s-1,0.78-1.33,1.39c-0.33,0.61-0.5,1.32-0.5,2.14c0,0.83,0.17,1.56,0.5,2.17c0.33,0.61,0.77,1.08,1.33,1.41c0.56,0.32,1.17,0.49,1.84,0.49c0.67,0,1.29-0.16,1.85-0.49c0.56-0.32,1.01-0.79,1.34-1.41c0.33-0.62,0.5-1.33,0.5-2.15S253.47,365.25,253.14,364.64z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M258.97,359.25c-0.24-0.24-0.36-0.53-0.36-0.87s0.12-0.63,0.36-0.87c0.24-0.24,0.53-0.36,0.87-0.36c0.33,0,0.61,0.12,0.84,0.36c0.23,0.24,0.35,0.53,0.35,0.87s-0.12,0.63-0.35,0.87c-0.23,0.24-0.51,0.36-0.84,0.36C259.5,359.6,259.21,359.48,258.97,359.25z M260.72,361.37v10.86h-1.8v-10.86H260.72z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M268.61,362.85h-2.28v9.38h-1.8v-9.38h-1.41v-1.49h1.41v-0.77c0-1.22,0.31-2.1,0.94-2.67c0.63-0.56,1.64-0.84,3.02-0.84v1.51c-0.79,0-1.35,0.16-1.68,0.47c-0.32,0.31-0.49,0.82-0.49,1.54v0.77h2.28V362.85z" fill="',
                Utils.rgba(color, "1"),
                '"/>',
                '<path class="st4" d="M273.31,362.85v6.4c0,0.53,0.11,0.9,0.34,1.12c0.22,0.22,0.61,0.33,1.17,0.33h1.33v1.53h-1.63c-1,0-1.76-0.23-2.26-0.69c-0.5-0.46-0.75-1.22-0.75-2.28v-6.4h-1.41v-1.49h1.41v-2.74h1.8v2.74h2.84v1.49H273.31z" fill="',
                Utils.rgba(color, "1"),
                '"/>'
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
