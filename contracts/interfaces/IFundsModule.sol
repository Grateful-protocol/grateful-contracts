// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IFundsModule {
    function depositFunds(
        address profile,
        uint256 tokenId,
        bytes32 vaultId,
        uint256 amount
    ) external;

    function withdrawFunds(
        address profile,
        uint256 tokenId,
        bytes32 vaultId,
        uint256 shares
    ) external;
}
