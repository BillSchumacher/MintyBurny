// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20MintRegistryUpgradeable} from
    "./ERC20Upgradeable/extensions/ERC20MintRegistryUpgradeable.sol";
import {ERC20BurnRegistryUpgradeable} from
    "./ERC20Upgradeable/extensions/ERC20BurnRegistryUpgradeable.sol";
import {ERC20AirDropMintUpgradeable} from
    "./ERC20Upgradeable/extensions/ERC20AirDropMintUpgradeable.sol";
import {ERC20AirDropTransferUpgradeable} from
    "./ERC20Upgradeable/extensions/ERC20AirDropTransferUpgradeable.sol";
import {IERC20CustomErrors} from "./ERC20/extensions/IERC20CustomErrors.sol";

/// @title A token for testing.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract BurnTokenUpgradeable is
    Initializable,
    ERC20Upgradeable,
    ERC20MintRegistryUpgradeable,
    ERC20BurnRegistryUpgradeable,
    ERC20AirDropMintUpgradeable,
    ERC20AirDropTransferUpgradeable
{
    function initialize(
        string memory name,
        string memory symbol
    ) public initializer {
        __BurnToken_init(name, symbol);
    }

    function __BurnToken_init(
        string memory name,
        string memory symbol
    ) public virtual onlyInitializing {
        __ERC20_init(name, symbol);
        __ERC20MintRegistry_init();
        __ERC20BurnRegistry_init();
        __ERC20AirDropMint_init();
        __ERC20AirDropTransfer_init();
        __BurnToken_init_unchained();
    }

    function __BurnToken_init_unchained() internal onlyInitializing {}

    /// @inheritdoc ERC20Upgradeable
    function balanceOf(address account)
        public
        view
        override(ERC20Upgradeable, ERC20BurnRegistryUpgradeable)
        returns (uint256)
    {
        return ERC20BurnRegistryUpgradeable.balanceOf(account);
    }

    /// @dev Update the mint registry.
    /// @param account (address) - the address of the account.
    /// @param value (uint256) - the amount of tokens to mint.
    function afterAirDropMint(
        address account,
        uint256 value
    ) internal override {
        updateMintRegistry(account, value);
        super.afterAirDropMint(account, value);
    }

    /// @notice Allows the token to withdraw ether.
    /// @dev Allows the token to withdraw ether.
    function withdraw() public {
        address to = msg.sender;
        uint256 value = address(this).balance;
        (bool success,) = to.call{value: value}("");
        if (!success) revert IERC20CustomErrors.ERC20TransferFailed(to, value);
    }
}
