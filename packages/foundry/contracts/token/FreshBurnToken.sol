// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MultiTokenBurnRegistry} from "./common/MultiTokenBurnRegistry.sol";
import {MultiTokenMintRegistry} from "./common/MultiTokenMintRegistry.sol";

/// @title An ERC20 token supporting an external registry.
/// @author BillSchumacher
/// @custom:security-contact 34168009+BillSchumacher@users.noreply.github.com
contract FreshBurnToken is ERC20 {
    address private immutable _registry;

    constructor(address registry_) ERC20("Struct Fresh Burn Token", "SFBURN") {
        _registry = registry_;
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20) {
        ERC20._update(from, to, value);
        if (to == address(0)) {
            this._updateBurnRegistry(from, value);
        }
        if (from == address(0)) {
            this._updateMintRegistry(to, value);
        }
    }

    function mint(uint256 value) public {
        _mint(msg.sender, value);
    }

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function _updateBurnRegistry(address account, uint256 value) external {
        //_burnRegistry.call(abi.encodeWithSignature("updateBurnRegistry(address,uint256)", account, value));
        MultiTokenBurnRegistry(_registry).updateBurnRegistry(account, value);
    }

    function _updateMintRegistry(address account, uint256 value) external {
        //_burnRegistry.call(abi.encodeWithSignature("updateMintRegistry(address,uint256)", account, value));
        MultiTokenMintRegistry(_registry).updateMintRegistry(account, value);
    }
}
