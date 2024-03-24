// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ERC20AirDropErrors.sol";

abstract contract ERC20AirDropMint is ERC20 {
    event AirDropMint(address indexed to, uint256 value);

    function beforeAirDropMint() internal virtual {}
    function afterAirDropMint() internal virtual {}

    /// @notice Airdrop tokens to the given addresses via minting.
    /// @dev Airdrop tokens to the given addresses via minting.
    /// @param addresses (address[] memory) - the addresses to airdrop to.
    /// @param value (uint256) - the value to airdrop.
    function airDropMint(
        address[] memory addresses,
        uint256 value
    ) public virtual {
        uint256 len = addresses.length;
        beforeAirDropMint();
        for (uint256 i; i < len; i++) {
            address to = addresses[i];
            _mint(to, value);
            emit AirDropMint(to, value);
        }
        afterAirDropMint();
    }

    /// @notice Airdrop tokens to the given addresses via minting split evenly.
    /// @dev Airdrop tokens to the given addresses via minting split evenly.
    /// @param addresses (address[] memory) - the addresses to airdrop to.
    /// @param value (uint256) - the value to airdrop.
    function airDropMintSplit(
        address[] memory addresses,
        uint256 value
    ) public virtual {
        uint256 len = addresses.length;
        beforeAirDropMint();
        uint256 splitValue = value / len;
        for (uint256 i; i < len; i++) {
            address to = addresses[i];
            _mint(to, splitValue);
            emit AirDropMint(to, splitValue);
        }
        afterAirDropMint();
    }

    /// @notice Airdrop tokens to the given addresses.
    /// @dev Airdrop tokens to the given addresses.
    /// @param addresses (address[] memory) - the addresses to airdrop to.
    /// @param values (uint256[] memory) - the values to airdrop.
    function airDropMintValues(
        address[] memory addresses,
        uint256[] memory values
    ) public virtual {
        uint256 len = addresses.length;
        uint256 valLen = values.length;
        if (len != valLen) {
            revert ERC20AirDropMismatch(len, valLen);
        }
        beforeAirDropMint();
        for (uint256 i; i < len; i++) {
            address to = addresses[i];
            uint256 value = values[i];
            _mint(to, value);
            emit AirDropMint(to, value);
        }
        afterAirDropMint();
    }
}
