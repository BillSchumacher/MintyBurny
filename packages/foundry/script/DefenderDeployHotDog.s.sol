pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import "./DeployHelpers.s.sol";
import {Defender} from "@openzeppelin/foundry-upgrades/Defender.sol";

contract DefenderScript is ScaffoldETHDeploy {
    function setUp() public {}

    function run() public {
        address[] memory burnAddresses = new address[](3);
        address[] memory contractAddresses = new address[](1);
        burnAddresses[0] = address(0x0000000000000000000000000000000000000000);
        burnAddresses[1] = address(0xdEAD000000000000000042069420694206942069);
        burnAddresses[2] = address(0x000000000000000000000000000000000000dEaD);
        contractAddresses[0] =
            address(0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE);
        address deployed = Defender.deployContract(
            "HotDog.sol",
            abi.encode(
                address(0x4fbC1714767861e4293dDc4764C2e68fBe1f3856),
                burnAddresses,
                contractAddresses
            )
        );
        console.log("Deployed contract to address", deployed);
    }
}
