// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {CityCouncilDAO} from "../src/CityCouncilDAO.sol";

contract CityCouncilDAOScript is Script {
    CityCouncilDAO public cityCouncilDAO;
    address public governanceAdmin;

    function setUp() public {}

    function run() public {
        // Retrieve private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Set governance admin (could be from env var too)
        governanceAdmin = msg.sender;
        
        // Deploy the contract
        cityCouncilDAO = new CityCouncilDAO(
            address(0), // No existing meeting queue
            governanceAdmin
        );

        vm.stopBroadcast();
    }
}
