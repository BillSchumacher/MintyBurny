// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {MultiTokenMintRegistryUpgradeable} from
    "./common/MultiTokenMintRegistryUpgradeable.sol";
import {MultiTokenBurnRegistryUpgradeable} from
    "./common/MultiTokenBurnRegistryUpgradeable.sol";
import {IERC20CustomErrors} from "./ERC20/extensions/IERC20CustomErrors.sol";

/// @title Test registries.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract FreshBurnTokensUpgradeable is
    Initializable,
    MultiTokenBurnRegistryUpgradeable,
    MultiTokenMintRegistryUpgradeable
{
    /// @notice Allows the token to withdraw ether.
    /// @dev Allows the token to withdraw ether.
    function withdraw() public {
        address to = msg.sender;
        uint256 value = address(this).balance;
        (bool success,) = to.call{value: value}("");
        if (!success) revert IERC20CustomErrors.ERC20TransferFailed(to, value);
    }
}
