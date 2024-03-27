// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {MultiTokenMintRegistry} from "./common/MultiTokenMintRegistry.sol";
import {MultiTokenBurnRegistry} from "./common/MultiTokenBurnRegistry.sol";
import {IERC20CustomErrors} from "./ERC20/extensions/IERC20CustomErrors.sol";

/// @title Test registries.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract FreshBurnTokens is MultiTokenBurnRegistry, MultiTokenMintRegistry {
    /// @notice Allows the token to withdraw ether.
    /// @dev Allows the token to withdraw ether.
    function withdraw() public {
        address to = msg.sender;
        uint256 value = address(this).balance;
        (bool success,) = to.call{value: value}("");
        if (!success) revert IERC20CustomErrors.ERC20TransferFailed(to, value);
    }
}
