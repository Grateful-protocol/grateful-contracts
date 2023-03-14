// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {ERC4626, ERC20} from "solmate/mixins/ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// @audit Migrate to router proxy
contract Vault is ERC4626, Ownable {
    constructor(
        ERC20 asset_,
        address newOwner
    ) ERC4626(asset_, _vaultName(asset_), _vaultSymbol(asset_)) {
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

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    /// -----------------------------------------------------------------------
    /// ERC20 metadata generation
    /// -----------------------------------------------------------------------

    function _vaultName(
        ERC20 asset_
    ) internal view virtual returns (string memory vaultName) {
        vaultName = string.concat("ERC4626-Wrapped ", asset_.symbol());
    }

    function _vaultSymbol(
        ERC20 asset_
    ) internal view virtual returns (string memory vaultSymbol) {
        vaultSymbol = string.concat("w", asset_.symbol());
    }
}
