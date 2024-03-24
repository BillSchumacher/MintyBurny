//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/// @title A smart contract that allows burning tokens and tracking the burned tokens.
/// @author BillSchumacher
abstract contract ERC20BurnRegistry is ERC20, ERC20Burnable {
    mapping(address => uint256) private _burned;
    mapping(uint256 => address) private _burnAddresses;
    uint256 private _totalBurners;
    uint256 private _totalBurned;
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

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @return (uint256) - the total amount of burners.
    function totalBurners() public view returns (uint256) {
        return _totalBurners;
    }

    /// @notice Get the address of the burner at the given index.
    /// @dev Returns the address of the burner at the given index.
    /// @param index (uint256) - the index of the burner.
    /// @return (address) - the address of the burner.
    function burner(uint256 index) public view returns (address) {
        return _burnAddresses[index];
    }

    /// @notice Get the addresses of the first `amount` burners.
    /// @dev Returns the addresses of the first `amount` burners.
    /// @param amount (uint256) - the amount of burners.
    /// @return (address[] memory) - the addresses of the burners.
    function firstBurners(uint256 amount)
        public
        view
        returns (address[] memory)
    {
        address[] memory burners = new address[](amount);
        mapping(uint256 => address) storage burnAddresses = _burnAddresses;
        uint256 burnersLength = _totalBurners;
        if (burnersLength < amount) {
            amount = burnersLength;
        }
        for (uint256 i = 0; i < amount; i++) {
            burners[i] = burnAddresses[i];
        }
        return burners;
    }

    /// @notice Get the addresses of the last `amount` burners.
    /// @dev Returns the addresses of the last `amount` burners.
    /// @param amount (uint256) - the amount of burners.
    /// @return (address[] memory) - the addresses of the burners.
    function lastBurners(uint256 amount)
        public
        view
        returns (address[] memory)
    {
        address[] memory burners = new address[](amount);
        mapping(uint256 => address) storage burnAddresses = _burnAddresses;
        uint256 burnersLength = _totalBurners;
        if (burnersLength < amount) {
            amount = burnersLength;
        }
        for (uint256 i = 0; i < amount; i++) {
            burners[i] = burnAddresses[burnersLength - amount + i];
        }
        return burners;
    }

    /// @notice Get the amount of tokens burned by the given address.
    /// @dev Returns the amount of tokens burned by the given address.
    /// @param account (address) - the address of the account.
    /// @return (uint256) - the total amount of tokens burned.
    function burnedFrom(address account) public view returns (uint256) {
        return _burned[account];
    }

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @return (uint256) - the total amount of burners.
    function burns() public view returns (uint256) {
        return _totalBurners;
    }

    /// @notice Get the total amount of tokens burned.
    /// @dev Returns the total amount of tokens burned.
    /// @return (uint256) - the total amount of tokens burned.
    function totalBurned() public view returns (uint256) {
        return _totalBurned;
    }

    /// @dev Update the burn registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function updateBurnRegistry(
        address account,
        uint256 value
    ) internal virtual {
        _zeroAddress += value;
        _totalBurned += value;
        _burned[account] += value;
        _burnAddresses[_totalBurners] = account;
        _totalBurners += 1;
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
