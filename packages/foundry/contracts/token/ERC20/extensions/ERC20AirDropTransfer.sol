// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20AirDropMismatch} from "./ERC20AirDropErrors.sol";

/// @title Air drop support for ERC20 tokens, using transfers.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20AirDropTransfer is ERC20 {
    /// @notice Emitted when tokens are airdropped to an address.
    /// @dev Emitted when tokens are airdropped to an address.
    /// @param from (address) - the address the tokens are airdropped from.
    /// @param to (address) - the address the tokens are airdropped to.
    /// @param value (uint256) - the value of the airdrop.
    event AirDropTransfer(
        address indexed from, address indexed to, uint256 value
    );

    function beforeAirDropTransfer() internal virtual {}
    function afterAirDropTransfer() internal virtual {}

    /// @notice Airdrop tokens to the given addresses via transfer.
    /// @dev Airdrop tokens to the given addresses via transfer.
    /// @param addresses (address[] memory) - the addresses to airdrop to.
    /// @param value (uint256) - the value to airdrop.
    function airDropTransfer(
        address[] memory addresses,
        uint256 value
    ) public virtual {
        beforeAirDropTransfer();
        uint256 len = addresses.length;
        address sender = msg.sender;
        for (uint256 i; i < len;) {
            address addr = addresses[i];
            _transfer(sender, addr, value);
            emit AirDropTransfer(sender, addr, value);
            unchecked {
                ++i;
            }
        }
        afterAirDropTransfer();
    }

    /// @notice Airdrop tokens to the given addresses via transfer split evenly.
    /// @dev Airdrop tokens to the given addresses via transfer split evenly.
    /// @param addresses (address[] memory) - the addresses to airdrop to.
    /// @param value (uint256) - the value to airdrop split among the addresses.
    function airDropTransferSplit(
        address[] memory addresses,
        uint256 value
    ) public virtual {
        beforeAirDropTransfer();
        uint256 len = addresses.length;
        address sender = msg.sender;
        uint256 splitValue = value / len;
        for (uint256 i; i < len;) {
            address addr = addresses[i];
            _transfer(sender, addr, splitValue);
            emit AirDropTransfer(sender, addr, splitValue);
            unchecked {
                ++i;
            }
        }
        afterAirDropTransfer();
    }

    /// @notice Airdrop tokens to the given addresses via transfer.
    /// @dev Airdrop tokens to the given addresses via transfer.
    /// @param addresses (address[] memory) - the addresses to airdrop to.
    /// @param values (uint256[] memory) - the values to airdrop.
    function airDropTransferValues(
        address[] memory addresses,
        uint256[] memory values
    ) public virtual {
        uint256 len = addresses.length;
        uint256 valLen = values.length;
        if (len != valLen) {
            revert ERC20AirDropMismatch(len, valLen);
        }
        address sender = msg.sender;
        beforeAirDropTransfer();
        for (uint256 i; i < len;) {
            address addr = addresses[i];
            uint256 value = values[i];
            _transfer(sender, addr, value);
            emit AirDropTransfer(sender, addr, value);
            unchecked {
                ++i;
            }
        }
        afterAirDropTransfer();
    }
}
