// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20MintRegistryUpgradeable} from
    "../extensions/ERC20MintRegistryUpgradeable.sol";
import {ERC20BurnRegistryUpgradeable} from
    "../extensions/ERC20BurnRegistryUpgradeable.sol";
import {ERC20CappedUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol";
import {IERC20CustomErrorsUpgradeable} from
    "../extensions/IERC20CustomErrorsUpgradeable.sol";

/// @title Example implementation contract for extensions.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract ERC20MintyBurnyUpgradeable is
    Initializable,
    ERC20MintRegistryUpgradeable,
    ERC20BurnRegistryUpgradeable,
    ERC20CappedUpgradeable
{
    function initialize() public initializer {
        __ERC20MintyBurny_init();
        mint(1000000 * 10 ** decimals());
        burn(500000 * 10 ** decimals());
    }

    function __ERC20MintyBurny_init() public virtual onlyInitializing {
        __ERC20MintyBurny_init_unchained();
        __ERC20_init("MintyBurny", "MB");
        __ERC20Capped_init(2 ** 254);
    }

    function __ERC20MintyBurny_init_unchained() internal onlyInitializing {
        // ERC20MintRegistryStorage storage $ = _getERC20MintRegistryStorage();
        // ERC20BurnRegistryStorage storage _ = _getERC20BurnRegistryStorage();
    }

    /// @inheritdoc ERC20Upgradeable
    function balanceOf(address account)
        public
        view
        virtual
        override(ERC20Upgradeable, ERC20BurnRegistryUpgradeable)
        returns (uint256)
    {
        return ERC20BurnRegistryUpgradeable.balanceOf(account);
    }

    /// @inheritdoc ERC20Upgradeable
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20Upgradeable, ERC20CappedUpgradeable) {
        if (from == address(0)) {
            uint256 maxSupply = cap();
            uint256 supply = totalSupply();
            if (supply + value > maxSupply) {
                revert ERC20CappedUpgradeable.ERC20ExceededCap(
                    supply, maxSupply
                );
            }
        }
        ERC20Upgradeable._update(from, to, value);
    }

    /// @notice Allows the token to receive ether.
    receive() external payable {}

    /// @notice Allows the token to withdraw ether.
    /// @dev Allows the token to withdraw ether.
    function withdraw() public virtual {
        address to = msg.sender;
        uint256 value = address(this).balance;
        (bool success,) = to.call{value: value}("");
        if (!success) {
            revert IERC20CustomErrorsUpgradeable.ERC20TransferFailed(to, value);
        }
    }
}
