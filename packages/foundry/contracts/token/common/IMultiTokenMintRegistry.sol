// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IMultiTokenMintRegistry {
    struct TokenMintStats {
        uint256 totalMinted;
        uint256 totalMinters;
        mapping(address => uint256) minted;
        mapping(uint256 => address) mintAddresses;
    }
}
