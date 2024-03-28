// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {MultiTokenBurnRegistryUpgradeable} from
    "./common/MultiTokenBurnRegistryUpgradeable.sol";
import {MultiTokenMintRegistryUpgradeable} from
    "./common/MultiTokenMintRegistryUpgradeable.sol";

/// @title An ERC20 token supporting an external registry.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract FreshBurnTokenUpgradeable is Initializable, ERC20Upgradeable {
    /// @custom:storage-location erc7201:MintyBurny.storage.FreshBurnToken
    struct FreshBurnTokenStorage {
        address _registry;
    }

    bytes32 private constant FreshBurnTokenStorageLocation =
        0x2ae22741ee4c6304928a7cc01a2d5b2045521c8980d4420f4889dccbaaf6bd00;

    function _getFreshBurnTokenStorage()
        private
        pure
        returns (FreshBurnTokenStorage storage $)
    {
        assembly {
            $.slot := FreshBurnTokenStorageLocation
        }
    }

    function initialize(address registry_) public virtual initializer {
        __FreshBurnToken_init(registry_);
    }

    function __FreshBurnToken_init(address registry_)
        public
        virtual
        onlyInitializing
    {
        __FreshBurnToken_init_unchained(registry_);
        __ERC20_init("Struct Fresh Burn Token", "SFBURN");
    }

    function __FreshBurnToken_init_unchained(address registry_)
        internal
        onlyInitializing
    {
        FreshBurnTokenStorage storage $ = _getFreshBurnTokenStorage();
        $._registry = registry_;
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20Upgradeable) {
        ERC20Upgradeable._update(from, to, value);
        if (to == address(0)) {
            this._updateBurnRegistry(from, value);
        }
        if (from == address(0)) {
            this._updateMintRegistry(to, value);
        }
    }

    /// @notice Mint tokens to the sender.
    /// @dev Mint tokens to the sender.
    /// @param value (uint256) - the amount of tokens to mint.
    function mint(uint256 value) public {
        _mint(msg.sender, value);
    }

    /// @notice Burn tokens from the sender.
    /// @dev Burn tokens from the sender.
    /// @param value (uint256) - the amount of tokens to burn.
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /// @dev Update the burn registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to burn.
    function _updateBurnRegistry(address account, uint256 value) external {
        FreshBurnTokenStorage storage $ = _getFreshBurnTokenStorage();

        //_burnRegistry.call(abi.encodeWithSignature("updateBurnRegistry(address,uint256)", account, value));
        MultiTokenBurnRegistryUpgradeable($._registry).updateBurnRegistry(
            account, value
        );
    }

    /// @dev Update the mint registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to mint.
    function _updateMintRegistry(address account, uint256 value) external {
        FreshBurnTokenStorage storage $ = _getFreshBurnTokenStorage();

        //_burnRegistry.call(abi.encodeWithSignature("updateMintRegistry(address,uint256)", account, value));
        MultiTokenMintRegistryUpgradeable($._registry).updateMintRegistry(
            account, value
        );
    }
}
