// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Fee} from "../storage/Fee.sol";
import {IFeesModule} from "../interfaces/IFeesModule.sol";
import {OwnableMixin} from "@synthetixio/core-contracts/contracts/ownership/OwnableMixin.sol";
import {InputErrors} from "../errors/InputErrors.sol";

contract FeesModule is IFeesModule, OwnableMixin {
    using Fee for Fee.Data;

    event FeesInitialized(bytes32 gratefulFeeTreasury, uint256 feePercentage);

    function initializeFeesModule(
        bytes32 gratefulFeeTreasury,
        uint256 feePercentage
    ) external override onlyOwner {
        Fee.Data storage store = Fee.load();

        store.setGratefulFeeTreasury(gratefulFeeTreasury);
        store.setFeePercentage(feePercentage);

        emit FeesInitialized(gratefulFeeTreasury, feePercentage);
    }
}
