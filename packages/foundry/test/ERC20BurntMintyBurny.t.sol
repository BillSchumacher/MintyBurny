// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {ERC20MintyBurny} from
    "../contracts/token/ERC20/examples/ERC20MintyBurny.sol";
import {ERC20BurntMintyBurny} from
    "../contracts/token/ERC20/examples/ERC20BurntMintyBurny.sol";
import {NoTokensToMint} from
    "../contracts/token/ERC20/extensions/ERC20MintyBurnyErrors.sol";
import {IERC20CustomErrors} from
    "../contracts/token/ERC20/extensions/IERC20CustomErrors.sol";
import {ERC20Capped} from
    "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract BurntMintyBurnyTest is Test {
    ERC20MintyBurny public mintyBurny;
    ERC20BurntMintyBurny public burntMintyBurny;

    function setUp() public {
        mintyBurny = new ERC20MintyBurny();
        address[] memory burnAddresses = new address[](1);
        burnAddresses[0] = address(0);
        address[] memory contractAddresses = new address[](1);
        contractAddresses[0] = address(mintyBurny);
        burntMintyBurny =
            new ERC20BurntMintyBurny(burnAddresses, contractAddresses);
    }

    function testWithdraw() public {
        vm.deal(address(vm.addr(1)), 100000 * 10 ** 18);
        vm.deal(address(burntMintyBurny), 100000 * 10 ** 18);
        vm.deal(address(mintyBurny), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        burntMintyBurny.withdraw();
        assertTrue(address(burntMintyBurny).balance == 0);
        mintyBurny.withdraw();
        assertTrue(address(mintyBurny).balance == 0);
        vm.stopPrank();
        vm.deal(address(burntMintyBurny), 100000 * 10 ** 18);
        vm.deal(address(mintyBurny), 100000 * 10 ** 18);
        try burntMintyBurny.withdraw() {
            assertTrue(false, "withdraw() should revert when invalid.");
        } catch (bytes memory reason) {
            bytes4 expectedSelector =
                IERC20CustomErrors.ERC20TransferFailed.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }

    function testMintBurnt() public {
        uint256 minted = burntMintyBurny.totalSupply();
        burntMintyBurny.mintBurned();
        assertTrue(
            burntMintyBurny.totalSupply() - minted
                == mintyBurny.balanceOf(address(0))
                    * burntMintyBurny.burnMintRatio() / 10000
        );
        assertTrue(
            burntMintyBurny.lastBurned() == mintyBurny.balanceOf(address(0))
        );

        try burntMintyBurny.mintBurned() {
            assertTrue(
                false, "mintBurned() should revert when no tokens to mint."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = NoTokensToMint.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }

    function testMintBurntFor() public {
        uint256 minted = burntMintyBurny.totalSupply();
        burntMintyBurny.mintBurnedFor(vm.addr(1));
        assertTrue(
            burntMintyBurny.totalSupply() - minted
                == mintyBurny.balanceOf(address(0))
                    * burntMintyBurny.burnMintRatio() / 10000
        );
        assertTrue(
            burntMintyBurny.balanceOf(vm.addr(1))
                == mintyBurny.balanceOf(address(0))
                    * burntMintyBurny.burnMintRatio() / 10000
        );
    }

    function testCurrentBurned() public {
        assertTrue(
            burntMintyBurny.getCurrentBurned()
                == mintyBurny.balanceOf(address(0))
        );
    }

    function testCurrentBurnerBurned() public {
        vm.startPrank(vm.addr(1));
        assertTrue(
            burntMintyBurny.getCurrentBurnerBurned()
                == mintyBurny.burnedFrom(vm.addr(1))
        );
        vm.stopPrank();
    }

    function testCurrentMinterMinted() public {
        vm.startPrank(vm.addr(1));
        assertTrue(
            burntMintyBurny.getCurrentMinterMinted()
                == mintyBurny.mintedBy(vm.addr(1))
        );
        vm.stopPrank();
    }

    function testCurrentMinted() public {
        assertTrue(
            burntMintyBurny.getCurrentMinted() == mintyBurny.totalSupply()
        );
    }

    function testZeroAddressHasBalance() public {
        burntMintyBurny.burn(10000 * 10 ** burntMintyBurny.decimals());
        uint256 zeroBalance = burntMintyBurny.balanceOf(address(0));
        assertTrue(zeroBalance > 0);
    }

    function testBurnedFromIncreases() public {
        uint256 burnedFrom = burntMintyBurny.burnedFrom(vm.addr(1));
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.prank(vm.addr(1));
        burntMintyBurny.mint(20000 * 10 ** 18);
        vm.prank(vm.addr(1));
        burntMintyBurny.burn(10000 * 10 ** 18);
        assertTrue(
            burntMintyBurny.burnedFrom(vm.addr(1)) - burnedFrom
                == 10000 * 10 ** burntMintyBurny.decimals()
        );
        assertTrue(burntMintyBurny.burnedFrom(address(0)) == 0);
        vm.prank(vm.addr(1));
        burntMintyBurny.approve(vm.addr(2), 10000 * 10 ** 18);
        vm.deal(vm.addr(2), 10000 * 10 ** 18);
        vm.prank(vm.addr(2));
        burntMintyBurny.burnFrom(vm.addr(1), 10000 * 10 ** 18);
        assertTrue(
            burntMintyBurny.burnedFrom(vm.addr(1)) - burnedFrom
                == 20000 * 10 ** burntMintyBurny.decimals()
        );
        assertTrue(burntMintyBurny.balanceOf(vm.addr(1)) == 0);
    }

    function testMintForIncreases() public {
        uint256 minted = burntMintyBurny.mintedBy(vm.addr(2));
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.prank(vm.addr(1));
        burntMintyBurny.mintFor(vm.addr(2), 20000 * 10 ** 18);
        assertTrue(
            burntMintyBurny.mintedBy(vm.addr(2)) - minted
                == 20000 * 10 ** burntMintyBurny.decimals()
        );
    }

    function testTotalMintedIncreases() public {
        uint256 totalMinted = burntMintyBurny.totalMinted();
        burntMintyBurny.burn(10000 * 10 ** burntMintyBurny.decimals());
        assertTrue(burntMintyBurny.totalMinted() == totalMinted);
        burntMintyBurny.mint(10000 * 10 ** burntMintyBurny.decimals());
        assertTrue(
            burntMintyBurny.totalMinted() - totalMinted
                == 10000 * 10 ** burntMintyBurny.decimals()
        );
    }

    function testTotalBurnedIncreases() public {
        uint256 totalBurned = burntMintyBurny.totalBurned();
        burntMintyBurny.mint(10000 * 10 ** burntMintyBurny.decimals());
        assertTrue(burntMintyBurny.totalBurned() == totalBurned);
        burntMintyBurny.burn(10000 * 10 ** burntMintyBurny.decimals());
        assertTrue(
            burntMintyBurny.totalBurned() - totalBurned
                == 10000 * 10 ** burntMintyBurny.decimals()
        );
    }

    function testZeroAddressIncrementsByBurn() public {
        uint256 zeroBalance = burntMintyBurny.balanceOf(address(0));
        burntMintyBurny.burn(10000 * 10 ** burntMintyBurny.decimals());
        uint256 newZeroBalance = burntMintyBurny.balanceOf(address(0));
        assertTrue(
            newZeroBalance - zeroBalance
                == 10000 * 10 ** burntMintyBurny.decimals()
        );
    }

    function testBurnersIncrements() public {
        burntMintyBurny.burn(10000 * 10 ** burntMintyBurny.decimals());
        require(burntMintyBurny.burns() == 2);
    }

    function testMintersIncrements() public {
        burntMintyBurny.mint(10000 * 10 ** burntMintyBurny.decimals());
        require(burntMintyBurny.minters() == 2);
    }

    function testMintingCapped() public {
        try burntMintyBurny.mint(2 ** 255) {
            assertTrue(
                false, "mint(..) should revert when value + supply > maxSupply."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = ERC20Capped.ERC20ExceededCap.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }

    function testMintRatio() public view {
        assertTrue(burntMintyBurny.mintRatio() == 5000);
    }

    function testMintMinterRatio() public view {
        assertTrue(burntMintyBurny.mintMinterRatio() == 5000);
    }

    function testMintBurnerRatio() public view {
        assertTrue(burntMintyBurny.mintBurnerRatio() == 5000);
    }

    function testMintBurnRatio() public view {
        assertTrue(burntMintyBurny.burnMintRatio() == 5000);
    }

    function testMintBurnerBurned() public {
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        mintyBurny.mint(20000 * 10 ** 18);
        mintyBurny.burn(20000 * 10 ** 18);
        uint256 minted = burntMintyBurny.totalSupply();
        burntMintyBurny.mintBurnerBurned();
        assertTrue(
            burntMintyBurny.totalSupply() - minted
                == mintyBurny.burnedFrom(vm.addr(1))
                    * burntMintyBurny.mintBurnerRatio() / 10000
        );
        assertTrue(
            burntMintyBurny.lastBurnerBurned()
                == mintyBurny.burnedFrom(vm.addr(1))
        );

        try burntMintyBurny.mintBurnerBurned() {
            assertTrue(
                false,
                "mintBurnerBurned() should revert when no tokens to mint."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = NoTokensToMint.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
        vm.stopPrank();
    }

    function testMintBurnerBurnedFor() public {
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        mintyBurny.mint(20000 * 10 ** 18);
        mintyBurny.burn(20000 * 10 ** 18);
        uint256 minted = burntMintyBurny.totalSupply();
        burntMintyBurny.mintBurnerBurnedFor(vm.addr(2));
        assertTrue(
            burntMintyBurny.totalSupply() - minted
                == mintyBurny.burnedFrom(vm.addr(1))
                    * burntMintyBurny.mintBurnerRatio() / 10000
        );
        assertTrue(
            burntMintyBurny.lastBurnerBurned()
                == mintyBurny.burnedFrom(vm.addr(1))
        );
        assertTrue(
            burntMintyBurny.balanceOf(vm.addr(2))
                == mintyBurny.burnedFrom(vm.addr(1))
                    * burntMintyBurny.mintBurnerRatio() / 10000
        );
        assertTrue(burntMintyBurny.balanceOf(vm.addr(1)) == 0);

        try burntMintyBurny.mintBurnerBurned() {
            assertTrue(
                false,
                "mintBurnerBurned() should revert when no tokens to mint."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = NoTokensToMint.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
        vm.stopPrank();
    }

    function testMintMinted() public {
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        uint256 minted = burntMintyBurny.totalSupply();
        burntMintyBurny.mintMinted();
        assertTrue(
            burntMintyBurny.totalSupply() - minted
                == mintyBurny.totalSupply() * burntMintyBurny.mintedRatio() / 10000
        );
        assertTrue(burntMintyBurny.lastMinted() == mintyBurny.totalSupply());
        assertTrue(
            burntMintyBurny.balanceOf(vm.addr(1))
                == mintyBurny.totalSupply() * burntMintyBurny.mintedRatio() / 10000
        );

        try burntMintyBurny.mintMinted() {
            assertTrue(
                false, "mintMinted() should revert when no tokens to mint."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = NoTokensToMint.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
        vm.stopPrank();
    }

    function testMintMintedFor() public {
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        uint256 minted = burntMintyBurny.totalSupply();
        burntMintyBurny.mintMintedFor(vm.addr(2));
        assertTrue(
            burntMintyBurny.totalSupply() - minted
                == mintyBurny.totalSupply() * burntMintyBurny.mintedRatio() / 10000
        );
        assertTrue(burntMintyBurny.lastMinted() == mintyBurny.totalSupply());
        assertTrue(
            burntMintyBurny.balanceOf(vm.addr(2))
                == mintyBurny.totalSupply() * burntMintyBurny.mintedRatio() / 10000
        );
        assertTrue(burntMintyBurny.balanceOf(vm.addr(1)) == 0);

        try burntMintyBurny.mintMinted() {
            assertTrue(
                false, "mintMinted() should revert when no tokens to mint."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = NoTokensToMint.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
        vm.stopPrank();
    }

    function testMintMinterMinted() public {
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        uint256 minted = burntMintyBurny.totalSupply();
        mintyBurny.mint(20000 * 10 ** 18);
        burntMintyBurny.mintMinterMinted();
        assertTrue(
            burntMintyBurny.totalSupply() - minted
                == mintyBurny.balanceOf(vm.addr(1))
                    * burntMintyBurny.mintMinterRatio() / 10000
        );
        assertTrue(
            burntMintyBurny.lastMinterMinted()
                == mintyBurny.balanceOf(vm.addr(1))
        );
        assertTrue(
            burntMintyBurny.balanceOf(vm.addr(1))
                == mintyBurny.balanceOf(vm.addr(1))
                    * burntMintyBurny.mintMinterRatio() / 10000
        );

        try burntMintyBurny.mintMinterMinted() {
            assertTrue(
                false, "mintMinter() should revert when no tokens to mint."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = NoTokensToMint.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
        vm.stopPrank();
    }

    function testMintMinterMintedFor() public {
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.startPrank(vm.addr(1));
        uint256 minted = burntMintyBurny.totalSupply();
        mintyBurny.mint(20000 * 10 ** 18);
        burntMintyBurny.mintMinterMintedFor(vm.addr(2));
        assertTrue(
            burntMintyBurny.totalSupply() - minted
                == mintyBurny.mintedBy(vm.addr(1))
                    * burntMintyBurny.mintMinterRatio() / 10000
        );
        assertTrue(
            burntMintyBurny.lastMinterMinted()
                == mintyBurny.balanceOf(vm.addr(1))
        );
        assertTrue(
            burntMintyBurny.balanceOf(vm.addr(2))
                == mintyBurny.mintedBy(vm.addr(1))
                    * burntMintyBurny.mintMinterRatio() / 10000
        );

        assertTrue(burntMintyBurny.balanceOf(vm.addr(1)) == 0);
        try burntMintyBurny.mintMinterMintedFor(vm.addr(2)) {
            assertTrue(
                false,
                "mintMinterMintedFor() should revert when no tokens to mint."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = NoTokensToMint.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
        vm.stopPrank();
    }
}
