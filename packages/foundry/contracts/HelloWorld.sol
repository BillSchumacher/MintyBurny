// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";


abstract contract MyERC20 is ERC20Capped {
    function _update(address from, address to, uint256 value) internal virtual override {
        if (from == address(0)) {
            uint256 maxSupply = cap();
            uint256 supply = totalSupply();
            if (supply + value > maxSupply) {
                revert ERC20ExceededCap(supply, maxSupply);
            }
        }
        ERC20._update(from, to, value);
    }
}

abstract contract MyERC20After is ERC20Capped {
    function _update(address from, address to, uint256 value) internal virtual override {
        ERC20._update(from, to, value);
        if (from == address(0)) {
            uint256 maxSupply = cap();
            uint256 supply = totalSupply();
            if (supply > maxSupply) {
                revert ERC20ExceededCap(supply, maxSupply);
            }
        }
    }
}

contract HelloWorld is MyERC20 {
    constructor() payable MyERC20() ERC20("hello", "wrld") ERC20Capped(42)  {
    }

    function mint(uint256 value) public {
        _mint(msg.sender, value);
    }
}

contract WorldHello is MyERC20After {
    constructor() payable MyERC20After() ERC20("wrld", "hello") ERC20Capped(42)  {
    }

    function mint(uint256 value) public {
        _mint(msg.sender, value);
    }
}