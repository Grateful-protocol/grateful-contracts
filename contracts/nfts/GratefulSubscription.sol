// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IGratefulSubscription} from "../interfaces/IGratefulSubscription.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// @audit Migrate to router proxy
contract GratefulSubscription is IGratefulSubscription, ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Grateful Protocol Subscription", "GPS") {
        _tokenIdCounter.increment();
    }

    function safeMint(address to) external override onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function getCurrentTokenId() public view override returns (uint256) {
        return _tokenIdCounter.current();
    }
}
