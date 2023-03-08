// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Module with ERC721 logic for the grateful subscription.
 */
interface IGratefulSubscription {
    /**************************************************************************
     * Governance functions
     *************************************************************************/

    /**
     * @notice Initialize the NFT
     * @dev Only owner / Token must not be initialized
     * @param tokenName The NFT token name
     * @param tokenSymbol The NFT token symbol
     * @param uri The NFT uri
     */
    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        string memory uri
    ) external;

    /**
     * @notice Mint token to user and increment counter
     * @dev Only owner / Token must be initialized
     * @param to Address to mint the NFT
     */
    function mint(address to) external;

    /**************************************************************************
     * View functions
     *************************************************************************/

    /**
     * @notice Get the current subscriptions token ID
     * @return The current token ID
     */
    function getCurrentTokenId() external view returns (uint256);
}
