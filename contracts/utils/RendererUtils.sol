// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

struct Color {
    uint256 red;
    uint256 green;
    uint256 blue;
}

library Utils {
    function rgba(
        Color memory color,
        string memory _a
    ) internal pure returns (string memory) {
        return
            string.concat(
                "rgba(",
                uint2str(color.red),
                ",",
                uint2str(color.green),
                ",",
                uint2str(color.blue),
                ",",
                _a,
                ")"
            );
    }

    function uint2str(
        uint256 _i
    ) internal pure returns (string memory _uintAsString) {
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
