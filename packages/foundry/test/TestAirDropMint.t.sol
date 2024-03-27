// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {BurnToken} from "../contracts/token/BurnToken.sol";
import {ERC20AirDropMismatch} from
    "../contracts/token/ERC20/extensions/ERC20AirDropErrors.sol";
import {IERC20CustomErrors} from
    "../contracts/token/ERC20/extensions/IERC20CustomErrors.sol";

contract TestTokenAirDropMint is Test {
    BurnToken public burnToken;

    function setUp() public {
        burnToken = new BurnToken("BurnToken", "BURN");
    }

    function testWithdraw() public {
        vm.deal(address(vm.addr(1)), 100000 * 10 ** 18);
        vm.deal(address(burnToken), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        burnToken.withdraw();
        assertTrue(address(burnToken).balance == 0);
        vm.stopPrank();
        vm.deal(address(burnToken), 100000 * 10 ** 18);
        try burnToken.withdraw() {
            assertTrue(false, "withdraw() should revert when invalid.");
        } catch (bytes memory reason) {
            bytes4 expectedSelector =
                IERC20CustomErrors.ERC20TransferFailed.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }

    function testAirDropMint() public {
        address[] memory addresses = new address[](3);
        addresses[0] = vm.addr(1);
        addresses[1] = vm.addr(2);
        addresses[2] = vm.addr(3);
        burnToken.airDropMint(addresses, 100);
        assertEq(burnToken.totalMinted(), 300);
    }

    function testAirDropMintSplit() public {
        address[] memory addresses = new address[](3);
        addresses[0] = vm.addr(1);
        addresses[1] = vm.addr(2);
        addresses[2] = vm.addr(3);
        burnToken.airDropMintSplit(addresses, 300);
        assertEq(burnToken.totalMinted(), 300);
    }

    function testAirDropMintValues() public {
        address[] memory addresses = new address[](3);
        addresses[0] = vm.addr(1);
        addresses[1] = vm.addr(2);
        addresses[2] = vm.addr(3);
        uint256[] memory values = new uint256[](3);
        values[0] = 100;
        values[1] = 100;
        values[2] = 100;
        burnToken.airDropMintValues(addresses, values);
        assertEq(burnToken.totalMinted(), 300);

        values = new uint256[](4);
        values[0] = 100;
        values[1] = 100;
        values[2] = 100;
        values[3] = 100;
        try burnToken.airDropMintValues(addresses, values) {
            assertTrue(
                false,
                "airDropMintValues(..) should revert when values length > addresses."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = ERC20AirDropMismatch.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }
}
