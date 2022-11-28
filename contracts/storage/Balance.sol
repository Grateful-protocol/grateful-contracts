// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

library Balance {
    using SafeCast for uint256;

    struct Data {
        int256 balance; // Total balance
        int216 flow; // Total flow (wei per second)
        uint40 lastUpdate; // Last time profile balance was updated
    }

    function load(bytes32 profileId, bytes32 vaultId)
        internal
        pure
        returns (Data storage store)
    {
        bytes32 s = keccak256(abi.encode("Balance", profileId, vaultId));
        assembly {
            store.slot := s
        }
    }

    function increase(Data storage self, uint256 amount) internal {
        self.balance += amount.toInt256();
    }

    function balanceOf(Data storage self)
        internal
        view
        returns (int256 balance)
    {
        uint256 elapsedTime = _getElapsedTime(self.lastUpdate);

        balance = _calculateBalance(self.balance, self.flow, elapsedTime);
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
}
