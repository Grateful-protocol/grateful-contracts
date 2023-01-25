// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Config} from "../storage/Config.sol";
import {IConfigModule} from "../interfaces/IConfigModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract ConfigModule is IConfigModule {
    using Config for Config.Data;

    /**
     * @notice Emits the initial configuration
     * @param solvencyTimeRequired The time required to remain solvent
     * @param liquidationTimeRequired The time required to avoid liquidation
     * @param gratefulSubscription The Grateful Subscription NFT address
     */
    event ConfigInitialized(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired,
        address gratefulSubscription
    );

    /// @inheritdoc	IConfigModule
    function initializeConfigModule(
        uint256 solvencyTimeRequired,
        uint256 liquidationTimeRequired,
        address gratefulSubscription
    ) external override {
        OwnableStorage.onlyOwner();

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

    /// @inheritdoc	IConfigModule
    function getSolvencyTimeRequired()
        external
        view
        override
        returns (uint256)
    {
        return Config.load().getSolvencyTimeRequired();
    }

    /// @inheritdoc	IConfigModule
    function getLiquidationTimeRequired()
        external
        view
        override
        returns (uint256)
    {
        return Config.load().getLiquidationTimeRequired();
    }

    /// @inheritdoc	IConfigModule
    function getGratefulSubscription()
        external
        view
        override
        returns (address)
    {
        return address(Config.load().getGratefulSubscription());
    }
}
