// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IMultiTokenBurnRegistry} from "./IMultiTokenBurnRegistry.sol";

/// @title Burn registry supporting multiple token contract addresses.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract MultiTokenBurnRegistry is IMultiTokenBurnRegistry {
    mapping(address token => IMultiTokenBurnRegistry.TokenBurnStats stats)
        private _burnStats;

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of burners.
    function totalBurners(address token) public view returns (uint256) {
        return _burnStats[token].totalBurners;
    }

    /// @notice Get the address of the burner at the given index.
    /// @dev Returns the address of the burner at the given index.
    /// @param token (address) - the address of the token.
    /// @param index (uint256) - the index of the burner.
    /// @return (address) - the address of the burner.
    function burner(
        address token,
        uint256 index
    ) public view returns (address) {
        return _burnStats[token].burnAddresses[index];
    }

    /// @notice Get the addresses of the first `amount` burners.
    /// @dev Returns the addresses of the first `amount` burners.
    /// @param token (address) - the address of the token.
    /// @param amount (uint256) - the amount of burners.
    /// @return (address[] memory) - the addresses of the burners.
    function firstBurners(
        address token,
        uint256 amount
    ) public view returns (address[] memory) {
        TokenBurnStats storage stats = _burnStats[token];
        uint256 burnersLength = stats.totalBurners;
        if (burnersLength < amount) {
            amount = burnersLength;
        }

        address[] memory burners = new address[](amount);
        mapping(uint256 => address) storage burnAddresses = stats.burnAddresses;

        for (uint256 i; i < amount;) {
            burners[i] = burnAddresses[i];
            unchecked {
                ++i;
            }
        }
        return burners;
    }

    /// @notice Get the addresses of the last `amount` burners.
    /// @dev Returns the addresses of the last `amount` burners.
    /// @param token (address) - the address of the token.
    /// @param amount (uint256) - the amount of burners.
    /// @return (address[] memory) - the addresses of the burners.
    function lastBurners(
        address token,
        uint256 amount
    ) public view returns (address[] memory) {
        TokenBurnStats storage stats = _burnStats[token];
        uint256 burnersLength = stats.totalBurners;
        if (burnersLength < amount) {
            amount = burnersLength;
        }

        address[] memory burners = new address[](amount);
        mapping(uint256 => address) storage burnAddresses = stats.burnAddresses;

        for (uint256 i; i < amount;) {
            burners[i] = burnAddresses[burnersLength - amount + i];
            unchecked {
                ++i;
            }
        }
        return burners;
    }

    /// @notice Get the amount of tokens burned by the given address.
    /// @dev Returns the amount of tokens burned by the given address.
    /// @param token (address) - the address of the token.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the total amount of tokens burned.
    function burnedFrom(
        address token,
        address account
    ) public view returns (uint256) {
        return _burnStats[token].burned[account];
    }

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of burners.
    function burns(address token) public view returns (uint256) {
        return _burnStats[token].totalBurners;
    }

    /// @notice Get the total amount of tokens burned.
    /// @dev Returns the total amount of tokens burned.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of tokens burned.
    function totalBurned(address token) public view returns (uint256) {
        return _burnStats[token].totalBurned;
    }

    /// @dev Update the burn registry, uses the sender as the token address.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function updateBurnRegistry(
        address account,
        uint256 value
    ) public payable virtual {
        address sender = msg.sender;
        TokenBurnStats storage stats = _burnStats[sender];
        stats.totalBurned += value;
        stats.burned[account] += value;
        stats.burnAddresses[stats.totalBurners] = account;
        stats.totalBurners = stats.totalBurners + 1;
    }
}
