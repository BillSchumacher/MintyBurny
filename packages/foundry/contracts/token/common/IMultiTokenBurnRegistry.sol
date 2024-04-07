// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ITokenBurnRegistryStats} from "./ITokenBurnRegistryStats.sol";

/// @title Multi-token Burn registry interface.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
interface IMultiTokenBurnRegistry is ITokenBurnRegistryStats {
    event TokenBurned(
        address indexed token,
        address indexed account,
        uint256 value,
        uint256 totalBurned,
        uint256 totalBurners
    );

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of burners.
    function totalBurners(address token) external view returns (uint256);

    /// @notice Get the address of the burner at the given index.
    /// @dev Returns the address of the burner at the given index.
    /// @param token (address) - the address of the token.
    /// @param index (uint256) - the index of the burner.
    /// @return (address) - the address of the burner.
    function burner(
        address token,
        uint256 index
    ) external view returns (address);

    /// @notice Get the addresses of the first `amount` burners.
    /// @dev Returns the addresses of the first `amount` burners.
    /// @param token (address) - the address of the token.
    /// @param amount (uint256) - the amount of burners.
    /// @return (address[] memory) - the addresses of the burners.
    function firstBurners(
        address token,
        uint256 amount
    ) external view returns (address[] memory);

    /// @notice Get the addresses of the last `amount` burners.
    /// @dev Returns the addresses of the last `amount` burners.
    /// @param token (address) - the address of the token.
    /// @param amount (uint256) - the amount of burners.
    /// @return (address[] memory) - the addresses of the burners.
    function lastBurners(
        address token,
        uint256 amount
    ) external view returns (address[] memory);

    /// @notice Get the amount of tokens burned by the given address.
    /// @dev Returns the amount of tokens burned by the given address.
    /// @param token (address) - the address of the token.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the total amount of tokens burned.
    function burnedFrom(
        address token,
        address account
    ) external view returns (uint256);

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of burners.
    function burns(address token) external view returns (uint256);

    /// @notice Get the total amount of tokens burned.
    /// @dev Returns the total amount of tokens burned.
    /// @param token (address) - the address of the token.
    /// @return (uint256) - the total amount of tokens burned.
    function totalBurned(address token) external view returns (uint256);

    /// @dev Update the burn registry, uses the sender as the token address.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function updateBurnRegistry(
        address account,
        uint256 value
    ) external payable;
}
