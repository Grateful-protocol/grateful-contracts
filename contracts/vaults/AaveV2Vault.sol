// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {AaveV2ERC4626, ERC20, IAaveMining, ILendingPool} from "yield-daddy/aave-v2/AaveV2ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// @audit Migrate to router proxy
contract AaveV2Vault is AaveV2ERC4626, Ownable {
    constructor(
        ERC20 asset_,
        ERC20 aToken_,
        IAaveMining aaveMining_,
        address rewardRecipient_,
        ILendingPool lendingPool_,
        address newOwner
    )
        AaveV2ERC4626(
            asset_,
            aToken_,
            aaveMining_,
            rewardRecipient_,
            lendingPool_
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
