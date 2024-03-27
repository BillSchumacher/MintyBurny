// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20MintRegistry} from "../extensions/ERC20MintRegistry.sol";
import {ERC20BurnRegistry} from "../extensions/ERC20BurnRegistry.sol";
import {ERC20ProofOfBurn} from "../extensions/ERC20ProofOfBurn.sol";
import {ERC20Capped} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {ERC20ProofOfBurner} from "../extensions/ERC20ProofOfBurner.sol";
import {ERC20ProofOfMint} from "../extensions/ERC20ProofOfMint.sol";
import {ERC20ProofOfMinter} from "../extensions/ERC20ProofOfMinter.sol";
import {IERC20CustomErrors} from "../extensions/IERC20CustomErrors.sol";

/// @title Example implementation contract for extensions.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract ERC20BurntMintyBurny is
    ERC20ProofOfBurn,
    ERC20ProofOfBurner,
    ERC20ProofOfMint,
    ERC20ProofOfMinter,
    ERC20MintRegistry,
    ERC20BurnRegistry,
    ERC20Capped
{
    constructor(
        address[] memory burnAddresses,
        address[] memory contractAddresses
    )
        ERC20("MintyBurny", "MB")
        ERC20ProofOfBurn(burnAddresses, contractAddresses)
        ERC20ProofOfBurner(contractAddresses)
        ERC20ProofOfMint(contractAddresses)
        ERC20ProofOfMinter(contractAddresses)
        ERC20Capped(2 ** 254)
    {
        mint(1000000 * 10 ** decimals());
        burn(500000 * 10 ** decimals());
    }

    /// @inheritdoc ERC20ProofOfBurn
    function mintRatio()
        public
        pure
        override(
            ERC20ProofOfBurn,
            ERC20ProofOfBurner,
            ERC20ProofOfMint,
            ERC20ProofOfMinter
        )
        returns (uint256)
    {
        // Just for coverage...
        ERC20ProofOfBurn.mintRatio();
        ERC20ProofOfBurner.mintRatio();
        ERC20ProofOfMint.mintRatio();
        ERC20ProofOfMinter.mintRatio();
        return 5000;
    }

    /// @inheritdoc ERC20
    function balanceOf(address account)
        public
        view
        virtual
        override(ERC20, ERC20BurnRegistry)
        returns (uint256)
    {
        return ERC20BurnRegistry.balanceOf(account);
    }

    /// @inheritdoc ERC20
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

    /// @notice Allows the token to withdraw ether.
    /// @dev Allows the token to withdraw ether.
    function withdraw() public virtual {
        address to = msg.sender;
        uint256 value = address(this).balance;
        (bool success,) = to.call{value: value}("");
        if (!success) revert IERC20CustomErrors.ERC20TransferFailed(to, value);
    }
}
