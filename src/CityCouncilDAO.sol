// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./CityCouncilMeetingQueue.sol";
import "./VotingFunction.sol";

contract CityCouncilDAO {
    
    // --- State Variables ---
    CityCouncilMeetingQueue public meetingQueue;
    VotingFunction public votingFunction;
    mapping(address => bool) public isCouncilMember;
    address[] private councilMembers;
    uint256 public councilMemberCount;

    address public governanceAdmin;

    // --- Modifiers ---
    modifier onlyGovernanceAdmin() {
        require(msg.sender == governanceAdmin, "Only governance admin can call this function.");
        _;
    }

    modifier onlyCouncilMember() {
        require(isCouncilMember[msg.sender], "Only council members can call this function.");
        _;
    }

    // --- Constructor ---
    /// @notice Initializes the DAO with optional existing meeting queue and required governance admin
    /// @param _meetingQueue Address of existing meeting queue, or address(0) to deploy new one
    /// @param _governanceAdmin Address that will have admin privileges
    constructor(address _meetingQueue, address _governanceAdmin) {
        if(_meetingQueue != address(0)) {
            meetingQueue = CityCouncilMeetingQueue(_meetingQueue);
        } else {
            meetingQueue = new CityCouncilMeetingQueue();
        }

        votingFunction = new VotingFunction();
        governanceAdmin = _governanceAdmin;
        isCouncilMember[_governanceAdmin] = true;
        councilMembers.push(_governanceAdmin);
        councilMemberCount++;
    }

    // --- Functions ---

    function addCouncilMember(address _member) public onlyGovernanceAdmin {
        require(!isCouncilMember[_member], "Already a council member");
        isCouncilMember[_member] = true;
        councilMembers.push(_member);
        councilMemberCount++;
    }

    function removeCouncilMember(address _member) public onlyGovernanceAdmin {
        require(_member != governanceAdmin, "Cannot remove the governance admin.");
        require(isCouncilMember[_member], "Not a council member");
        
        isCouncilMember[_member] = false;
        councilMemberCount--;
        
        for (uint i = 0; i < councilMembers.length; i++) {
            if (councilMembers[i] == _member) {
                councilMembers[i] = councilMembers[councilMembers.length - 1];
                councilMembers.pop();
                break;
            }
        }
    }

    function getCouncilMemberCount() public view returns (uint256) {
        return councilMemberCount;
    }

    function getCouncilMembers() public view returns (address[] memory) {
        return councilMembers;
    }

    // --- Proxy Functions to Expose CityCouncilMeetingQueue Methods ---
    function scheduleMeeting(uint256 _scheduledTime) public onlyGovernanceAdmin {
        meetingQueue.scheduleMeeting(_scheduledTime);
    }

    function setMeetingInactive(uint256 _meetingId) public onlyGovernanceAdmin {
        meetingQueue.setMeetingInactive(_meetingId);
    }

    function getMeetingDetails(uint256 _meetingId) public view returns (CityCouncilMeetingQueue.Meeting memory) {
        return meetingQueue.getMeetingDetails(_meetingId);
    }

    function addObjectiveToQueue(uint256 _meetingId, uint256 _objectiveId) public onlyGovernanceAdmin {
        meetingQueue.addObjectiveToQueue(_meetingId, _objectiveId);
    }

    function removeObjectiveFromQueue(uint256 _meetingId, uint256 _objectiveId) public onlyGovernanceAdmin {
        meetingQueue.removeObjectiveFromQueue(_meetingId, _objectiveId);
    }

    function getMeetingQueue(uint256 _meetingId) public view returns (uint256[] memory) {
        return meetingQueue.getMeetingQueue(_meetingId);
    }

    function proposeObjective(string memory _title, string memory _description) public onlyCouncilMember {
        meetingQueue.proposeObjective(_title, _description, msg.sender);
    }

    function setObjectiveInactive(uint256 _objectiveId) public onlyCouncilMember {
        meetingQueue.setObjectiveInactive(_objectiveId, msg.sender);
    }

    function getObjectiveDetails(uint256 _objectiveId) public view returns (CityCouncilMeetingQueue.PoliticalObjective memory) {
        return meetingQueue.getObjectiveDetails(_objectiveId);
    }

    // --- Proxy Functions to Expose VotingFunction Methods ---
    function startVoting(uint256 _objectiveId) public onlyCouncilMember {
        require(meetingQueue.isObjectiveActive(_objectiveId), "Objective is not active.");
        votingFunction.startVoting(_objectiveId);
    }

    function castVote(uint256 _objectiveId, VotingFunction.Vote _vote) public onlyCouncilMember {
        votingFunction.castVote(_objectiveId, _vote, msg.sender);
    }

    function endVoting(uint256 _objectiveId) public onlyCouncilMember {
        votingFunction.endVoting(_objectiveId, getCouncilMemberCount());
    }

    function setVotingDuration(uint256 _duration) public onlyGovernanceAdmin {
        votingFunction.setVotingDuration(_duration);
    }

    // --- Voting Getter Functions ---
    function getVotingDetails(uint256 _objectiveId) public view returns (VotingFunction.VotingDetails memory) {
        return votingFunction.getVotingDetails(_objectiveId);
    }

    function getVote(uint256 _objectiveId, address _voter) public view returns (VotingFunction.Vote) {
        return votingFunction.getVote(_objectiveId, _voter);
    }

    function getVotingDuration(uint256 _objectiveId) public view returns (VotingFunction.VotingDurationDetails memory) {
        return votingFunction.getVotingDuration(_objectiveId);
    }
}