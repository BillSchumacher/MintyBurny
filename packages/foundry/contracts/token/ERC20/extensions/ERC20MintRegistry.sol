// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {TokenMintRegistry} from "../../common/TokenMintRegistry.sol";

/// @title A smart contract that allows minting tokens and tracking the minting.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20MintRegistry is Context, ERC20, TokenMintRegistry {
    /// @notice Mints a `value` amount of tokens.
    /// @dev Mints a `value` amount of tokens for the caller.
    /// See {ERC20-_mint}.
    /// @param value (uint256) - the amount of tokens to mint.
    function mint(uint256 value) public payable virtual {
        address sender = _msgSender();
        beforeMint(sender, sender, value);
        _mint(sender, value);
        updateMintRegistry(sender, value);
    }

    /// @notice Mints a `value` amount of tokens for `account`.
    /// @dev Mints a `value` amount of tokens for `account`.
    /// See {ERC20-_mint}.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to mint.
    function mintFor(address account, uint256 value) public payable virtual {
        beforeMint(_msgSender(), account, value);
        _mint(account, value);
        updateMintRegistry(account, value);
    }
}
