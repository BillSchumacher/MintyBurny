// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20AirDropMismatch} from "./ERC20AirDropErrorsUpgradeable.sol";

/// @title Air drop support for ERC20 tokens, using minting.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20AirDropMintUpgradeable is
    Initializable,
    ERC20Upgradeable
{
    /// @notice Emitted when tokens are airdropped to an address.
    /// @dev Emitted when tokens are airdropped to an address.
    /// @param to (address) - the address the tokens are airdropped to.
    /// @param value (uint256) - the value of the airdrop.
    event AirDropMint(address indexed to, uint256 value);

    function __ERC20AirDropMint_init() internal onlyInitializing {
        __ERC20AirDropMint_init_unchained();
    }

    function __ERC20AirDropMint_init_unchained() internal onlyInitializing {}

    function beforeAirDropMint(
        address account,
        uint256 value
    ) internal virtual {}

    function afterAirDropMint(
        address account,
        uint256 value
    ) internal virtual {}

    /// @notice Airdrop tokens to the given addresses via minting.
    /// @dev Airdrop tokens to the given addresses via minting.
    /// @param addresses (address[] memory) - the addresses to airdrop to.
    /// @param value (uint256) - the value to airdrop.
    function airDropMint(
        address[] memory addresses,
        uint256 value
    ) public virtual {
        uint256 len = addresses.length;
        for (uint256 i; i < len;) {
            address to = addresses[i];
            beforeAirDropMint(to, value);
            _mint(to, value);
            emit AirDropMint(to, value);
            afterAirDropMint(to, value);
            unchecked {
                ++i;
            }
        }
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
        uint256 splitValue = value / len;
        for (uint256 i; i < len;) {
            address to = addresses[i];
            beforeAirDropMint(to, splitValue);
            _mint(to, splitValue);
            emit AirDropMint(to, splitValue);
            afterAirDropMint(to, splitValue);
            unchecked {
                ++i;
            }
        }
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
        for (uint256 i; i < len;) {
            address to = addresses[i];
            uint256 value = values[i];

            beforeAirDropMint(to, value);
            _mint(to, value);
            afterAirDropMint(to, value);
            emit AirDropMint(to, value);
            unchecked {
                ++i;
            }
        }
    }
}
