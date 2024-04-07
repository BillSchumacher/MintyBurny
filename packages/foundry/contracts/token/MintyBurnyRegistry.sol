// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {MultiTokenMintRegistry} from "./common/MultiTokenMintRegistry.sol";
import {MultiTokenBurnRegistry} from "./common/MultiTokenBurnRegistry.sol";
import {IERC20CustomErrors} from "./ERC20/extensions/IERC20CustomErrors.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

/// @title Mint and burn registry.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract MintyBurnyRegistry is
    Context,
    Ownable,
    MultiTokenBurnRegistry,
    MultiTokenMintRegistry
{
    constructor() Ownable(msg.sender) {}

    /// @notice Allows the token to withdraw ether.
    /// @dev Allows the token to withdraw ether.
    function withdraw() public onlyOwner {
        uint256 value = address(this).balance;
        address to = owner();
        (bool success,) = to.call{value: value}("");
        if (!success) revert IERC20CustomErrors.ERC20TransferFailed(to, value);
    }
}
