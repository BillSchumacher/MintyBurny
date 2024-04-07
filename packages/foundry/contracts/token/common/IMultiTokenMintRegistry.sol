// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ITokenMintRegistryStats} from "./ITokenMintRegistryStats.sol";

/// @title Multi-token mint registry interface.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
interface IMultiTokenMintRegistry is ITokenMintRegistryStats {
    event TokenMinted(
        address indexed token,
        address indexed account,
        uint256 value,
        uint256 totalMinted,
        uint256 totalMinters
    );
    /// @notice Get the address of the minter at the given index.
    /// @dev Returns the address of the minter at the given index.
    /// @param token (address) - the address of the token.
    /// @param index (uint256) - the index of the minter.
    /// @return (address) - the address of the minter.

    function minter(
        address token,
        uint256 index
    ) external view returns (address);

    /// @notice Get the total amount of minters.
    /// @dev Returns the total amount of minters.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of minters.
    function totalMinters(address token) external view returns (uint256);

    /// @notice Get the addresses of the first `amount` minters.
    /// @dev Returns the addresses of the first `amount` minters.
    /// @param token (address) - the address of the token.
    /// @param amount (uint256) - the amount of minters.
    /// @return (address[] memory) - the addresses of the minters.
    function firstMinters(
        address token,
        uint256 amount
    ) external view returns (address[] memory);

    /// @notice Get the addresses of the last `amount` minters.
    /// @dev Returns the addresses of the last `amount` minters.
    /// @param token (address) - the address of the token.
    /// @param amount (uint256) - the amount of minters.
    /// @return (address[] memory) - the addresses of the minters.
    function lastMinters(
        address token,
        uint256 amount
    ) external view returns (address[] memory);

    /// @notice Get the amount of tokens minted by the given address.
    /// @dev Returns the amount of tokens minted by the given address.
    /// @param token (address) - the address of the token.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the amount of tokens minted.
    function mintedBy(
        address token,
        address account
    ) external view returns (uint256);

    /// @notice Get the total amount of tokens minted.
    /// @dev Returns the total amount of tokens minted.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of tokens minted.
    function totalMinted(address token) external view returns (uint256);

    /// @dev Update the mint registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to mint.
    function updateMintRegistry(
        address account,
        uint256 value
    ) external payable;
}
