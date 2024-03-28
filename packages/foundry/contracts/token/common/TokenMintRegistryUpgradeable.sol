// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title Mint registry supporting a ERC20 token.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract TokenMintRegistryUpgradeable {
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
        uint256 allMinters = _totalMinters;
        if (allMinters < amount) {
            amount = allMinters;
        }
        address[] memory result = new address[](amount);
        mapping(uint256 => address) storage mintAddresses = _mintAddresses;

        for (uint256 i = 0; i < amount; ++i) {
            result[i] = mintAddresses[i];
        }
        return result;
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
        uint256 allMinters = _totalMinters;
        if (allMinters < amount) {
            amount = allMinters;
        }
        address[] memory results = new address[](amount);
        mapping(uint256 => address) storage mintAddresses = _mintAddresses;

        for (uint256 i = 0; i < amount; ++i) {
            results[i] = mintAddresses[allMinters - amount + i];
        }
        return results;
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
        unchecked {
            _minted[account] += value;
            _mintAddresses[_totalMinters] = account;
            _totalMinters += 1;
        }
    }
}
