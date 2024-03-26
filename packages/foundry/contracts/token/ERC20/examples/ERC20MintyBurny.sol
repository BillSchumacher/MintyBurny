// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "../extensions/ERC20MintRegistry.sol";
import "../extensions/ERC20BurnRegistry.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

/// @title Example implementation contract for extensions.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract ERC20MintyBurny is
    ERC20MintRegistry,
    ERC20BurnRegistry,
    ERC20Capped
{
    constructor() ERC20("MintyBurny", "MB") ERC20Capped(2 ** 254) {
        mint(1000000 * 10 ** decimals());
        burn(500000 * 10 ** decimals());
    }

    function balanceOf(address account)
        public
        view
        virtual
        override(ERC20, ERC20BurnRegistry)
        returns (uint256)
    {
        return ERC20BurnRegistry.balanceOf(account);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Capped) {
        if (from == address(0)) {
            uint256 maxSupply = cap();
            uint256 supply = totalSupply();
            if (supply + value > maxSupply) {
                revert ERC20Capped.ERC20ExceededCap(supply, maxSupply);
            }
        }
        ERC20._update(from, to, value);
    }

    /// @notice Allows the token to receive ether.
    receive() external payable {}
}
