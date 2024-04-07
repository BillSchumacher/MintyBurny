// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title Token Burn registry interface.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
interface ITokenBurnRegistryStats {
    struct TokenBurnStats {
        uint256 totalBurned;
        uint256 totalBurners;
        mapping(address account => uint256 value) burned;
        mapping(uint256 index => address account) burnAddresses;
    }

    event Burned(
        address indexed account,
        uint256 value,
        uint256 totalBurned,
        uint256 totalBurners
    );
}
