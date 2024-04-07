// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "./ITokenBurnRegistryStats.sol";

/// @title Burn registry supporting a ERC20 token.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract TokenBurnRegistry is ITokenBurnRegistryStats {
    TokenBurnStats private _burnStats;

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @return (uint256) - the total amount of burners.
    function totalBurners() public view returns (uint256) {
        return _burnStats.totalBurners;
    }

    /// @notice Get the address of the burner at the given index.
    /// @dev Returns the address of the burner at the given index.
    /// @param index (uint256) - the index of the burner.
    /// @return (address) - the address of the burner.
    function burner(uint256 index) public view returns (address) {
        return _burnStats.burnAddresses[index];
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
        TokenBurnStats storage stats = _burnStats;
        uint256 burnersLength = stats.totalBurners;
        if (burnersLength < amount) {
            amount = burnersLength;
        }
        address[] memory burners = new address[](amount);
        mapping(uint256 => address) storage burnAddresses = stats.burnAddresses;

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
        TokenBurnStats storage stats = _burnStats;
        uint256 burnersLength = stats.totalBurners;
        if (burnersLength < amount) {
            amount = burnersLength;
        }
        address[] memory burners = new address[](amount);
        mapping(uint256 => address) storage burnAddresses = stats.burnAddresses;

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
        return _burnStats.burned[account];
    }

    /// @notice Get the total amount of burners.
    /// @dev Returns the total amount of burners.
    /// @return (uint256) - the total amount of burners.
    function burns() public view returns (uint256) {
        return _burnStats.totalBurners;
    }

    /// @notice Get the total amount of tokens burned.
    /// @dev Returns the total amount of tokens burned.
    /// @return (uint256) - the total amount of tokens burned.
    function totalBurned() public view returns (uint256) {
        return _burnStats.totalBurned;
    }

    /// @dev Update the burn registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function updateBurnRegistry(
        address account,
        uint256 value
    ) internal virtual {
        TokenBurnStats storage stats = _burnStats;
        stats.totalBurned += value;
        unchecked {
            stats.burned[account] += value;
            stats.burnAddresses[stats.totalBurners] = account;
            stats.totalBurners += 1;
        }
        emit Burned(account, value, stats.totalBurned, stats.totalBurners);
    }
}
