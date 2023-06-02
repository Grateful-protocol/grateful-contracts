// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Module for getting balances data.
 */
interface IBalancesModule {
    /**************************************************************************
     * View functions
     *************************************************************************/

    /**
     * @notice Return the current profile balance from a vault
     * @param profileId The profile to return the balance
     * @param vaultId The vault from where return the balance
     * @return The current balance
     */
    function balanceOf(
        bytes32 profileId,
        bytes32 vaultId
    ) external view returns (int256);

    /**
     * @notice Return the current profile flow from a vault
     * @param profileId The profile to return the flow
     * @param vaultId The vault from where return the flow
     * @return The current flow
     */
    function getFlow(
        bytes32 profileId,
        bytes32 vaultId
    ) external view returns (int256);

    /**
     * @notice Check if a profile can be liquidated from a vault
     * @param profileId The profile to check the liquidation
     * @param vaultId The vault from where to check the liquidation
     * @return If profile/vault is liquidable
     */
    function canBeLiquidated(
        bytes32 profileId,
        bytes32 vaultId
    ) external view returns (bool);

    /**
     * @notice Return the profile remaining time to zero balance from a vault
     * @param profileId The profile to return the remaining time
     * @param vaultId The vault from where return the remaining time
     * @return Time left
     */
    function getRemainingTimeToZero(
        bytes32 profileId,
        bytes32 vaultId
    ) external view returns (uint256);

    /**
     * @notice Return the current profile balance data from a vault
     * @dev It bundle all balance data in one function
     * @param profileId The profile to return the current data
     * @param vaultId The vault from where return the current data
     * @return currentBalance Current balance
     * @return flow Current flow
     * @return liquidable If profile/vault is liquidable
     * @return timeLeft Time left to zero balance
     */
    function getBalanceCurrentData(
        bytes32 profileId,
        bytes32 vaultId
    )
        external
        view
        returns (
            int256 currentBalance,
            int256 flow,
            bool liquidable,
            uint256 timeLeft
        );
}
