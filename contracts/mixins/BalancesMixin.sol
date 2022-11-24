// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {BalancesStorage} from "../storage/BalancesStorage.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract BalancesMixin is BalancesStorage {
    using SafeCast for uint256;

    function _increaseProfileBalance(
        bytes32 profileId,
        bytes32 vaultId,
        uint256 amount
    ) internal {
        Balance storage store = _getBalance(profileId, vaultId);
        store.balance += amount.toInt256();
    }

    function _getElapsedTime(uint256 lastUpdate)
        private
        view
        returns (uint256 elapsedTime)
    {
        if (lastUpdate == 0) return 0;
        if (block.timestamp <= lastUpdate) return 0;
        elapsedTime = block.timestamp - lastUpdate;
    }

    function _calculateBalance(
        int256 balance,
        int256 flow,
        uint256 time
    ) private pure returns (int256 currentBalance) {
        int256 totalFlow = flow * time.toInt256();

        currentBalance = balance + totalFlow;
    }

    function _balanceOf(bytes32 profileId, bytes32 vaultId)
        internal
        view
        returns (int256 balance)
    {
        Balance storage store = _getBalance(profileId, vaultId);

        uint256 elapsedTime = _getElapsedTime(store.lastUpdate);

        balance = _calculateBalance(store.balance, store.flow, elapsedTime);
    }
}
