// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {FreshBurnTokensUpgradeable} from
    "../contracts/token/FreshBurnTokensUpgradeable.sol";
import {FreshBurnTokenUpgradeable} from
    "../contracts/token/FreshBurnTokenUpgradeable.sol";
import {IERC20CustomErrors} from
    "../contracts/token/ERC20/extensions/IERC20CustomErrors.sol";

contract TestMultiMintBurnUpgradeableTest is Test {
    FreshBurnTokensUpgradeable public freshBurnTokens;
    FreshBurnTokenUpgradeable public freshBurnToken;
    address public freshBurnTokenAddress;

    function setUp() public {
        freshBurnTokens = new FreshBurnTokensUpgradeable();
        freshBurnToken = new FreshBurnTokenUpgradeable();
        freshBurnToken.initialize(address(freshBurnTokens));
        freshBurnTokenAddress = address(freshBurnToken);
    }

    function testWithdraw() public {
        vm.deal(address(vm.addr(1)), 100000 * 10 ** 18);
        vm.deal(address(freshBurnTokens), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        freshBurnTokens.withdraw();
        assertTrue(address(freshBurnTokens).balance == 0);
        vm.stopPrank();
        vm.deal(address(freshBurnTokens), 100000 * 10 ** 18);
        try freshBurnTokens.withdraw() {
            assertTrue(false, "withdraw() should revert when invalid.");
        } catch (bytes memory reason) {
            bytes4 expectedSelector =
                IERC20CustomErrors.ERC20TransferFailed.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }

    function testRegistryMintAndBurn() public {
        freshBurnToken.mint(300);
        assertEq(freshBurnTokens.totalMinted(freshBurnTokenAddress), 300);
        freshBurnToken.burn(100);
        assertEq(freshBurnTokens.totalBurned(freshBurnTokenAddress), 100);
        assertEq(freshBurnTokens.totalMinted(freshBurnTokenAddress), 300);
        freshBurnToken.burn(100);
        assertEq(freshBurnTokens.totalBurned(freshBurnTokenAddress), 200);
        freshBurnToken.burn(100);
        assertEq(freshBurnTokens.totalBurned(freshBurnTokenAddress), 300);
        vm.startPrank(vm.addr(2));
        freshBurnToken.mint(100);
        freshBurnToken.transfer(vm.addr(1), 100);
        assertEq(freshBurnToken.balanceOf(vm.addr(1)), 100);
        vm.stopPrank();
    }

    function testFirstAndLastBurners() public {
        vm.startPrank(vm.addr(1));
        freshBurnToken.mint(20000 * 10 ** freshBurnToken.decimals());
        freshBurnToken.burn(10000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, vm.addr(1))
                == 10000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, address(0)) == 0
        );
        vm.stopPrank();
        vm.startPrank(vm.addr(2));
        freshBurnToken.mint(30000 * 10 ** freshBurnToken.decimals());
        freshBurnToken.burn(20000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, vm.addr(2))
                == 20000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, vm.addr(1))
                == 10000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, address(0)) == 0
        );
        vm.stopPrank();
        vm.startPrank(vm.addr(3));
        freshBurnToken.mint(40000 * 10 ** freshBurnToken.decimals());
        freshBurnToken.burn(30000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, vm.addr(3))
                == 30000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, vm.addr(2))
                == 20000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, vm.addr(1))
                == 10000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, address(0)) == 0
        );
        vm.stopPrank();

        address[] memory burners =
            freshBurnTokens.firstBurners(freshBurnTokenAddress, 3);
        assertTrue(burners.length == 3);
        assertTrue(burners[0] == vm.addr(1));
        assertTrue(burners[1] == vm.addr(2));
        assertTrue(burners[2] == vm.addr(3));
        assertTrue(
            freshBurnTokens.burner(freshBurnTokenAddress, 1) == vm.addr(2)
        );

        burners = freshBurnTokens.firstBurners(freshBurnTokenAddress, 4);
        assertTrue(burners.length == 3);
        assertTrue(burners[0] == vm.addr(1));
        assertTrue(burners[1] == vm.addr(2));
        assertTrue(burners[2] == vm.addr(3));

        burners = freshBurnTokens.lastBurners(freshBurnTokenAddress, 2);
        assertTrue(burners.length == 2);
        assertTrue(burners[0] == vm.addr(2));
        assertTrue(burners[1] == vm.addr(3));

        burners = freshBurnTokens.lastBurners(freshBurnTokenAddress, 4);
        assertTrue(burners.length == 3);
        assertTrue(burners[0] == vm.addr(1));
        assertTrue(burners[1] == vm.addr(2));
        assertTrue(burners[2] == vm.addr(3));
    }

    function testBurnedFromIncreases() public {
        uint256 burnedFrom =
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, vm.addr(1));
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        freshBurnToken.mint(20000 * 10 ** 18);
        freshBurnToken.burn(10000 * 10 ** 18);
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, vm.addr(1))
                - burnedFrom == 10000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.burnedFrom(freshBurnTokenAddress, address(0)) == 0
        );
        vm.stopPrank();
    }

    function testTotalBurnersIncreases() public {
        uint256 totalBurners =
            freshBurnTokens.totalBurners(freshBurnTokenAddress);
        assertTrue(totalBurners == 0);
        freshBurnToken.mint(10000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.totalBurners(freshBurnTokenAddress) == totalBurners
        );
        freshBurnToken.burn(10000 * 10 ** freshBurnToken.decimals());
        assertTrue(freshBurnTokens.totalBurners(freshBurnTokenAddress) == 1);
    }

    function testTotalBurnedIncreases() public {
        uint256 totalBurned = freshBurnTokens.totalBurned(freshBurnTokenAddress);
        freshBurnToken.mint(10000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.totalBurned(freshBurnTokenAddress) == totalBurned
        );
        freshBurnToken.burn(10000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.totalBurned(freshBurnTokenAddress) - totalBurned
                == 10000 * 10 ** freshBurnToken.decimals()
        );
    }

    function testBurnersIncrements() public {
        require(freshBurnTokens.burns(freshBurnTokenAddress) == 0);
        freshBurnToken.mint(10000 * 10 ** freshBurnToken.decimals());
        freshBurnToken.burn(10000 * 10 ** freshBurnToken.decimals());
        require(freshBurnTokens.burns(freshBurnTokenAddress) == 1);
    }

    function testFirstAndLastMinters() public {
        vm.startPrank(vm.addr(1));
        freshBurnToken.mint(20000 * 10 ** freshBurnToken.decimals());
        freshBurnToken.burn(10000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, vm.addr(1))
                == 20000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, address(0)) == 0
        );
        vm.stopPrank();
        vm.startPrank(vm.addr(2));
        freshBurnToken.mint(30000 * 10 ** freshBurnToken.decimals());
        freshBurnToken.burn(20000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, vm.addr(2))
                == 30000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, vm.addr(1))
                == 20000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, address(0)) == 0
        );
        vm.stopPrank();
        vm.startPrank(vm.addr(3));
        freshBurnToken.mint(40000 * 10 ** freshBurnToken.decimals());
        freshBurnToken.burn(30000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, vm.addr(3))
                == 40000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, vm.addr(2))
                == 30000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, vm.addr(1))
                == 20000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, address(0)) == 0
        );
        vm.stopPrank();

        address[] memory minters =
            freshBurnTokens.firstMinters(freshBurnTokenAddress, 3);
        assertTrue(minters.length == 3);
        assertTrue(minters[0] == vm.addr(1));
        assertTrue(minters[1] == vm.addr(2));
        assertTrue(minters[2] == vm.addr(3));
        assertTrue(
            freshBurnTokens.minter(freshBurnTokenAddress, 1) == vm.addr(2)
        );

        minters = freshBurnTokens.firstMinters(freshBurnTokenAddress, 4);
        assertTrue(minters.length == 3);
        assertTrue(minters[0] == vm.addr(1));
        assertTrue(minters[1] == vm.addr(2));
        assertTrue(minters[2] == vm.addr(3));

        minters = freshBurnTokens.lastMinters(freshBurnTokenAddress, 2);
        assertTrue(minters.length == 2);
        assertTrue(minters[0] == vm.addr(2));
        assertTrue(minters[1] == vm.addr(3));

        minters = freshBurnTokens.lastMinters(freshBurnTokenAddress, 4);
        assertTrue(minters.length == 3);
        assertTrue(minters[0] == vm.addr(1));
        assertTrue(minters[1] == vm.addr(2));
        assertTrue(minters[2] == vm.addr(3));
    }

    function testMintedByIncreases() public {
        uint256 mintedBy =
            freshBurnTokens.mintedBy(freshBurnTokenAddress, vm.addr(1));
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        freshBurnToken.mint(20000 * 10 ** 18);
        freshBurnToken.burn(10000 * 10 ** 18);
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, vm.addr(1))
                - mintedBy == 20000 * 10 ** freshBurnToken.decimals()
        );
        assertTrue(
            freshBurnTokens.mintedBy(freshBurnTokenAddress, address(0)) == 0
        );
        vm.stopPrank();
    }

    function testTotalMintersIncreases() public {
        uint256 totalMinters =
            freshBurnTokens.totalMinters(freshBurnTokenAddress);
        assertTrue(totalMinters == 0);
        freshBurnToken.mint(10000 * 10 ** freshBurnToken.decimals());
        assertTrue(freshBurnTokens.totalMinters(freshBurnTokenAddress) == 1);
        freshBurnToken.burn(5000 * 10 ** freshBurnToken.decimals());
        assertTrue(freshBurnTokens.totalMinters(freshBurnTokenAddress) == 1);
    }

    function testTotalMintedIncreases() public {
        uint256 totalMinted = freshBurnTokens.totalMinted(freshBurnTokenAddress);
        freshBurnToken.mint(10000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.totalMinted(freshBurnTokenAddress)
                == 10000 * 10 ** freshBurnToken.decimals()
        );
        freshBurnToken.burn(5000 * 10 ** freshBurnToken.decimals());
        assertTrue(
            freshBurnTokens.totalMinted(freshBurnTokenAddress) - totalMinted
                == 10000 * 10 ** freshBurnToken.decimals()
        );
    }
}
