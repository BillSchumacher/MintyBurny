// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {TokenBurnRegistry} from "../../common/TokenBurnRegistry.sol";

/// @title A smart contract that allows burning tokens and tracking the burned tokens.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20BurnRegistry is
    ERC20,
    ERC20Burnable,
    TokenBurnRegistry
{
    uint256 private _zeroAddress;

    /// @inheritdoc ERC20
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (account == address(0)) return _zeroAddress;
        return ERC20.balanceOf(account);
    }

    /// @dev Update the burn registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function updateBurnRegistry(
        address account,
        uint256 value
    ) internal virtual override {
        _zeroAddress += value;
        super.updateBurnRegistry(account, value);
    }

    /// @notice Destroys a `value` amount of tokens from your balance.
    /// @dev Destroys a `value` amount of tokens from the caller.
    /// See {ERC20-_burn}.
    /// @param value (uint256) - the amount of tokens to burn.
    function burn(uint256 value) public virtual override {
        address sender = _msgSender();
        _burn(sender, value);
        updateBurnRegistry(sender, value);
    }

    /// @notice Destroys a `value` amount of tokens from `account`, deducting from your allowance.
    /// @dev Destroys a `value` amount of tokens from `account`, deducting from the caller's allowance.
    /// See {ERC20-_burn} and {ERC20-allowance}.
    /// @inheritdoc ERC20Burnable
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function burnFrom(address account, uint256 value) public virtual override {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
        updateBurnRegistry(account, value);
    }
}
