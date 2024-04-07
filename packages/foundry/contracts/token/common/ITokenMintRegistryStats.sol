// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title Multi-token mint registry interface.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
interface ITokenMintRegistryStats {
    struct TokenMintStats {
        uint256 totalMinted;
        uint256 totalMinters;
        mapping(address => uint256) minted;
        mapping(uint256 => address) mintAddresses;
    }

    event Minted(
        address indexed account,
        uint256 value,
        uint256 totalMinted,
        uint256 totalMinters
    );
}
