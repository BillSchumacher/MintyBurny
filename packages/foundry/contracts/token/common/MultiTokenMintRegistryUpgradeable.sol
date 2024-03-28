// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IMultiTokenMintRegistry} from "./IMultiTokenMintRegistry.sol";
import {ContextUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

/// @title Mint registry supporting multiple token contract addresses.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract MultiTokenMintRegistryUpgradeable is
    Initializable,
    IMultiTokenMintRegistry,
    ContextUpgradeable
{
    /// @custom:storage-location erc7201:MintyBurny.storage.MultiTokenMintRegistry
    struct MultiTokenMintRegistryStorage {
        mapping(address => IMultiTokenMintRegistry.TokenMintStats) _mintStats;
    }

    // keccak256(abi.encode(uint256(keccak256("MintyBurny.storage.MultiTokenMintRegistry")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MultiTokenMintRegistryStorageLocation =
        0x9a1c1e808f2bfa896c780520d91388311f35c67fdad8cc083afbd9d384d84100;

    function _getMultiTokenMintRegistryStorage()
        private
        pure
        returns (MultiTokenMintRegistryStorage storage $)
    {
        assembly {
            $.slot := MultiTokenMintRegistryStorageLocation
        }
    }

    function __MultiTokenMintRegistry_init() public virtual onlyInitializing {
        __MultiTokenMintRegistry_init_unchained();
    }

    function __MultiTokenMintRegistry_init_unchained()
        internal
        onlyInitializing
    {
        // MultiTokenMintRegistryStorage storage $ = _getMultiTokenMintRegistryStorage();
    }

    /// @notice Get the address of the minter at the given index.
    /// @dev Returns the address of the minter at the given index.
    /// @param index (uint256) - the index of the minter.
    /// @return (address) - the address of the minter.
    function minter(
        address token,
        uint256 index
    ) public view returns (address) {
        MultiTokenMintRegistryStorage storage $ =
            _getMultiTokenMintRegistryStorage();
        return $._mintStats[token].mintAddresses[index];
    }

    /// @notice Get the total amount of minters.
    /// @dev Returns the total amount of minters.
    /// @return (uint256) - the total amount of minters.
    function totalMinters(address token) public view returns (uint256) {
        MultiTokenMintRegistryStorage storage $ =
            _getMultiTokenMintRegistryStorage();
        return $._mintStats[token].totalMinters;
    }

    /// @notice Get the addresses of the first `amount` minters.
    /// @dev Returns the addresses of the first `amount` minters.
    /// @param amount (uint256) - the amount of minters.
    /// @return (address[] memory) - the addresses of the minters.
    function firstMinters(
        address token,
        uint256 amount
    ) public view returns (address[] memory) {
        MultiTokenMintRegistryStorage storage $ =
            _getMultiTokenMintRegistryStorage();
        TokenMintStats storage stats = $._mintStats[token];
        uint256 allMinters = stats.totalMinters;
        if (allMinters < amount) {
            amount = allMinters;
        }
        address[] memory result = new address[](amount);
        mapping(uint256 => address) storage mintAddresses = stats.mintAddresses;

        for (uint256 i; i < amount;) {
            result[i] = mintAddresses[i];
            unchecked {
                ++i;
            }
        }
        return result;
    }

    /// @notice Get the addresses of the last `amount` minters.
    /// @dev Returns the addresses of the last `amount` minters.
    /// @param amount (uint256) - the amount of minters.
    /// @return (address[] memory) - the addresses of the minters.
    function lastMinters(
        address token,
        uint256 amount
    ) public view returns (address[] memory) {
        MultiTokenMintRegistryStorage storage $ =
            _getMultiTokenMintRegistryStorage();
        TokenMintStats storage stats = $._mintStats[token];
        uint256 allMinters = stats.totalMinters;
        if (allMinters < amount) {
            amount = allMinters;
        }
        address[] memory results = new address[](amount);
        mapping(uint256 => address) storage mintAddresses = stats.mintAddresses;

        for (uint256 i; i < amount;) {
            results[i] = mintAddresses[allMinters - amount + i];
            unchecked {
                ++i;
            }
        }
        return results;
    }

    /// @notice Get the amount of tokens minted by the given address.
    /// @dev Returns the amount of tokens minted by the given address.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the amount of tokens minted.
    function mintedBy(
        address token,
        address account
    ) public view returns (uint256) {
        MultiTokenMintRegistryStorage storage $ =
            _getMultiTokenMintRegistryStorage();
        return $._mintStats[token].minted[account];
    }

    /// @notice Get the total amount of tokens minted.
    /// @dev Returns the total amount of tokens minted.
    /// @return (uint256) - the total amount of tokens minted.
    function totalMinted(address token) public view returns (uint256) {
        MultiTokenMintRegistryStorage storage $ =
            _getMultiTokenMintRegistryStorage();
        return $._mintStats[token].totalMinted;
    }

    /// @dev Update the mint registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to mint.
    function updateMintRegistry(
        address account,
        uint256 value
    ) public payable virtual {
        MultiTokenMintRegistryStorage storage $ =
            _getMultiTokenMintRegistryStorage();
        address sender = _msgSender();
        TokenMintStats storage stats = $._mintStats[sender];
        stats.totalMinted += value;
        stats.minted[account] += value;
        uint256 tokenMinters = stats.totalMinters;
        stats.mintAddresses[tokenMinters] = account;
        stats.totalMinters = tokenMinters + 1;
    }
}
