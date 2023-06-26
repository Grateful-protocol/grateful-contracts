// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Config} from "../storage/Config.sol";

/**
 * @title Stores the balance and flow for a profile ID and vault ID tuple.
 *
 * Each profile has a different balance for each vault.
 */
library Balance {
    using SafeCast for uint256;
    using Config for Config.Data;

    struct Data {
        /**
         * @dev Amount of settled balance.
         *
         * Vault balance is normalized to 20 decimals.
         *
         * This can be increase or decrease during depositing or withdrawing funds,
         * or also after settling the elapsed time due to a flow change.
         *
         * The system accepts negative balances if the subscriptions were not liquidated at time.
         */
        int256 balance;
        /**
         * @dev Current balance incoming flow.
         *
         * Flow unit is 1e-20 per second.
         *
         * This reperesents the amount of balance that is increasing each second.
         */
        uint104 inflow;
        /**
         * @dev Current balance outgoing flow.
         *
         * Flow unit is 1e-20 per second.
         *
         * This reperesents the amount of balance that is decreasing each second.
         */
        uint104 outflow;
        /**
         * @dev Last time balance was updated.
         *
         * This is used to calculate the current balance.
         */
        uint48 lastUpdate;
    }

    /**
     * @dev Loads the balance for the profile/vault tuple.
     */
    function load(
        bytes32 profileId,
        bytes32 vaultId
    ) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Balance", profileId, vaultId));
        assembly {
            store.slot := s
        }
    }

    /**
     * @dev Increases the settled balance by `amount`.
     */
    function increase(Data storage self, uint256 amount) internal {
        self.balance += amount.toInt256();
    }

    /**
     * @dev Decreases the settled balance by `amount`.
     */
    function decrease(Data storage self, uint256 amount) internal {
        self.balance -= amount.toInt256();
    }

    /**
     * @dev Calculates the current balance, stores it and returns it.
     */
    function settle(Data storage self) internal returns (int256 newBalance) {
        newBalance = balanceOf(self);

        self.balance = newBalance;
        self.lastUpdate = (block.timestamp).toUint48();
    }

    /**
     * @dev Increases the current inflow by `amount`.
     */
    function increaseInflow(Data storage self, uint256 amount) internal {
        settle(self);

        self.inflow += amount.toUint104();
    }

    /**
     * @dev Increases the current outflow by `amount`.
     */
    function increaseOutflow(Data storage self, uint256 amount) internal {
        settle(self);

        self.outflow += amount.toUint104();
    }

    /**
     * @dev Decreases the current inflow by `amount`.
     */
    function decreaseInflow(Data storage self, uint256 amount) internal {
        settle(self);

        self.inflow -= amount.toUint104();
    }

    /**
     * @dev Decreases the current outflow by `amount`.
     */
    function decreaseOutflow(Data storage self, uint256 amount) internal {
        settle(self);

        self.outflow -= amount.toUint104();
    }

    /**
     * @dev Calculate the current total flow.
     *
     * This means the inflow minus the outflow. It could be negative.
     */
    function getFlow(Data storage self) internal view returns (int256) {
        int256 totalInflow = (uint256(self.inflow)).toInt256();
        int256 totalOutflow = (uint256(self.outflow)).toInt256();
        return totalInflow - totalOutflow;
    }

    /**
     * @dev Returns the current balance since last update.
     */
    function balanceOf(
        Data storage self
    ) internal view returns (int256 balance) {
        uint256 elapsedTime = _getElapsedTime(self.lastUpdate);

        balance = _calculateBalance(
            self.balance,
            self.inflow,
            self.outflow,
            elapsedTime
        );
    }

    /**
     * @dev Returns the elapsed time since `lastUpdate`.
     */
    function _getElapsedTime(
        uint256 lastUpdate
    ) private view returns (uint256 elapsedTime) {
        if (lastUpdate == 0) return 0;
        if (block.timestamp <= lastUpdate) return 0;
        elapsedTime = block.timestamp - lastUpdate;
    }

    /**
     * @dev Calculates the current balance: `balance` + (`inflow` * `time`) - (`outflow` * `time`)
     */
    function _calculateBalance(
        int256 balance,
        uint256 inflow,
        uint256 outflow,
        uint256 time
    ) private pure returns (int256 currentBalance) {
        int256 totalInflow = (inflow * time).toInt256();
        int256 totalOutflow = (outflow * time).toInt256();
        int256 totalFlow = totalInflow - totalOutflow;

        currentBalance = balance + totalFlow;
    }

    /**
     * @dev Returns if the balance is solvent for a given `time`.
     *
     * It adds the input time to the current elapsed time to calculate if the balance is positive in a future time.
     */
    function _isSolvent(
        Data storage self,
        uint256 time
    ) private view returns (bool) {
        uint256 futureElapsedTime = _getElapsedTime(self.lastUpdate) + time;

        return
            _calculateBalance(
                self.balance,
                self.inflow,
                self.outflow,
                futureElapsedTime
            ) > 0;
    }

    /**
     * @dev Returns if the balance is greater or equal to the required balance.
     *
     * The required balance is the balance needed to cover the `time` of outflow.
     */
    function _hasEnoughBalance(
        Data storage self,
        uint256 time
    ) private view returns (bool) {
        int256 balance = balanceOf(self);
        int256 requiredBalance = (self.outflow * time).toInt256();
        return balance >= requiredBalance;
    }

    /**
     * @dev Returns if the profile with the current balance can make a withdrawal.
     *
     * To make a withdrawal the current balance must cover the required time of flow
     * and also must be solvent for that lapse.
     *
     * Uses the solvency time required from the system to evaluate the solvency.
     */
    function canWithdraw(Data storage self) internal view returns (bool) {
        uint256 time = Config.load().solvencyTimeRequired;
        return _hasEnoughBalance(self, time);
    }

    /**
     * @dev Returns if the profile with the current balance can make a new subscription.
     *
     * To make a new subscription the current balance must cover the required time of flow
     * and also must be solvent for that lapse.
     *
     * Uses the solvency time required from the system to evaluate the solvency.
     */
    function canStartSubscription(
        Data storage self
    ) internal view returns (bool) {
        uint256 time = Config.load().solvencyTimeRequired;
        return _hasEnoughBalance(self, time);
    }

    /**
     * @dev Returns if the profile with the current balance can be liquidated.
     *
     * To be liquidated the balance must have negative flow and also not be solvent
     * for the required time.
     *
     * Uses the liquidation time required from the system to evaluate the solvency.
     */
    function canBeLiquidated(Data storage self) internal view returns (bool) {
        uint256 time = Config.load().liquidationTimeRequired;
        bool hasNegativeFlow = self.outflow > self.inflow;
        return hasNegativeFlow && !_isSolvent(self, time);
    }

    /**
     * @dev Returns if the balance is negative
     */
    function isNegative(Data storage self) internal view returns (bool) {
        int256 balance = balanceOf(self);
        return balance < 0;
    }

    /**
     * @dev Returns the remaining time to zero balance.
     *
     * If the flow is positive (or zero) or the balance is already negative (or zero), the time is zero.
     *
     * remainingTime = currentBalance / flow
     */
    function remainingTimeToZero(
        Data storage self
    ) internal view returns (uint256) {
        int256 balance = balanceOf(self);
        uint256 inflow = self.inflow;
        uint256 outflow = self.outflow;

        if (inflow >= outflow || balance <= 0) {
            return 0;
        } else {
            return uint256(balance) / (outflow - inflow);
        }
    }
}
