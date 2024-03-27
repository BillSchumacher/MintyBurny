// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {ERC20MintyBurny} from
    "../contracts/token/ERC20/examples/ERC20MintyBurny.sol";
import {ERC20Capped} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract MintyBurnyTest is Test {
    ERC20MintyBurny public mintyBurny;

    function setUp() public {
        mintyBurny = new ERC20MintyBurny();
    }

    function testZeroAddressHasBalance() public {
        mintyBurny.burn(10000 * 10 ** mintyBurny.decimals());
        uint256 zeroBalance = mintyBurny.balanceOf(address(0));
        assertTrue(zeroBalance > 0);
    }

    function testBurnedFromIncreases() public {
        uint256 burnedFrom = mintyBurny.burnedFrom(vm.addr(1));
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.prank(vm.addr(1));
        mintyBurny.mint(20000 * 10 ** 18);
        vm.prank(vm.addr(1));
        mintyBurny.burn(10000 * 10 ** 18);
        assertTrue(
            mintyBurny.burnedFrom(vm.addr(1)) - burnedFrom
                == 10000 * 10 ** mintyBurny.decimals()
        );
        assertTrue(mintyBurny.burnedFrom(address(0)) == 0);
        vm.prank(vm.addr(1));
        mintyBurny.approve(vm.addr(2), 10000 * 10 ** 18);
        vm.deal(vm.addr(2), 10000 * 10 ** 18);
        vm.prank(vm.addr(2));
        mintyBurny.burnFrom(vm.addr(1), 10000 * 10 ** 18);
        assertTrue(
            mintyBurny.burnedFrom(vm.addr(1)) - burnedFrom
                == 20000 * 10 ** mintyBurny.decimals()
        );
        assertTrue(mintyBurny.balanceOf(vm.addr(1)) == 0);
    }

    function testMintForIncreases() public {
        uint256 minted = mintyBurny.mintedBy(vm.addr(2));
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.prank(vm.addr(1));
        mintyBurny.mintFor(vm.addr(2), 20000 * 10 ** 18);
        assertTrue(
            mintyBurny.mintedBy(vm.addr(2)) - minted
                == 20000 * 10 ** mintyBurny.decimals()
        );
    }

    function testTotalMintedIncreases() public {
        uint256 totalMinted = mintyBurny.totalMinted();
        mintyBurny.burn(10000 * 10 ** mintyBurny.decimals());
        assertTrue(mintyBurny.totalMinted() == totalMinted);
        mintyBurny.mint(10000 * 10 ** mintyBurny.decimals());
        assertTrue(
            mintyBurny.totalMinted() - totalMinted
                == 10000 * 10 ** mintyBurny.decimals()
        );
    }

    function testTotalBurnedIncreases() public {
        uint256 totalBurned = mintyBurny.totalBurned();
        mintyBurny.mint(10000 * 10 ** mintyBurny.decimals());
        assertTrue(mintyBurny.totalBurned() == totalBurned);
        mintyBurny.burn(10000 * 10 ** mintyBurny.decimals());
        assertTrue(
            mintyBurny.totalBurned() - totalBurned
                == 10000 * 10 ** mintyBurny.decimals()
        );
    }

    function testZeroAddressIncrementsByBurn() public {
        uint256 zeroBalance = mintyBurny.balanceOf(address(0));
        mintyBurny.burn(10000 * 10 ** mintyBurny.decimals());
        uint256 newZeroBalance = mintyBurny.balanceOf(address(0));
        assertTrue(
            newZeroBalance - zeroBalance == 10000 * 10 ** mintyBurny.decimals()
        );
    }

    function testBurnersIncrements() public {
        mintyBurny.burn(10000 * 10 ** mintyBurny.decimals());
        require(mintyBurny.burns() == 2);
    }

    function testMintersIncrements() public {
        mintyBurny.mint(10000 * 10 ** mintyBurny.decimals());
        require(mintyBurny.minters() == 2);
    }

    function testMintingCapped() public {
        try mintyBurny.mint(2 ** 255) {
            assertTrue(
                false, "mint(..) should revert when value + supply > maxSupply."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = ERC20Capped.ERC20ExceededCap.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }
}
