// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {MultiTokenMintRegistryUpgradeable} from
    "./common/MultiTokenMintRegistryUpgradeable.sol";
import {MultiTokenBurnRegistryUpgradeable} from
    "./common/MultiTokenBurnRegistryUpgradeable.sol";
import {IERC20CustomErrors} from "./ERC20/extensions/IERC20CustomErrors.sol";
import {OwnableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ContextUpgradeable} from
    "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {UUPSUpgradeable} from
    "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title Test registries.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract FreshBurnTokensUpgradeable is
    Initializable,
    UUPSUpgradeable,
    ContextUpgradeable,
    OwnableUpgradeable,
    MultiTokenBurnRegistryUpgradeable,
    MultiTokenMintRegistryUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    /*
    constructor() {
        _disableInitializers();
    }
    */

    function initialize(address owner) public initializer {
        __Ownable_init(owner);
        __Context_init();
        __MultiTokenBurnRegistry_init();
        __MultiTokenMintRegistry_init();
        _transferOwnership(owner);
    }

    /// @notice Allows the token to withdraw ether.
    /// @dev Allows the token to withdraw ether.
    function withdraw() public {
        address to = _msgSender();
        uint256 value = address(this).balance;
        (bool success,) = to.call{value: value}("");
        if (!success) revert IERC20CustomErrors.ERC20TransferFailed(to, value);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
