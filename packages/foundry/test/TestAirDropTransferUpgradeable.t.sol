// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {BurnTokenUpgradeable} from "../contracts/token/BurnTokenUpgradeable.sol";
import {ERC20AirDropMismatch} from
    "../contracts/token/ERC20/extensions/ERC20AirDropErrors.sol";

contract TestTokenAirDropTransfer is Test {
    BurnTokenUpgradeable public burnToken;

    function setUp() public {
        burnToken = new BurnTokenUpgradeable();
        burnToken.initialize("BurnToken", "BURN");
    }

    function testAirDropTransfer() public {
        burnToken.mint(300);
        address[] memory addresses = new address[](3);
        addresses[0] = vm.addr(1);
        addresses[1] = vm.addr(2);
        addresses[2] = vm.addr(3);
        burnToken.airDropTransfer(addresses, 100);
        assertEq(burnToken.balanceOf(vm.addr(1)), 100);
        assertEq(burnToken.balanceOf(vm.addr(2)), 100);
        assertEq(burnToken.balanceOf(vm.addr(3)), 100);
        assertEq(burnToken.totalMinted(), 300);
    }

    function testAirDropTransferSplit() public {
        burnToken.mint(300);
        address[] memory addresses = new address[](3);
        addresses[0] = vm.addr(1);
        addresses[1] = vm.addr(2);
        addresses[2] = vm.addr(3);
        burnToken.airDropTransferSplit(addresses, 300);
        assertEq(burnToken.balanceOf(vm.addr(1)), 100);
        assertEq(burnToken.balanceOf(vm.addr(2)), 100);
        assertEq(burnToken.balanceOf(vm.addr(3)), 100);
        assertEq(burnToken.totalMinted(), 300);
    }

    function testAirDropMintValues() public {
        burnToken.mint(300);
        address[] memory addresses = new address[](3);
        addresses[0] = vm.addr(1);
        addresses[1] = vm.addr(2);
        addresses[2] = vm.addr(3);
        uint256[] memory values = new uint256[](3);
        values[0] = 100;
        values[1] = 100;
        values[2] = 100;
        burnToken.airDropTransferValues(addresses, values);
        assertEq(burnToken.balanceOf(vm.addr(1)), 100);
        assertEq(burnToken.balanceOf(vm.addr(2)), 100);
        assertEq(burnToken.balanceOf(vm.addr(3)), 100);
        assertEq(burnToken.totalMinted(), 300);

        values = new uint256[](4);
        values[0] = 100;
        values[1] = 100;
        values[2] = 100;
        values[3] = 100;
        try burnToken.airDropTransferValues(addresses, values) {
            assertTrue(
                false,
                "airDropTransferValues(..) should revert when values length > addresses."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = ERC20AirDropMismatch.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }
}
