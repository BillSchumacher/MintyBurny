// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IMultiTokenBurnRegistry {
    struct TokenBurnStats {
        uint256 totalBurned;
        uint256 totalBurners;
        mapping(address account => uint256 value) burned;
        mapping(uint256 index => address account) burnAddresses;
    }
}
