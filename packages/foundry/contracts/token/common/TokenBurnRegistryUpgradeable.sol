// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title Burn registry supporting a ERC20 token.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract TokenBurnRegistryUpgradeable {
    mapping(address => uint256) private _burned;
    mapping(uint256 => address) private _burnAddresses;
    uint256 private _totalBurners;
    uint256 private _totalBurned;

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
        uint256 burnersLength = _totalBurners;
        if (burnersLength < amount) {
            amount = burnersLength;
        }
        address[] memory burners = new address[](amount);
        mapping(uint256 => address) storage burnAddresses = _burnAddresses;

        for (uint256 i; i < amount;) {
            burners[i] = burnAddresses[i];
            unchecked {
                ++i;
            }
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
        uint256 burnersLength = _totalBurners;
        if (burnersLength < amount) {
            amount = burnersLength;
        }
        address[] memory burners = new address[](amount);
        mapping(uint256 => address) storage burnAddresses = _burnAddresses;

        for (uint256 i; i < amount;) {
            burners[i] = burnAddresses[burnersLength - amount + i];
            unchecked {
                ++i;
            }
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
        _totalBurned += value;
        unchecked {
            _burned[account] += value;
            _burnAddresses[_totalBurners] = account;
            _totalBurners += 1;
        }
    }
}
