// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Fee} from "../storage/Fee.sol";
import {IFeesModule} from "../interfaces/IFeesModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {InputErrors} from "../errors/InputErrors.sol";

/**
 * @title Module for managing fees.
 * @dev See IFeesModule.
 */
contract FeesModule is IFeesModule {
    using Fee for Fee.Data;

    /// @inheritdoc	IFeesModule
    function initializeFeesModule(
        bytes32 gratefulFeeTreasury,
        uint256 feePercentage
    ) external override {
        OwnableStorage.onlyOwner();

        if (gratefulFeeTreasury == bytes32(0)) revert InputErrors.ZeroId();

        Fee.Data storage fee = Fee.load();

        if (fee.isInitialized()) revert InputErrors.AlreadyInitialized();

        fee.setGratefulFeeTreasury(gratefulFeeTreasury);
        fee.setFeePercentage(feePercentage);

        emit FeesInitialized(gratefulFeeTreasury, feePercentage);
    }

    /// @inheritdoc	IFeesModule
    function setGratefulFeeTreasury(bytes32 newTreasury) external override {
        OwnableStorage.onlyOwner();
        if (newTreasury == 0) revert InputErrors.ZeroId();

        Fee.Data storage fee = Fee.load();

        bytes32 oldTreasury = fee.gratefulFeeTreasury;
        fee.setGratefulFeeTreasury(newTreasury);

        emit GratefulFeeTreasuryChanged(oldTreasury, newTreasury);
    }

    /// @inheritdoc	IFeesModule
    function setFeePercentage(uint256 newFeePercentage) external override {
        OwnableStorage.onlyOwner();

        Fee.Data storage fee = Fee.load();

        uint256 oldFeePercentage = fee.feePercentage;
        fee.setFeePercentage(newFeePercentage);

        emit FeePercentageChanged(oldFeePercentage, newFeePercentage);
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
