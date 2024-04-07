pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import "./DeployHelpers.s.sol";
import {Defender} from "openzeppelin-foundry-upgrades/Defender.sol";

contract DefenderScript is ScaffoldETHDeploy {
    function run() public {
        address deployed = Defender.deployContract(
            "FreshBurnToken.sol",
            abi.encode(address(0xad20652a7e2650128EDFd7135dC2A2B219B0b777))
        );
        console.log("Deployed contract to address", deployed);
    }
}
