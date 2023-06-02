// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

// @custom:artifact @openzeppelin/contracts/utils/Base64.sol:Base64
library Base64 {
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
}

// @custom:artifact @openzeppelin/contracts/utils/Strings.sol:Strings
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
}

// @custom:artifact @openzeppelin/contracts/utils/math/Math.sol:Math
library Math {
    enum Rounding {
        Down,
        Up,
        Zero
    }
}

// @custom:artifact @synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol:OwnableStorage
library OwnableStorage {
    bytes32 private constant _SLOT_OWNABLE_STORAGE = keccak256(abi.encode("io.synthetix.core-contracts.Ownable"));
    struct Data {
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

// @custom:artifact @synthetixio/core-contracts/contracts/token/ERC721EnumerableStorage.sol:ERC721EnumerableStorage
library ERC721EnumerableStorage {
    bytes32 private constant _SLOT_ERC721_ENUMERABLE_STORAGE = keccak256(abi.encode("io.synthetix.core-contracts.ERC721Enumerable"));
    struct Data {
        mapping(uint256 => uint256) ownedTokensIndex;
        mapping(uint256 => uint256) allTokensIndex;
        mapping(address => mapping(uint256 => uint256)) ownedTokens;
        uint256[] allTokens;
    }
    function load() internal pure returns (Data storage store) {
        bytes32 s = _SLOT_ERC721_ENUMERABLE_STORAGE;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact @synthetixio/core-contracts/contracts/token/ERC721Storage.sol:ERC721Storage
library ERC721Storage {
    bytes32 private constant _SLOT_ERC721_STORAGE = keccak256(abi.encode("io.synthetix.core-contracts.ERC721"));
    struct Data {
        string name;
        string symbol;
        string baseTokenURI;
        mapping(uint256 => address) ownerOf;
        mapping(address => uint256) balanceOf;
        mapping(uint256 => address) tokenApprovals;
        mapping(address => mapping(address => bool)) operatorApprovals;
    }
    function load() internal pure returns (Data storage store) {
        bytes32 s = _SLOT_ERC721_STORAGE;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact @synthetixio/core-contracts/contracts/utils/SetUtil.sol:SetUtil
library SetUtil {
    struct UintSet {
        Bytes32Set raw;
    }
    struct AddressSet {
        Bytes32Set raw;
    }
    struct Bytes32Set {
        bytes32[] _values;
        mapping(bytes32 => uint) _positions;
    }
}

// @custom:artifact @synthetixio/core-modules/contracts/modules/NftModule.sol:NftModule
contract NftModule {
    bytes32 internal constant _INITIALIZED_NAME = "NftModule";
}

// @custom:artifact @synthetixio/core-modules/contracts/storage/AssociatedSystem.sol:AssociatedSystem
library AssociatedSystem {
    bytes32 public constant KIND_ERC20 = "erc20";
    bytes32 public constant KIND_ERC721 = "erc721";
    bytes32 public constant KIND_UNMANAGED = "unmanaged";
    struct Data {
        address proxy;
        address impl;
        bytes32 kind;
    }
    function load(bytes32 id) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("io.synthetix.core-modules.AssociatedSystem", id));
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact @synthetixio/core-modules/contracts/storage/Initialized.sol:Initialized
library Initialized {
    struct Data {
        bool initialized;
    }
    function load(bytes32 id) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("io.synthetix.code-modules.Initialized", id));
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/interfaces/IProfilesModule.sol:IProfilesModule
interface IProfilesModule {
    struct ProfilePermissions {
        address user;
        bytes32[] permissions;
    }
}

// @custom:artifact contracts/modules/ProfilesModule.sol:ProfilesModule
contract ProfilesModule {
    bytes32 private constant _GRATEFUL_PROFILE_NFT = "gratefulProfileNft";
}

// @custom:artifact contracts/modules/SubscriptionsModule.sol:SubscriptionsModule
contract SubscriptionsModule {
    bytes32 private constant _GRATEFUL_SUBSCRIPTION_NFT = "gratefulSubscriptionNft";
}

// @custom:artifact contracts/storage/Balance.sol:Balance
library Balance {
    struct Data {
        int256 balance;
        uint104 inflow;
        uint104 outflow;
        uint48 lastUpdate;
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
    bytes32 private constant _CONFIG_STORAGE_SLOT = keccak256(abi.encode("Config"));
    struct Data {
        uint256 solvencyTimeRequired;
        uint256 liquidationTimeRequired;
    }
    function load() internal pure returns (Data storage store) {
        bytes32 s = _CONFIG_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/Fee.sol:Fee
library Fee {
    bytes32 private constant _FEE_STORAGE_SLOT = keccak256(abi.encode("Fee"));
    struct Data {
        bytes32 gratefulFeeTreasury;
        uint256 feePercentage;
    }
    function load() internal pure returns (Data storage store) {
        bytes32 s = _FEE_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/Profile.sol:Profile
library Profile {
    struct Data {
        ProfileRBAC.Data rbac;
    }
    function load(bytes32 id) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Profile", id));
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/ProfileNft.sol:ProfileNft
library ProfileNft {
    struct Data {
        bytes32 profileId;
    }
    function load(address profile, uint256 tokenId) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("ProfileNft", profile, tokenId));
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/ProfileRBAC.sol:ProfileRBAC
library ProfileRBAC {
    bytes32 internal constant _ADMIN_PERMISSION = "ADMIN";
    bytes32 internal constant _WITHDRAW_PERMISSION = "WITHDRAW";
    bytes32 internal constant _SUBSCRIBE_PERMISSION = "SUBSCRIBE";
    bytes32 internal constant _UNSUBSCRIBE_PERMISSION = "UNSUBSCRIBE";
    bytes32 internal constant _EDIT_PERMISSION = "EDIT";
    struct Data {
        address owner;
        mapping(address => SetUtil.Bytes32Set) permissions;
        SetUtil.AddressSet permissionAddresses;
    }
}

// @custom:artifact contracts/storage/Subscription.sol:Subscription
library Subscription {
    struct Data {
        uint96 rate;
        uint80 feeRate;
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

// @custom:artifact contracts/storage/SubscriptionNft.sol:SubscriptionNft
library SubscriptionNft {
    bytes32 private constant _SUBSCRIPTION_NFT_STORAGE_SLOT = keccak256(abi.encode("SubscriptionNft"));
    struct Data {
        uint256 tokenIdCounter;
    }
    function load() internal pure returns (Data storage store) {
        bytes32 s = _SUBSCRIPTION_NFT_STORAGE_SLOT;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/SubscriptionRegistry.sol:SubscriptionRegistry
library SubscriptionRegistry {
    struct Data {
        uint256 subscriptionId;
    }
    function load(bytes32 giverId, bytes32 creatorId) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("SubscriptionRegistry", giverId, creatorId));
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
        bool paused;
        bool deactivated;
    }
    function load(bytes32 id) internal pure returns (Data storage store) {
        bytes32 s = keccak256(abi.encode("Vault", id));
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/utils/SubscriptionRenderer.sol:SubscriptionRenderer
library SubscriptionRenderer {
    uint256 internal constant MONTH_SECONDS = 30;
}
