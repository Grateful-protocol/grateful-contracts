// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {AaveV3ERC4626, ERC20, IPool, IRewardsController} from "yield-daddy/aave-v3/AaveV3ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// @audit Migrate to router proxy
contract AaveV3Vault is AaveV3ERC4626, Ownable {
    constructor(
        ERC20 asset_,
        ERC20 aToken_,
        IPool lendingPool_,
        address rewardRecipient_,
        IRewardsController rewardsController_,
        address newOwner
    )
        AaveV3ERC4626(
            asset_,
            aToken_,
            lendingPool_,
            rewardRecipient_,
            rewardsController_
        )
    {
        transferOwnership(newOwner);
    }

    function deposit(
        uint256 assets,
        address receiver
    ) public override onlyOwner returns (uint256 shares) {
        return super.deposit(assets, receiver);
    }

    function mint(
        uint256 shares,
        address receiver
    ) public override onlyOwner returns (uint256 assets) {
        return super.mint(shares, receiver);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner_
    ) public override onlyOwner returns (uint256 shares) {
        return super.withdraw(assets, receiver, owner_);
    }

    function redeem(
        uint256 shares,
        address receiver,
        address owner_
    ) public override onlyOwner returns (uint256 assets) {
        return super.redeem(shares, receiver, owner_);
    }
}
