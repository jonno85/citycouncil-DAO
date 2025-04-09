// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {CityCouncilDAO} from "../src/CityCouncilDAO.sol";

contract DeploySepolia is Script {
    function run() public {
        // Retrieve private key from environment
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy with no existing meeting queue
        CityCouncilDAO cityCouncilDAO = new CityCouncilDAO(
            address(0), // No existing meeting queue
            vm.addr(deployerPrivateKey) // Deployer as governance admin
        );

        vm.stopBroadcast();

        // Log deployment information
        console.log("CityCouncilDAO deployed to:", address(cityCouncilDAO));
        console.log("Governance Admin:", cityCouncilDAO.governanceAdmin());
        
        // Save deployment address to file
        string memory deploymentInfo = string(
            abi.encodePacked(
                "CITY_COUNCIL_DAO_ADDRESS=", vm.toString(address(cityCouncilDAO))
            )
        );
        vm.writeFile("deployment.txt", deploymentInfo);
    }
}