// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Config} from "../storage/Config.sol";
import {IConfigModule} from "../interfaces/IConfigModule.sol";
import {OwnableMixin} from "@synthetixio/core-contracts/contracts/ownership/OwnableMixin.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract ConfigModule is IConfigModule, OwnableMixin {
    using Config for Config.Data;

    event ConfigInitialized(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired,
        address gratefulSubscription
    );

    function initializeConfigModule(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired,
        address gratefulSubscription
    ) external override onlyOwner {
        if (solvencyTimeRequired == 0) revert InputErrors.ZeroTime();
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

    function getSolvencyTimeRequired()
        external
        view
        override
        returns (uint256)
    {
        return Config.load().getSolvencyTimeRequired();
    }

    function getLiquidationTimeRequired()
        external
        view
        override
        returns (uint256)
    {
        return Config.load().getLiquidationTimeRequired();
    }

    function getGratefulSubscription()
        external
        view
        override
        returns (address)
    {
        return address(Config.load().getGratefulSubscription());
    }
}
