// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/token/ChillyDog.sol";
import "../contracts/token/HotDog.sol";
import "../contracts/token/BurnToken.sol";
import "../contracts/token/FreshBurnTokens.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../contracts/token/ERC20/extensions/ERC20MintyBurnyErrors.sol";

contract ChillyDogTest is Test {
    BurnToken public burnToken;
    ChillyDog public chillyDog;
    HotDog public hotDog;
    FreshBurnTokens public registry;
    address public deadAddress;
    address public ownerAddress;
    address public feeAddress;
    address public chillyDogAddress;

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
        contractAddresses[0] = address(hotDog);
        chillyDog = new ChillyDog(address(registry), contractAddresses);
        chillyDogAddress = address(chillyDog);
        vm.deal(ownerAddress, 1000000 * 10 ** 18);
        vm.startPrank(ownerAddress);
        burnToken.transfer(deadAddress, 10000000 * 10 ** 18);
        hotDog.mintBurned{value: 0.01 ether}();
        vm.stopPrank();
    }

    uint256 private _mintFee = 0.01 ether;

    function testMintMinted() public {
        try chillyDog.mintMinted{value: 0.001 ether}() {
            assertTrue(false, "mintFor(..) should revert due to fee.");
        } catch (bytes memory reason) {
            bytes4 expectedSelector = ChillyDog.InsufficientMintFee.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
        uint256 minted = chillyDog.totalSupply();
        chillyDog.mintMinted{value: 0.01 ether}();
        assertTrue(
            chillyDog.totalSupply() - minted
                == hotDog.totalSupply() * chillyDog.mintRatio() / 10000
        );
        assertTrue(chillyDog.lastMinted() == hotDog.totalSupply());

        try chillyDog.mintMinted{value: 0.02 ether}() {
            assertTrue(
                false, "mintBurned() should revert when no tokens to mint."
            );
        } catch (bytes memory reason) {
            bytes4 expectedSelector = NoTokensToMint.selector;
            bytes4 receivedSelector = bytes4(reason);
            assertEq(expectedSelector, receivedSelector);
        }
    }

    function testMintMintedFor() public {
        uint256 minted = chillyDog.totalSupply();
        chillyDog.mintMintedFor{value: 0.01 ether}(vm.addr(1));
        assertTrue(
            chillyDog.totalSupply() - minted
                == hotDog.totalSupply() * chillyDog.mintRatio() / 10000
        );
        assertTrue(
            chillyDog.balanceOf(vm.addr(1))
                == hotDog.totalSupply() * chillyDog.mintRatio() / 10000
        );
    }

    function testCurrentMinted() public {
        assertTrue(chillyDog.getCurrentMinted() == hotDog.totalSupply());
    }

    function testZeroAddressHasBalance() public {
        chillyDog.mintMinted{value: 0.01 ether}();
        chillyDog.burn(10000 * 10 ** chillyDog.decimals());
        uint256 zeroBalance = chillyDog.balanceOf(address(0));
        assertTrue(zeroBalance > 0);
    }

    function testMintFeeIncreases() public {
        uint256 mintFee = chillyDog.getMintFee();
        assertTrue(chillyDog.getMintFee() == 0.01 ether);
        chillyDog.mintMinted{value: 0.01 ether}();
        chillyDog.burn(10000 * 10 ** chillyDog.decimals());
        uint256 newMintFee = 0.01 ether * 1001 / 1000;
        assertTrue(chillyDog.getMintFee() == newMintFee);
    }
}
