// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

/// @title An extension to support an external minting registry.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
abstract contract ERC20ExternalMintRegistry is Context, ERC20 {
    address internal _mintRegistry;

    constructor(address mintRegistry_) {
        _mintRegistry = mintRegistry_;
    }

    /// @notice Get the mint registry address.
    /// @dev Returns the mint registry address.
    /// @return (address) - the mint registry address.
    function mintRegistry() public view returns (address) {
        return _mintRegistry;
    }
}
