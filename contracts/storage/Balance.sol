// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {SignedMath} from "@openzeppelin/contracts/utils/math/SignedMath.sol";
import {Config} from "../storage/Config.sol";

library Balance {
    using SafeCast for uint256;
    using SafeCast for int256;
    using SignedMath for int256;
    using Config for Config.Data;

    struct Data {
        int256 balance; // Total balance
        int216 flow; // Total flow (1e-20 per second)
        uint40 lastUpdate; // Last time profile balance was updated
    }

    function load(
        bytes32 profileId,
        bytes32 vaultId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Balance", profileId, vaultId));
        assembly {
            store.slot := s
        }
    }

    function increase(Data storage self, uint256 amount) internal {
        self.balance += amount.toInt256();
    }

    function decrease(Data storage self, uint256 amount) internal {
        self.balance -= amount.toInt256();
    }

    function settle(Data storage self) internal returns (int256 newBalance) {
        newBalance = balanceOf(self);

        self.balance = newBalance;
        self.lastUpdate = (block.timestamp).toUint40();
    }

    function increaseFlow(Data storage self, uint256 amount) internal {
        settle(self);

        self.flow += (amount.toInt256()).toInt216();
    }

    function decreaseFlow(Data storage self, uint256 amount) internal {
        settle(self);

        self.flow -= (amount.toInt256()).toInt216();
    }

    function balanceOf(
        Data storage self
    ) internal view returns (int256 balance) {
        uint256 elapsedTime = _getElapsedTime(self.lastUpdate);

        balance = _calculateBalance(self.balance, self.flow, elapsedTime);
    }

    function _getElapsedTime(
        uint256 lastUpdate
    ) private view returns (uint256 elapsedTime) {
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

    function _isSolvent(
        Data storage self,
        uint256 time
    ) private view returns (bool) {
        uint256 futureElapsedTime = _getElapsedTime(self.lastUpdate) + time;

        return
            _calculateBalance(self.balance, self.flow, futureElapsedTime) > 0;
    }

    function canWithdraw(Data storage self) internal view returns (bool) {
        uint256 time = Config.load().solvencyTimeRequired;
        return _isSolvent(self, time);
    }

    function canStartSubscription(
        Data storage self,
        uint256 rate
    ) internal view returns (bool) {
        uint256 time = Config.load().solvencyTimeRequired;

        int256 balance = balanceOf(self);
        int256 requiredBalance = (rate * time).toInt256();
        bool hasEnoughBalance = balance > requiredBalance;

        return hasEnoughBalance && _isSolvent(self, time);
    }

    function canBeLiquidated(Data storage self) internal view returns (bool) {
        uint256 time = Config.load().liquidationTimeRequired;
        bool hasNegativeFlow = self.flow < 0;
        return hasNegativeFlow && !_isSolvent(self, time);
    }

    function isNegative(Data storage self) internal view returns (bool) {
        int256 balance = balanceOf(self);
        return balance < 0;
    }

    function remainingTimeToZero(
        Data storage self
    ) internal view returns (uint256) {
        int256 balance = balanceOf(self);
        int256 flow = self.flow;

        if (flow >= 0 || balance <= 0) {
            return 0;
        } else {
            return uint256(balance) / flow.abs();
        }
    }
}
