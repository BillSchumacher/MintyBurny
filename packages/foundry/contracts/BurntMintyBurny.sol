//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./extensions/ERC20MintRegistry.sol";
import "./extensions/ERC20BurnRegistry.sol";
import "./extensions/ERC20ProofOfBurn.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "./extensions/ERC20ProofOfBurner.sol";
import "./extensions/ERC20ProofOfMint.sol";
import "./extensions/ERC20ProofOfMinter.sol";

/// @title Example implementation contract for extensions.
/// @author BillSchumacher
contract BurntMintyBurny is
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

    function mintRatio()
        public
        view
        override(
            ERC20ProofOfBurn,
            ERC20ProofOfBurner,
            ERC20ProofOfMint,
            ERC20ProofOfMinter
        )
        returns (uint256)
    {
        return 5000;
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
