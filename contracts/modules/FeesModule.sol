// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Fee} from "../storage/Fee.sol";
import {IFeesModule} from "../interfaces/IFeesModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract FeesModule is IFeesModule {
    using Fee for Fee.Data;

    /**
     * @notice Emits the initial fees configuration
     * @param gratefulFeeTreasury The Grateful treasury profile ID
     * @param feePercentage The fee percentage to take from giver subscriptions
     */
    event FeesInitialized(bytes32 gratefulFeeTreasury, uint256 feePercentage);

    /// @inheritdoc	IFeesModule
    function initializeFeesModule(
        bytes32 gratefulFeeTreasury,
        uint256 feePercentage
    ) external override {
        OwnableStorage.onlyOwner();

        if (gratefulFeeTreasury == bytes32(0)) revert InputErrors.ZeroId();
        if (feePercentage == 0) revert InputErrors.ZeroAmount();

        Fee.Data storage store = Fee.load();

        store.setGratefulFeeTreasury(gratefulFeeTreasury);
        store.setFeePercentage(feePercentage);

        emit FeesInitialized(gratefulFeeTreasury, feePercentage);
    }

    /// @inheritdoc	IFeesModule
    function getFeeTreasuryId() external view override returns (bytes32) {
        return Fee.load().gratefulFeeTreasury;
    }

    /// @inheritdoc	IFeesModule
    function getFeePercentage() external view override returns (uint256) {
        return Fee.load().feePercentage;
    }

    /// @inheritdoc	IFeesModule
    function getFeeRate(uint256 rate) external view override returns (uint256) {
        return Fee.load().getFeeRate(rate);
    }
}
