// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {CityCouncilDAO} from "../src/CityCouncilDAO.sol";

contract InteractLocal is Script {
    // Anvil's default accounts
    address constant ADMIN = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant MEMBER1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address constant MEMBER2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    CityCouncilDAO public cityCouncilDAO;

    function setUp() public {
        // Replace with your deployed contract address
        cityCouncilDAO = CityCouncilDAO(0x5FbDB2315678afecb367f032d93F642f64180aa3);
    }

    function run() public {
        // Use first account as admin
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        
        vm.startBroadcast(deployerPrivateKey);

        // Add council members
        cityCouncilDAO.addCouncilMember(MEMBER1);
        cityCouncilDAO.addCouncilMember(MEMBER2);

        // Schedule a meeting (1 day from now)
        uint256 meetingTime = block.timestamp + 1 days;
        cityCouncilDAO.scheduleMeeting(meetingTime);

        vm.stopBroadcast();

        // Switch to MEMBER1
        vm.startBroadcast(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d);
        
        // Propose an objective
        cityCouncilDAO.proposeObjective("City Park Renovation", "Renovate the central park with new facilities");
        
        vm.stopBroadcast();

        // Log status
        console.log("Council members count:", cityCouncilDAO.getCouncilMemberCount());
        console.log("Meeting scheduled for:", meetingTime);
    }
}