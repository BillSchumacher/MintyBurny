// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/HelloWorld.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract OverCapTest is Test {
    HelloWorld public helloWorld;

    function setUp() public {
        helloWorld = new HelloWorld();
    }

    function testHelloOverCap() public {
        try helloWorld.mint(1000000 * 10 ** helloWorld.decimals()) {
            assertTrue(
                false, "mint(..) should revert when value + supply > maxSupply."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = ERC20Capped.ERC20ExceededCap.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }

    function testHelloUnderCap() public {
        helloWorld.mint(10);
        assertTrue(helloWorld.totalSupply() == 10);
    }
}
