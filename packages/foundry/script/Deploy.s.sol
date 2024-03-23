//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../contracts/MintyBurny.sol";
import "../contracts/BurntMintyBurny.sol";
import "./DeployHelpers.s.sol";

contract DeployScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    function run() external {
        uint256 deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        vm.startBroadcast(deployerPrivateKey);
        MintyBurny mintyBurnyContract = new MintyBurny(); //vm.addr(deployerPrivateKey)
        console.logString(
            string.concat(
                "MintyBurny deployed at: ",
                vm.toString(address(mintyBurnyContract))
            )
        );
        address[] memory burnAddresses = new address[](1);
        address[] memory contractAddresses = new address[](1);
        burnAddresses[0] = address(0);
        contractAddresses[0] = address(mintyBurnyContract);
        BurntMintyBurny burntMintyBurnyContract =
            new BurntMintyBurny(burnAddresses, contractAddresses); //vm.addr(deployerPrivateKey)
        console.logString(
            string.concat(
                "BurntMintyBurny deployed at: ",
                vm.toString(address(burntMintyBurnyContract))
            )
        );
        vm.stopBroadcast();

        /**
         * This function generates the file containing the contracts Abi definitions.
         * These definitions are used to derive the types needed in the custom scaffold-eth hooks, for example.
         * This function should be called last.
         */
        exportDeployments();
    }

    function test() public {}
}
