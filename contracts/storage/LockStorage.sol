//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract LockStorage {
    struct LockStore {
        bool initialized;
        uint256 unlockTime;
        address payable owner;
    }

    function _lockStore() internal pure returns (LockStore storage store) {
        assembly {
            // bytes32(uint(keccak256("io.synthetix.global")) - 1)
            store.slot := 0x8f203f5ee9f9a1d361b4a0f56abfdac49cdd246db58538b151edf87309e955b9
        }
    }
}
