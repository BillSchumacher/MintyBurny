// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {BurnToken} from "../contracts/token/BurnToken.sol";

contract TestTokenMintRegistry is Test {
    BurnToken public burnToken;

    function setUp() public {
        burnToken = new BurnToken("MintToken", "MINTY");
    }

    function testRegistryMint() public {
        burnToken.mint(300);
        assertEq(burnToken.totalMinted(), 300);
        burnToken.burn(100);
        assertEq(burnToken.totalMinted(), 300);
    }

    function testFirstAndLastMinters() public {
        vm.startPrank(vm.addr(1));
        burnToken.mint(20000 * 10 ** burnToken.decimals());
        burnToken.burn(10000 * 10 ** burnToken.decimals());
        assertTrue(
            burnToken.mintedBy(vm.addr(1)) == 20000 * 10 ** burnToken.decimals()
        );
        assertTrue(burnToken.mintedBy(address(0)) == 0);
        vm.stopPrank();
        vm.startPrank(vm.addr(2));
        burnToken.mint(30000 * 10 ** burnToken.decimals());
        burnToken.burn(20000 * 10 ** burnToken.decimals());
        assertTrue(
            burnToken.mintedBy(vm.addr(2)) == 30000 * 10 ** burnToken.decimals()
        );
        assertTrue(
            burnToken.mintedBy(vm.addr(1)) == 20000 * 10 ** burnToken.decimals()
        );
        assertTrue(burnToken.mintedBy(address(0)) == 0);
        vm.stopPrank();
        vm.startPrank(vm.addr(3));
        burnToken.mint(40000 * 10 ** burnToken.decimals());
        burnToken.burn(30000 * 10 ** burnToken.decimals());
        assertTrue(
            burnToken.mintedBy(vm.addr(3)) == 40000 * 10 ** burnToken.decimals()
        );
        assertTrue(
            burnToken.mintedBy(vm.addr(2)) == 30000 * 10 ** burnToken.decimals()
        );
        assertTrue(
            burnToken.mintedBy(vm.addr(1)) == 20000 * 10 ** burnToken.decimals()
        );
        assertTrue(burnToken.mintedBy(address(0)) == 0);
        vm.stopPrank();

        address[] memory minters = burnToken.firstMinters(3);
        assertTrue(minters.length == 3);
        assertTrue(minters[0] == vm.addr(1));
        assertTrue(minters[1] == vm.addr(2));
        assertTrue(minters[2] == vm.addr(3));
        assertTrue(burnToken.minter(1) == vm.addr(2));

        minters = burnToken.firstMinters(4);
        assertTrue(minters.length == 3);
        assertTrue(minters[0] == vm.addr(1));
        assertTrue(minters[1] == vm.addr(2));
        assertTrue(minters[2] == vm.addr(3));

        minters = burnToken.lastMinters(2);
        assertTrue(minters.length == 2);
        assertTrue(minters[0] == vm.addr(2));
        assertTrue(minters[1] == vm.addr(3));

        minters = burnToken.lastMinters(4);
        assertTrue(minters.length == 3);
        assertTrue(minters[0] == vm.addr(1));
        assertTrue(minters[1] == vm.addr(2));
        assertTrue(minters[2] == vm.addr(3));
    }

    function testMintedByIncreases() public {
        uint256 mintedBy = burnToken.mintedBy(vm.addr(1));
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        burnToken.mint(20000 * 10 ** 18);
        burnToken.burn(10000 * 10 ** 18);
        assertTrue(
            burnToken.mintedBy(vm.addr(1)) - mintedBy
                == 20000 * 10 ** burnToken.decimals()
        );
        assertTrue(burnToken.mintedBy(address(0)) == 0);
        vm.stopPrank();
    }

    function testTotalMintersIncreases() public {
        uint256 totalMinters = burnToken.totalMinters();
        assertTrue(totalMinters == 0);
        burnToken.mint(10000 * 10 ** burnToken.decimals());
        assertTrue(burnToken.totalMinters() == 1);
        burnToken.burn(5000 * 10 ** burnToken.decimals());
        assertTrue(burnToken.totalMinters() == 1);
    }

    function testTotalMintedIncreases() public {
        uint256 totalMinted = burnToken.totalMinted();
        burnToken.mint(10000 * 10 ** burnToken.decimals());
        assertTrue(
            burnToken.totalMinted() - 10000 * 10 ** burnToken.decimals()
                == totalMinted
        );
        burnToken.burn(5000 * 10 ** burnToken.decimals());
        assertTrue(
            burnToken.totalMinted() - totalMinted
                == 10000 * 10 ** burnToken.decimals()
        );
    }
}
