// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20BurnableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {TokenBurnRegistryUpgradeable} from
    "../../common/TokenBurnRegistryUpgradeable.sol";

/// @title A smart contract that allows burning tokens and tracking the burned tokens.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20BurnRegistryUpgradeable is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    TokenBurnRegistryUpgradeable
{
    /// @custom:storage-location erc7201:MintyBurny.storage.ERC20BurnRegistry
    struct ERC20BurnRegistryStorage {
        uint256 _zeroAddress;
    }

    bytes32 private constant ERC20BurnRegistryStorageLocation =
        0xf15fcfbf1c887e2d534832e4499f218738b8a22bff40e56a09c0ae588c22af00;

    function _getERC20BurnRegistryStorage()
        private
        pure
        returns (ERC20BurnRegistryStorage storage $)
    {
        assembly {
            $.slot := ERC20BurnRegistryStorageLocation
        }
    }

    function __ERC20BurnRegistry_init() public virtual onlyInitializing {
        __ERC20BurnRegistry_init_unchained();
    }

    function __ERC20BurnRegistry_init_unchained() internal onlyInitializing {
        // ERC20BurnRegistryStorage storage $ = _getERC20BurnRegistryStorage();
    }

    /// @inheritdoc ERC20Upgradeable
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        ERC20BurnRegistryStorage storage $ = _getERC20BurnRegistryStorage();
        if (account == address(0)) return $._zeroAddress;
        return ERC20Upgradeable.balanceOf(account);
    }

    /// @dev Update the burn registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function updateBurnRegistry(
        address account,
        uint256 value
    ) internal virtual override {
        ERC20BurnRegistryStorage storage $ = _getERC20BurnRegistryStorage();
        $._zeroAddress += value;
        super.updateBurnRegistry(account, value);
    }

    /// @notice Destroys a `value` amount of tokens from your balance.
    /// @dev Destroys a `value` amount of tokens from the caller.
    /// See {ERC20Upgradeable-_burn}.
    /// @param value (uint256) - the amount of tokens to burn.
    function burn(uint256 value) public virtual override {
        address sender = _msgSender();
        _burn(sender, value);
        updateBurnRegistry(sender, value);
    }

    /// @notice Destroys a `value` amount of tokens from `account`, deducting from your allowance.
    /// @dev Destroys a `value` amount of tokens from `account`, deducting from the caller's allowance.
    /// See {ERC20Upgradeable-_burn} and {ERC20Upgradeable-allowance}.
    /// @inheritdoc ERC20BurnableUpgradeable
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function burnFrom(address account, uint256 value) public virtual override {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
        updateBurnRegistry(account, value);
    }
}
