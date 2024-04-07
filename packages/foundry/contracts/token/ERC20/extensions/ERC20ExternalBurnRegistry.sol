// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

/// @title An extension to support an external burning registry.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20ExternalBurnRegistry is Context, ERC20 {
    address internal _burnRegistry;

    constructor(address memory burnRegistry_) {
        _burnRegistry = burnRegistry_;
    }

    /// @notice Get the burn registry address.
    /// @dev Returns the burn registry address.
    /// @return (address) - the burn registry address.
    function burnRegistry() public view returns (address) {
        return _burnRegistry;
    }
}
