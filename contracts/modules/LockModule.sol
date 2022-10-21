// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {LockStorage} from "../storage/LockStorage.sol";
import {ILockModule} from "../interfaces/ILockModule.sol";
import "@synthetixio/core-contracts/contracts/initializable/InitializableMixin.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract LockModule is LockStorage, InitializableMixin, ILockModule {
    event Withdrawal(uint256 amount, uint256 when);

    function initialize(uint256 _unlockTime)
        external
        payable
        override
        onlyIfNotInitialized
    {
        require(
            block.timestamp < _unlockTime,
            "Unlock time should be in the future"
        );

        _lockStore().unlockTime = _unlockTime;
        _lockStore().owner = payable(msg.sender);
        _lockStore().initialized = true;
    }

    function withdraw() external override {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log("Unlock time is %o and block timestamp is %o", unlockTime, block.timestamp);

        require(
            block.timestamp >= _lockStore().unlockTime,
            "You can't withdraw yet"
        );
        require(msg.sender == _lockStore().owner, "You aren't the owner");

        emit Withdrawal(address(this).balance, block.timestamp);

        _lockStore().owner.transfer(address(this).balance);
    }

    function getUnlockTime() external view override returns (uint256) {
        return _lockStore().unlockTime;
    }

    function getOwner() external view override returns (address) {
        return _lockStore().owner;
    }

    function _isInitialized() internal view virtual override returns (bool) {
        return _lockStore().initialized;
    }

    function isLockModuleInitialized() external view override returns (bool) {
        return _isInitialized();
    }
}
