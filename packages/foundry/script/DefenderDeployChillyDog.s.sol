pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import "./DeployHelpers.s.sol";
import {Defender} from "@openzeppelin/foundry-upgrades/Defender.sol";

contract DefenderScript is ScaffoldETHDeploy {
    function setUp() public {}

    function run() public {
        address[] memory contractAddresses = new address[](1);
        contractAddresses[0] =
            address(0x787D961F3DE4FfA402a4A2a0bDf35E1B85E03cC5);
        address deployed = Defender.deployContract(
            "ChillyDog.sol",
            abi.encode(
                address(0x4fbC1714767861e4293dDc4764C2e68fBe1f3856),
                contractAddresses
            )
        );
        console.log("Deployed contract to address", deployed);
    }
}
