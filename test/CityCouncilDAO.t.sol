// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {CityCouncilDAO} from "../src/CityCouncilDAO.sol";
import {CityCouncilMeetingQueue} from "../src/CityCouncilMeetingQueue.sol";
import {VotingFunction} from "../src/VotingFunction.sol";

contract CityCouncilDAOTest is Test {
    CityCouncilDAO public cityCouncilDAO;
    address public governanceAdmin;
    address public councilMember;
    address public councilMember2;
    uint256 public constant MEETING_TIME = 1703980800; // 2023-12-31 00:00:00 UTC

    function setUp() public {
        governanceAdmin = makeAddr("governanceAdmin");
        councilMember = makeAddr("councilMember");
        councilMember2 = makeAddr("councilMember2");
        
        cityCouncilDAO = new CityCouncilDAO(address(0), governanceAdmin);
        vm.prank(governanceAdmin);
        cityCouncilDAO.addCouncilMember(councilMember);
        vm.prank(governanceAdmin);
        cityCouncilDAO.addCouncilMember(councilMember2);

        vm.prank(councilMember);
        cityCouncilDAO.proposeObjective("Test Objective", "Test Description");
    }

    function test_InitialState() public view {
        assertEq(cityCouncilDAO.governanceAdmin(), governanceAdmin);
        assertTrue(cityCouncilDAO.isCouncilMember(governanceAdmin));
    }

    function test_AddCouncilMember() public {
        address newMember = makeAddr("newMember");
        
        vm.prank(governanceAdmin);
        cityCouncilDAO.addCouncilMember(newMember);
        
        assertTrue(cityCouncilDAO.isCouncilMember(newMember));
    }

    function test_RemoveCouncilMember() public {
        address member = makeAddr("member");
        
        vm.startPrank(governanceAdmin);
        cityCouncilDAO.addCouncilMember(member);
        cityCouncilDAO.removeCouncilMember(member);
        vm.stopPrank();
        
        assertFalse(cityCouncilDAO.isCouncilMember(member));
    }

    function test_RevertWhen_RemovingGovernanceAdmin() public {
        vm.prank(governanceAdmin);
        vm.expectRevert("Cannot remove the governance admin.");
        cityCouncilDAO.removeCouncilMember(governanceAdmin);
    }

    // --- Meeting Queue Proxy Tests ---
    function test_setObjectiveInactive() public {
        vm.prank(councilMember);
        cityCouncilDAO.setObjectiveInactive(1);

        CityCouncilMeetingQueue.PoliticalObjective memory objective = cityCouncilDAO.getObjectiveDetails(1);
        assertFalse(objective.isActive);
    }

    function test_ScheduleMeeting() public {
        vm.prank(governanceAdmin);
        cityCouncilDAO.scheduleMeeting(MEETING_TIME);
        
        CityCouncilMeetingQueue.Meeting memory meeting = cityCouncilDAO.getMeetingDetails(1);
        assertEq(meeting.scheduledTime, MEETING_TIME);
        assertTrue(meeting.isActive);
    }

    function test_RevertWhen_NonAdminSchedulesMeeting() public {
        vm.prank(councilMember);
        vm.expectRevert("Only governance admin can call this function.");
        cityCouncilDAO.scheduleMeeting(MEETING_TIME);
    }

    function test_SetMeetingInactive() public {
        vm.startPrank(governanceAdmin);
        cityCouncilDAO.scheduleMeeting(MEETING_TIME);
        cityCouncilDAO.setMeetingInactive(1);
        vm.stopPrank();

        CityCouncilMeetingQueue.Meeting memory meeting = cityCouncilDAO.getMeetingDetails(1);
        assertFalse(meeting.isActive);
        assertEq(MEETING_TIME, meeting.scheduledTime);
    }

    function test_ProposeObjective() public view {
        CityCouncilMeetingQueue.PoliticalObjective memory objective = cityCouncilDAO.getObjectiveDetails(1);
        assertEq(objective.title, "Test Objective");
        assertEq(objective.description, "Test Description");
        assertEq(objective.proposer, councilMember);
        assertTrue(objective.isActive);
    }

    function test_RevertWhen_NonMemberProposesObjective() public {
        address nonMember = makeAddr("nonMember");
        vm.prank(nonMember);
        vm.expectRevert("Only council members can call this function.");
        cityCouncilDAO.proposeObjective("Test Objective", "Test Description");
    }

    function test_AddObjectiveToQueue() public {
        vm.prank(governanceAdmin);
        cityCouncilDAO.scheduleMeeting(MEETING_TIME);
        
        vm.prank(governanceAdmin);
        cityCouncilDAO.addObjectiveToQueue(1, 1);

        uint256[] memory queue = cityCouncilDAO.getMeetingQueue(1);
        assertEq(queue.length, 1);
        assertEq(queue[0], 1);
    }

    // --- Voting Function Proxy Tests ---
    function test_StartVoting() public {
        vm.prank(governanceAdmin);
        cityCouncilDAO.scheduleMeeting(MEETING_TIME);

        vm.prank(governanceAdmin);
        cityCouncilDAO.addObjectiveToQueue(1, 1);

        vm.prank(councilMember);
        cityCouncilDAO.startVoting(1);

        VotingFunction.VotingDetails memory voting = cityCouncilDAO.getVotingDetails(1);
        assertEq(voting.objectiveId, 1);
        assertFalse(voting.isCompleted);
    }

    function test_CastVote() public {
        // Setup voting
        vm.prank(governanceAdmin);
        cityCouncilDAO.scheduleMeeting(MEETING_TIME);

        vm.prank(governanceAdmin);
        cityCouncilDAO.addObjectiveToQueue(1, 1);
        
        vm.prank(councilMember);
        cityCouncilDAO.startVoting(1);


        vm.prank(governanceAdmin);
        cityCouncilDAO.castVote(1, VotingFunction.Vote.NO);
        // Cast votes
        vm.prank(councilMember);
        cityCouncilDAO.castVote(1, VotingFunction.Vote.YES);

        vm.prank(councilMember2);
        cityCouncilDAO.castVote(1, VotingFunction.Vote.ABSTAIN);

        // Verify votes
        assertEq(uint(cityCouncilDAO.getVote(1, councilMember)), uint(VotingFunction.Vote.YES));
        assertEq(uint(cityCouncilDAO.getVote(1, councilMember2)), uint(VotingFunction.Vote.ABSTAIN));
        assertEq(uint(cityCouncilDAO.getVote(1, governanceAdmin)), uint(VotingFunction.Vote.NO));
    }

    function test_EndVoting() public {
        // Setup and cast votes
        
        vm.prank(councilMember);
        cityCouncilDAO.startVoting(1);

        vm.prank(councilMember);
        cityCouncilDAO.castVote(1, VotingFunction.Vote.YES);

        vm.prank(councilMember2);
        cityCouncilDAO.castVote(1, VotingFunction.Vote.NO);

        vm.prank(governanceAdmin);
        cityCouncilDAO.castVote(1, VotingFunction.Vote.YES);

        // End voting
        vm.prank(councilMember);
        cityCouncilDAO.endVoting(1);

        VotingFunction.VotingDetails memory voting = cityCouncilDAO.getVotingDetails(1);
        assertTrue(voting.isCompleted);
        assertTrue(voting.isPassed); // Should pass with 2 YES votes out of 3 members
    }

    function test_SetVotingDuration() public {
        uint256 newDuration = 7 days;
        
        vm.prank(governanceAdmin);
        cityCouncilDAO.setVotingDuration(newDuration);

        VotingFunction.VotingDurationDetails memory votingDetails = cityCouncilDAO.getVotingDuration(1);
        assertEq(uint(votingDetails.votingDuration), uint(newDuration));
    }

    function test_RevertWhen_NonMemberStartsVoting() public {
        address nonMember = makeAddr("nonMember");

        vm.prank(nonMember);
        vm.expectRevert("Only council members can call this function.");
        cityCouncilDAO.startVoting(1);
    }

    function test_RevertWhen_NonMemberCastsVote() public {
        address nonMember = makeAddr("nonMember");
        
        vm.prank(councilMember);
        cityCouncilDAO.startVoting(1);

        vm.prank(nonMember);
        vm.expectRevert("Only council members can call this function.");
        cityCouncilDAO.castVote(1, VotingFunction.Vote.YES);
    }
}
