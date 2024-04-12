pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import "./DeployHelpers.s.sol";
import {Defender} from "@openzeppelin/foundry-upgrades/Defender.sol";

contract DefenderScript is ScaffoldETHDeploy {
    function run() public {
        address deployed =
            Defender.deployContract("MintyBurnyRegistry.sol", abi.encode());
        console.log("Deployed contract to address", deployed);
    }
}
