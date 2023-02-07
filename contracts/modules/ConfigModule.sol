// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Config} from "../storage/Config.sol";
import {IConfigModule} from "../interfaces/IConfigModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract ConfigModule is IConfigModule {
    using Config for Config.Data;

    /// @inheritdoc	IConfigModule
    function initializeConfigModule(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired,
        address gratefulSubscription
    ) external override {
        OwnableStorage.onlyOwner();

        if (solvencyTimeRequired == 0) revert InputErrors.ZeroTime();
        if (liquidationTimeRequired == 0) revert InputErrors.ZeroTime();
        if (gratefulSubscription == address(0))
            revert InputErrors.ZeroAddress();

        Config.Data storage store = Config.load();

        store.setSolvencyTimeRequired(solvencyTimeRequired);
        store.setLiquidationTimeRequired(liquidationTimeRequired);
        store.setGratefulSubscription(gratefulSubscription);

        emit ConfigInitialized(
            solvencyTimeRequired,
            liquidationTimeRequired,
            gratefulSubscription
        );
    }

    /// @inheritdoc	IConfigModule
    function setSolvencyTimeRequired(
        uint256 newSolvencyTime
    ) external override {
        OwnableStorage.onlyOwner();
        if (newSolvencyTime == 0) revert InputErrors.ZeroTime();

        Config.Data storage config = Config.load();

        uint256 oldSolvencyTime = config.solvencyTimeRequired;
        config.setSolvencyTimeRequired(newSolvencyTime);

        emit SolvencyTimeChanged(oldSolvencyTime, newSolvencyTime);
    }

    /// @inheritdoc	IConfigModule
    function setLiquidationTimeRequired(
        uint256 newLiquidationTime
    ) external override {
        OwnableStorage.onlyOwner();
        if (newLiquidationTime == 0) revert InputErrors.ZeroTime();

        Config.Data storage config = Config.load();

        uint256 oldLiquidationTime = config.liquidationTimeRequired;
        config.setLiquidationTimeRequired(newLiquidationTime);

        emit LiquidationTimeChanged(oldLiquidationTime, newLiquidationTime);
    }

    /// @inheritdoc	IConfigModule
    function getSolvencyTimeRequired()
        external
        view
        override
        returns (uint256)
    {
        return Config.load().solvencyTimeRequired;
    }

    /// @inheritdoc	IConfigModule
    function getLiquidationTimeRequired()
        external
        view
        override
        returns (uint256)
    {
        return Config.load().liquidationTimeRequired;
    }

    /// @inheritdoc	IConfigModule
    function getGratefulSubscription()
        external
        view
        override
        returns (address)
    {
        return Config.load().gratefulSubscription;
    }
}
