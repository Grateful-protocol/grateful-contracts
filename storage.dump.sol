// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// @custom:artifact @synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol:OwnableStorage
library OwnableStorage {
    bytes32 private constant _SLOT_OWNABLE_STORAGE = keccak256(abi.encode("io.synthetix.core-contracts.Ownable"));
    struct Data {
        bool initialized;
        address owner;
        address nominatedOwner;
    }
    function load() internal pure returns (Data storage store) {
        bytes32 s = _SLOT_OWNABLE_STORAGE;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact @synthetixio/core-contracts/contracts/proxy/ProxyStorage.sol:ProxyStorage
contract ProxyStorage {
    bytes32 private constant _SLOT_PROXY_STORAGE = keccak256(abi.encode("io.synthetix.core-contracts.Proxy"));
    struct ProxyStore {
        address implementation;
        bool simulatingUpgrade;
    }
    function _proxyStore() internal pure returns (ProxyStore storage store) {
        bytes32 s = _SLOT_PROXY_STORAGE;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/Balance.sol:Balance
library Balance {
    struct Data {
        int256 balance;
        int216 flow;
        uint40 lastUpdate;
    }
    function load(bytes32 profileId, bytes32 vaultId) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Balance", profileId, vaultId));
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/Config.sol:Config
library Config {
    bytes32 private constant CONFIG_STORAGE_SLOT = keccak256(abi.encode("Config"));
    struct Data {
        uint256 solvencyTimeRequired;
        uint256 liquidationTimeRequired;
        address gratefulSubscription;
    }
    function load() internal pure returns (Data storage store) {
        bytes32 s = CONFIG_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/Fee.sol:Fee
library Fee {
    bytes32 private constant FEE_STORAGE_SLOT = keccak256(abi.encode("Fee"));
    struct Data {
        bytes32 gratefulFeeTreasury;
        uint256 feePercentage;
    }
    function load() internal pure returns (Data storage store) {
        bytes32 s = FEE_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/Profile.sol:Profile
library Profile {
    struct Data {
        bool allowed;
    }
    function load(address profile) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Profile", profile));
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/Subscription.sol:Subscription
library Subscription {
    struct Data {
        uint256 rate;
        uint176 feeRate;
        uint40 lastUpdate;
        uint40 duration;
        bytes32 creatorId;
        bytes32 vaultId;
    }
    function load(uint256 subscriptionId) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Subscription", subscriptionId));
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/SubscriptionId.sol:SubscriptionId
library SubscriptionId {
    struct Data {
        uint256 subscriptionId;
    }
    function load(bytes32 giverId, bytes32 creatorId) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("SubscriptionId", giverId, creatorId));
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/Vault.sol:Vault
library Vault {
    struct Data {
        address impl;
        uint256 decimalsNormalizer;
        uint256 minRate;
        uint256 maxRate;
    }
    function load(bytes32 id) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Vault", id));
        assembly {
            store.slot := s
        }
    }
}
