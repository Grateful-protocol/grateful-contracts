// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ILiquidationsModule {
    function liquidate(
        bytes32 giverId,
        bytes32 creatorId,
        bytes32 liquidatorId
    ) external;
}
