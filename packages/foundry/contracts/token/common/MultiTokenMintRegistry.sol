// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IMultiTokenMintRegistry} from "./IMultiTokenMintRegistry.sol";

/// @title Mint registry supporting multiple token contract addresses.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract MultiTokenMintRegistry is IMultiTokenMintRegistry {
    mapping(address token => IMultiTokenMintRegistry.TokenMintStats) private
        _mintStats;

    /// @notice Get the address of the minter at the given index.
    /// @dev Returns the address of the minter at the given index.
    /// @param index (uint256) - the index of the minter.
    /// @return (address) - the address of the minter.
    function minter(
        address token,
        uint256 index
    ) public view returns (address) {
        return _mintStats[token].mintAddresses[index];
    }

    /// @notice Get the total amount of minters.
    /// @dev Returns the total amount of minters.
    /// @return (uint256) - the total amount of minters.
    function totalMinters(address token) public view returns (uint256) {
        return _mintStats[token].totalMinters;
    }

    /// @notice Get the addresses of the first `amount` minters.
    /// @dev Returns the addresses of the first `amount` minters.
    /// @param amount (uint256) - the amount of minters.
    /// @return (address[] memory) - the addresses of the minters.
    function firstMinters(
        address token,
        uint256 amount
    ) public view returns (address[] memory) {
        TokenMintStats storage stats = _mintStats[token];
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
        TokenMintStats storage stats = _mintStats[token];
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
        return _mintStats[token].minted[account];
    }

    /// @notice Get the total amount of tokens minted.
    /// @dev Returns the total amount of tokens minted.
    /// @return (uint256) - the total amount of tokens minted.
    function totalMinted(address token) public view returns (uint256) {
        return _mintStats[token].totalMinted;
    }

    /// @dev Update the mint registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to mint.
    function updateMintRegistry(
        address account,
        uint256 value
    ) public payable virtual {
        address sender = msg.sender;
        TokenMintStats storage stats = _mintStats[sender];
        stats.totalMinted += value;
        stats.minted[account] += value;
        uint256 tokenMinters = stats.totalMinters;
        stats.mintAddresses[tokenMinters] = account;
        stats.totalMinters = tokenMinters + 1;
    }
}
