// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IBalancesModule} from "../interfaces/IBalancesModule.sol";
import {Balance} from "../storage/Balance.sol";

contract BalancesModule is IBalancesModule {
    using Balance for Balance.Data;

    function balanceOf(bytes32 profileId, bytes32 vaultId)
        external
        view
        override
        returns (int256)
    {
        return Balance.load(profileId, vaultId).balanceOf();
    }
}
