// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract BalancesStorage {
    struct Balance {
        int256 balance; // Total balance
        int216 flow; // Total flow (wei per second)
        uint40 lastUpdate; // Last time profile balance was updated
    }

    struct BalancesStore {
        /// @dev profileId => vaultId => balance struct
        mapping(bytes32 => mapping(bytes32 => Balance)) _balances;
    }

    function _balancesStore()
        internal
        pure
        returns (BalancesStore storage store)
    {
        assembly {
            // bytes32(uint(keccak256("io.grateful.balances")) - 1)
            store.slot := 0xd51124b5b6976db045b230316c34ac94ba4fb9ae2dc93b794c18058019023373
        }
    }

    function _getBalance(bytes32 profileId, bytes32 vaultId)
        internal
        view
        returns (Balance storage balance)
    {
        balance = _balancesStore()._balances[profileId][vaultId];
    }
}
