//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

/// @title A smart contract that allows minting tokens and tracking the minting.
/// @author BillSchumacher
abstract contract ERC20MintRegistry is Context, ERC20 {
    mapping(address => uint256) private _minted;
    mapping(uint256 => address) private _mintAddresses;
    uint256 private _totalMinters;
    uint256 private _totalMinted;

    /// @notice Get the address of the minter at the given index.
    /// @dev Returns the address of the minter at the given index.
    /// @param index (uint256) - the index of the minter.
    /// @return (address) - the address of the minter.
    function minter(uint256 index) public view returns (address) {
        return _mintAddresses[index];
    }

    /// @notice Get the total amount of minters.
    /// @dev Returns the total amount of minters.
    /// @return (uint256) - the total amount of minters.
    function totalMinters() public view returns (uint256) {
        return _totalMinters;
    }

    /// @notice Get the addresses of the first `amount` minters.
    /// @dev Returns the addresses of the first `amount` minters.
    /// @param amount (uint256) - the amount of minters.
    /// @return (address[] memory) - the addresses of the minters.
    function firstMinters(uint256 amount)
        public
        view
        returns (address[] memory)
    {
        address[] memory minters = new address[](amount);
        mapping(uint256 => address) storage mintAddresses = _mintAddresses;
        if (_totalMinters < amount) {
            amount = _totalMinters;
        }
        for (uint256 i = 0; i < amount; i++) {
            minters[i] = mintAddresses[i];
        }
        return minters;
    }

    /// @notice Get the addresses of the last `amount` minters.
    /// @dev Returns the addresses of the last `amount` minters.
    /// @param amount (uint256) - the amount of minters.
    /// @return (address[] memory) - the addresses of the minters.
    function lastMinters(uint256 amount)
        public
        view
        returns (address[] memory)
    {
        address[] memory minters = new address[](amount);
        mapping(uint256 => address) storage mintAddresses = _mintAddresses;
        uint256 totalMinters = _totalMinters;
        if (totalMinters < amount) {
            amount = totalMinters;
        }
        for (uint256 i = 0; i < amount; i++) {
            minters[i] = mintAddresses[totalMinters - amount + i];
        }
        return minters;
    }

    /// @notice Get the amount of tokens minted by the given address.
    /// @dev Returns the amount of tokens minted by the given address.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the amount of tokens minted.
    function mintedBy(address account) public view returns (uint256) {
        return _minted[account];
    }

    /// @notice Get the total amount of minters.
    /// @dev Returns the total amount of minters.
    /// @return (uint256) - the total amount of minters.
    function minters() public view returns (uint256) {
        return _totalMinters;
    }

    /// @notice Get the total amount of tokens minted.
    /// @dev Returns the total amount of tokens minted.
    /// @return (uint256) - the total amount of tokens minted.
    function totalMinted() public view returns (uint256) {
        return _totalMinted;
    }

    /// @dev Handle access control, accounting, and any conditions here before minting, revert if failed.
    /// @param sender (address) - the address of the sender.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to mint.
    function beforeMint(
        address sender,
        address account,
        uint256 value
    ) internal virtual {}

    /// @dev Update the mint registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to mint.
    function updateMintRegistry(
        address account,
        uint256 value
    ) internal virtual {
        _totalMinted += value;
        _minted[account] += value;
        _mintAddresses[_totalMinters] = account;
        _totalMinters += 1;
    }

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
