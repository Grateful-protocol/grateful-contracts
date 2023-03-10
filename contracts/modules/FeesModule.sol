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

        Fee.Data storage store = Fee.load();

        if (store.isInitialized()) revert InputErrors.AlreadyInitialized();

        store.setGratefulFeeTreasury(gratefulFeeTreasury);
        store.setFeePercentage(feePercentage);

        emit FeesInitialized(gratefulFeeTreasury, feePercentage);
    }

    /// @inheritdoc	IFeesModule
    function setGratefulFeeTreasury(bytes32 newTreasury) external override {
        OwnableStorage.onlyOwner();
        if (newTreasury == 0) revert InputErrors.ZeroId();

        Fee.Data storage store = Fee.load();

        bytes32 oldTreasury = store.gratefulFeeTreasury;
        store.setGratefulFeeTreasury(newTreasury);

        emit GratefulFeeTreasuryChanged(oldTreasury, newTreasury);
    }

    /// @inheritdoc	IFeesModule
    function setFeePercentage(uint256 newFeePercentage) external override {
        OwnableStorage.onlyOwner();

        Fee.Data storage store = Fee.load();

        uint256 oldFeePercentage = store.feePercentage;
        store.setFeePercentage(newFeePercentage);

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
