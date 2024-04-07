// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/token/HotDog.sol";
import "../contracts/token/BurnToken.sol";
import "../contracts/token/FreshBurnTokens.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../contracts/token/ERC20/extensions/ERC20MintyBurnyErrors.sol";

contract HotDogTest is Test {
    BurnToken public burnToken;
    HotDog public hotDog;
    FreshBurnTokens public registry;
    address public deadAddress;
    address public ownerAddress;
    address public feeAddress;
    address public hotdogAddress;

    function setUp() public {
        ownerAddress = 0xB8f226dDb7bC672E27dffB67e4adAbFa8c0dFA08;
        feeAddress = 0x6603cb70464ca51481d4edBb3B927F66F53F4f42;
        deadAddress = 0xdEAD000000000000000042069420694206942069;
        burnToken = new BurnToken("Shiba Inu", "SHIB");
        vm.prank(ownerAddress);
        burnToken.mint(1000000000000000000000000000);
        address burnTokenContractAddress = address(burnToken);
        address[] memory burnAddresses = new address[](1);
        burnAddresses[0] = deadAddress;
        address[] memory contractAddresses = new address[](1);
        contractAddresses[0] = burnTokenContractAddress;
        registry = new FreshBurnTokens();
        hotDog = new HotDog(address(registry), burnAddresses, contractAddresses);
        hotdogAddress = address(hotDog);
        vm.deal(ownerAddress, 1000000 * 10 ** 18);
        vm.prank(ownerAddress);
        burnToken.transfer(deadAddress, 10000000 * 10 ** 18);
    }

    uint256 private _mintFee = 0.01 ether;

    function testMintBurnt() public {
        try hotDog.mintBurned{value: 0.001 ether}() {
            assertTrue(false, "mintFor(..) should revert due to fee.");
        } catch (bytes memory reason) {
            bytes4 expectedSelector = HotDog.InsufficientMintFee.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
        uint256 minted = hotDog.totalSupply();
        hotDog.mintBurned{value: 0.01 ether}();
        assertTrue(
            hotDog.totalSupply() - minted
                == burnToken.balanceOf(deadAddress) * hotDog.mintRatio() / 10000
        );
        assertTrue(hotDog.lastBurned() == burnToken.balanceOf(deadAddress));

        try hotDog.mintBurned{value: 0.02 ether}() {
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
        uint256 minted = hotDog.totalSupply();
        hotDog.mintBurnedFor{value: 0.01 ether}(vm.addr(1));
        assertTrue(
            hotDog.totalSupply() - minted
                == burnToken.balanceOf(deadAddress) * hotDog.mintRatio() / 10000
        );
        assertTrue(
            hotDog.balanceOf(vm.addr(1))
                == burnToken.balanceOf(deadAddress) * hotDog.mintRatio() / 10000
        );
    }

    function testCurrentBurned() public {
        assertTrue(
            hotDog.getCurrentBurned() == burnToken.balanceOf(deadAddress)
        );
    }

    function testZeroAddressHasBalance() public {
        hotDog.mintBurned{value: 0.01 ether}();
        hotDog.burn(10000 * 10 ** hotDog.decimals());
        uint256 zeroBalance = hotDog.balanceOf(address(0));
        assertTrue(zeroBalance > 0);
    }

    function testBurnedFromIncreases() public {
        uint256 burnedFrom = registry.burnedFrom(hotdogAddress, vm.addr(1));
        vm.deal(vm.addr(1), 1000000 * 10 ** 18);
        vm.prank(vm.addr(1));
        hotDog.mintBurned{value: 0.01 ether}();
        vm.prank(vm.addr(1));
        hotDog.burn(10000 * 10 ** 18);
        assertTrue(
            registry.burnedFrom(hotdogAddress, vm.addr(1)) - burnedFrom
                == 10000 * 10 ** hotDog.decimals()
        );
        assertTrue(registry.burnedFrom(hotdogAddress, address(0)) == 0);
        vm.prank(vm.addr(1));
        hotDog.approve(vm.addr(2), 10000 * 10 ** 18);
        vm.deal(vm.addr(2), 10000 * 10 ** 18);
        uint256 beforeBalance = hotDog.balanceOf(vm.addr(1));
        vm.prank(vm.addr(2));
        hotDog.burnFrom(vm.addr(1), 10000 * 10 ** 18);
        assertTrue(
            registry.burnedFrom(hotdogAddress, vm.addr(1)) - burnedFrom
                == 20000 * 10 ** hotDog.decimals()
        );
        assertTrue(
            hotDog.balanceOf(vm.addr(1)) == beforeBalance - 10000 * 10 ** 18
        );
    }

    function testMintBurnedForIncreases() public {
        uint256 minted = registry.mintedBy(hotdogAddress, vm.addr(2));
        vm.deal(vm.addr(1), 100000 * 10 ** 18);
        vm.prank(vm.addr(1));
        hotDog.mintBurnedFor{value: 0.01 ether}(vm.addr(2));
        assertTrue(
            registry.mintedBy(hotdogAddress, vm.addr(2)) - minted
                == burnToken.balanceOf(deadAddress) * hotDog.mintRatio() / 10000
        );
    }

    function testTotalMintedIncreases() public {
        uint256 totalMinted = registry.totalMinted(hotdogAddress);
        hotDog.mintBurned{value: 0.01 ether}();
        hotDog.burn(10000 * 10 ** hotDog.decimals());
        assertTrue(
            registry.totalMinted(hotdogAddress) - totalMinted
                == burnToken.balanceOf(deadAddress) * hotDog.mintRatio() / 10000
        );
    }

    function testTotalBurnedIncreases() public {
        uint256 totalBurned = registry.totalBurned(hotdogAddress);
        hotDog.mintBurned{value: 0.01 ether}();
        assertTrue(registry.totalBurned(hotdogAddress) == totalBurned);
        hotDog.burn(10000 * 10 ** hotDog.decimals());
        assertTrue(
            registry.totalBurned(hotdogAddress) - totalBurned
                == 10000 * 10 ** hotDog.decimals()
        );
    }

    function testZeroAddressIncrementsByBurn() public {
        uint256 zeroBalance = hotDog.balanceOf(address(0));
        hotDog.mintBurned{value: 0.01 ether}();
        hotDog.burn(10000 * 10 ** hotDog.decimals());
        uint256 newZeroBalance = hotDog.balanceOf(address(0));
        assertTrue(
            newZeroBalance - zeroBalance == 10000 * 10 ** hotDog.decimals()
        );
    }

    function testBurnersIncrements() public {
        hotDog.mintBurned{value: 0.01 ether}();
        hotDog.burn(10000 * 10 ** hotDog.decimals());
        require(registry.burns(hotdogAddress) == 1);
    }

    function testMintersIncrements() public {
        hotDog.mintBurned{value: 0.01 ether}();
        require(registry.totalMinters(hotdogAddress) == 1);
    }

    function testMintFeeIncreases() public {
        uint256 mintFee = hotDog.getMintFee();
        assertTrue(hotDog.getMintFee() == 0.01 ether);
        hotDog.mintBurned{value: 0.01 ether}();
        hotDog.burn(10000 * 10 ** hotDog.decimals());
        uint256 newMintFee = 0.01 ether * 1001 / 1000;
        assertTrue(hotDog.getMintFee() == newMintFee);
    }
}
