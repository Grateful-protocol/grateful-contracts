// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IBalancesModule} from "../interfaces/IBalancesModule.sol";
import {BalancesMixin} from "../mixins/BalancesMixin.sol";

contract BalancesModule is IBalancesModule, BalancesMixin {
    function balanceOf(bytes32 profileId, bytes32 vaultId)
        external
        view
        override
        returns (int256)
    {
        return _balanceOf(profileId, vaultId);
    }
}
