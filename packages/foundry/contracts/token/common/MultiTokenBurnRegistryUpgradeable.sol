// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IMultiTokenBurnRegistry} from "./IMultiTokenBurnRegistry.sol";
import {ContextUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

/// @title Burn registry supporting multiple token contract addresses.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract MultiTokenBurnRegistryUpgradeable is
    Initializable,
    IMultiTokenBurnRegistry,
    ContextUpgradeable
{
    /// @custom:storage-location erc7201:MintyBurny.storage.MultiTokenBurnRegistry
    struct MultiTokenBurnRegistryStorage {
        mapping(address => IMultiTokenBurnRegistry.TokenBurnStats) _burnStats;
    }

    // keccak256(abi.encode(uint256(keccak256("MintyBurny.storage.MultiTokenBurnRegistry")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MultiTokenBurnRegistryStorageLocation =
        0x8d7dd2605cd348455246d20287b62394203b2c84a04b5d85f103846a6bc7ee00;

    function _getMultiTokenBurnRegistryStorage()
        private
        pure
        returns (MultiTokenBurnRegistryStorage storage $)
    {
        assembly {
            $.slot := MultiTokenBurnRegistryStorageLocation
        }
    }

    function __MultiTokenBurnRegistry_init() public virtual onlyInitializing {
        __MultiTokenBurnRegistry_init_unchained();
    }

    function __MultiTokenBurnRegistry_init_unchained()
        internal
        onlyInitializing
    {
        // MultiTokenBurnRegistryStorage storage $ = _getMultiTokenBurnRegistryStorage();
    }

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of burners.
    function totalBurners(address token) external view returns (uint256) {
        MultiTokenBurnRegistryStorage storage $ =
            _getMultiTokenBurnRegistryStorage();
        return $._burnStats[token].totalBurners;
    }

    /// @notice Get the address of the burner at the given index.
    /// @dev Returns the address of the burner at the given index.
    /// @param token (address) - the address of the token.
    /// @param index (uint256) - the index of the burner.
    /// @return (address) - the address of the burner.
    function burner(
        address token,
        uint256 index
    ) external view returns (address) {
        MultiTokenBurnRegistryStorage storage $ =
            _getMultiTokenBurnRegistryStorage();
        return $._burnStats[token].burnAddresses[index];
    }

    /// @notice Get the addresses of the first `amount` burners.
    /// @dev Returns the addresses of the first `amount` burners.
    /// @param token (address) - the address of the token.
    /// @param amount (uint256) - the amount of burners.
    /// @return (address[] memory) - the addresses of the burners.
    function firstBurners(
        address token,
        uint256 amount
    ) external view returns (address[] memory) {
        MultiTokenBurnRegistryStorage storage $ =
            _getMultiTokenBurnRegistryStorage();
        TokenBurnStats storage stats = $._burnStats[token];
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
    ) external view returns (address[] memory) {
        MultiTokenBurnRegistryStorage storage $ =
            _getMultiTokenBurnRegistryStorage();
        TokenBurnStats storage stats = $._burnStats[token];
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
    ) external view returns (uint256) {
        MultiTokenBurnRegistryStorage storage $ =
            _getMultiTokenBurnRegistryStorage();
        return $._burnStats[token].burned[account];
    }

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of burners.
    function burns(address token) external view returns (uint256) {
        MultiTokenBurnRegistryStorage storage $ =
            _getMultiTokenBurnRegistryStorage();
        return $._burnStats[token].totalBurners;
    }

    /// @notice Get the total amount of tokens burned.
    /// @dev Returns the total amount of tokens burned.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of tokens burned.
    function totalBurned(address token) external view returns (uint256) {
        MultiTokenBurnRegistryStorage storage $ =
            _getMultiTokenBurnRegistryStorage();
        return $._burnStats[token].totalBurned;
    }

    /// @dev Update the burn registry, uses the sender as the token address.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function updateBurnRegistry(
        address account,
        uint256 value
    ) external payable virtual {
        MultiTokenBurnRegistryStorage storage $ =
            _getMultiTokenBurnRegistryStorage();
        address sender = _msgSender();
        TokenBurnStats storage stats = $._burnStats[sender];
        stats.totalBurned += value;
        unchecked {
            stats.burned[account] += value;
            stats.burnAddresses[stats.totalBurners] = account;
            stats.totalBurners = stats.totalBurners + 1;
        }
        emit TokenBurned(
            sender, account, value, stats.totalBurned, stats.totalBurners
        );
    }
}
