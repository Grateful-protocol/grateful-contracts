//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ILockModule {
    function initialize(uint _unlockTime) external payable;

    function withdraw() external;

    function getUnlockTime() external view returns (uint256);

    function getOwner() external view returns (address);

    function isLockModuleInitialized() external view returns (bool);
}
