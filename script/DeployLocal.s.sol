// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {CityCouncilDAO} from "../src/CityCouncilDAO.sol";

contract DeployLocal is Script {
    CityCouncilDAO public cityCouncilDAO;

    function setUp() public {}

    function run() public {
        // Use a default private key for local testing
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy with no existing meeting queue and first account as admin
        cityCouncilDAO = new CityCouncilDAO(
            address(0),
            vm.addr(deployerPrivateKey)
        );

        vm.stopBroadcast();

        // Log deployment info
        console.log("CityCouncilDAO deployed to:", address(cityCouncilDAO));
        console.log("Governance Admin:", cityCouncilDAO.governanceAdmin());
    }
}