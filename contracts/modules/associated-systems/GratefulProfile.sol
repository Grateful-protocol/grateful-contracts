// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {NftModule} from "@synthetixio/core-modules/contracts/modules/NftModule.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {IProfilesModule} from "../../interfaces/IProfilesModule.sol";

/**
 * @title Module with ERC721Enumerable logic for the grateful profile.
 * @dev See NftModule
 */
// solhint-disable-next-line no-empty-blocks
contract GratefulProfile is NftModule {
    /**
     * @dev Updates profile RBAC storage to track the current owner of the token.
     */
    function _postTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (from != address(0)) {
            IProfilesModule(OwnableStorage.getOwner()).notifyProfileTransfer(
                to,
                tokenId
            );
        }
    }
}
