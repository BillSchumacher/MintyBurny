// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/HelloWorld.sol";

contract OverCapAfterTest is Test {
    WorldHello public worldHello;

    function setUp() public {
        worldHello = new WorldHello();
    }

    function testWorldOverCap() public {
        try worldHello.mint(1000000 * 10 ** worldHello.decimals())  {
            assertTrue(false, "mint(..) should revert when value + supply > maxSupply.");
        } catch (bytes memory reason) {
            bytes4 expectedSelector = ERC20Capped.ERC20ExceededCap.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }

    function testWorldUnderCap() public {
        worldHello.mint(10);
        assertTrue(
            worldHello.totalSupply() == 10
        );
    }
}