// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {BurnTokenUpgradeable} from "../contracts/token/BurnTokenUpgradeable.sol";

contract TestTokenBurnRegistry is Test {
    BurnTokenUpgradeable public burnToken;

    function setUp() public {
        burnToken = new BurnTokenUpgradeable();
        burnToken.initialize("BurnToken", "BURN");
    }

    function testRegistryBurn() public {
        burnToken.mint(300);
        burnToken.burn(100);
        assertEq(burnToken.totalBurned(), 100);
        burnToken.burn(100);
        assertEq(burnToken.totalBurned(), 200);
        burnToken.burn(100);
        assertEq(burnToken.totalBurned(), 300);
    }

    function testFirstAndLastBurners() public {
        vm.startPrank(vm.addr(1));
        burnToken.mint(20000 * 10 ** burnToken.decimals());
        burnToken.burn(10000 * 10 ** burnToken.decimals());
        assertTrue(
            burnToken.burnedFrom(vm.addr(1))
                == 10000 * 10 ** burnToken.decimals()
        );
        assertTrue(burnToken.burnedFrom(address(0)) == 0);
        vm.stopPrank();
        vm.startPrank(vm.addr(2));
        burnToken.mint(30000 * 10 ** burnToken.decimals());
        burnToken.burn(20000 * 10 ** burnToken.decimals());
        assertTrue(
            burnToken.burnedFrom(vm.addr(2))
                == 20000 * 10 ** burnToken.decimals()
        );
        assertTrue(
            burnToken.burnedFrom(vm.addr(1))
                == 10000 * 10 ** burnToken.decimals()
        );
        assertTrue(burnToken.burnedFrom(address(0)) == 0);
        vm.stopPrank();
        vm.startPrank(vm.addr(3));
        burnToken.mint(40000 * 10 ** burnToken.decimals());
        burnToken.burn(30000 * 10 ** burnToken.decimals());
        assertTrue(
            burnToken.burnedFrom(vm.addr(3))
                == 30000 * 10 ** burnToken.decimals()
        );
        assertTrue(
            burnToken.burnedFrom(vm.addr(2))
                == 20000 * 10 ** burnToken.decimals()
        );
        assertTrue(
            burnToken.burnedFrom(vm.addr(1))
                == 10000 * 10 ** burnToken.decimals()
        );
        assertTrue(burnToken.burnedFrom(address(0)) == 0);
        vm.stopPrank();

        address[] memory burners = burnToken.firstBurners(3);
        assertTrue(burners.length == 3);
        assertTrue(burners[0] == vm.addr(1));
        assertTrue(burners[1] == vm.addr(2));
        assertTrue(burners[2] == vm.addr(3));
        assertTrue(burnToken.burner(1) == vm.addr(2));

        burners = burnToken.firstBurners(4);
        assertTrue(burners.length == 3);
        assertTrue(burners[0] == vm.addr(1));
        assertTrue(burners[1] == vm.addr(2));
        assertTrue(burners[2] == vm.addr(3));

        burners = burnToken.lastBurners(2);
        assertTrue(burners.length == 2);
        assertTrue(burners[0] == vm.addr(2));
        assertTrue(burners[1] == vm.addr(3));

        burners = burnToken.lastBurners(4);
        assertTrue(burners.length == 3);
        assertTrue(burners[0] == vm.addr(1));
        assertTrue(burners[1] == vm.addr(2));
        assertTrue(burners[2] == vm.addr(3));
    }

    function testBurnedFromIncreases() public {
        uint256 burnedFrom = burnToken.burnedFrom(vm.addr(1));
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        burnToken.mint(20000 * 10 ** 18);
        burnToken.burn(10000 * 10 ** 18);
        assertTrue(
            burnToken.burnedFrom(vm.addr(1)) - burnedFrom
                == 10000 * 10 ** burnToken.decimals()
        );
        assertTrue(burnToken.burnedFrom(address(0)) == 0);
        vm.stopPrank();
    }

    function testTotalBurnersIncreases() public {
        uint256 totalBurners = burnToken.totalBurners();
        assertTrue(totalBurners == 0);
        burnToken.mint(10000 * 10 ** burnToken.decimals());
        assertTrue(burnToken.totalBurners() == totalBurners);
        burnToken.burn(10000 * 10 ** burnToken.decimals());
        assertTrue(burnToken.totalBurners() == 1);
    }

    function testTotalBurnedIncreases() public {
        uint256 totalBurned = burnToken.totalBurned();
        burnToken.mint(10000 * 10 ** burnToken.decimals());
        assertTrue(burnToken.totalBurned() == totalBurned);
        burnToken.burn(10000 * 10 ** burnToken.decimals());
        assertTrue(
            burnToken.totalBurned() - totalBurned
                == 10000 * 10 ** burnToken.decimals()
        );
    }

    function testBurnersIncrements() public {
        require(burnToken.burns() == 0);
        burnToken.mint(10000 * 10 ** burnToken.decimals());
        burnToken.burn(10000 * 10 ** burnToken.decimals());
        require(burnToken.burns() == 1);
    }
}
