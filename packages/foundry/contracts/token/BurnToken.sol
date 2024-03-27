// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20MintRegistry} from "./ERC20/extensions/ERC20MintRegistry.sol";
import {ERC20BurnRegistry} from "./ERC20/extensions/ERC20BurnRegistry.sol";
import {ERC20AirDropMint} from "./ERC20/extensions/ERC20AirDropMint.sol";
import {ERC20AirDropTransfer} from "./ERC20/extensions/ERC20AirDropTransfer.sol";
import {IERC20CustomErrors} from "./ERC20/extensions/IERC20CustomErrors.sol";

/// @title A token for testing.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract BurnToken is
    ERC20,
    ERC20MintRegistry,
    ERC20BurnRegistry,
    ERC20AirDropMint,
    ERC20AirDropTransfer
{
    constructor(
        string memory name,
        string memory symbol
    ) payable ERC20(name, symbol) {}

    /// @inheritdoc ERC20
    function balanceOf(address account)
        public
        view
        override(ERC20, ERC20BurnRegistry)
        returns (uint256)
    {
        return ERC20BurnRegistry.balanceOf(account);
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
