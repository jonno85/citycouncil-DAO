// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./CityCouncilMeetingQueue.sol";
import "forge-std/console.sol"; 

contract VotingFunction {

    enum Vote {
        ABSTAIN,
        YES,
        NO
    }

    struct VoteRecord {
        address voter;
        Vote vote;
    }

    struct Voting {
        uint256 objectiveId;
        uint256 startTime;
        uint256 endTime;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 abstainVotes;
        mapping(address => VoteRecord) votes;
        bool isCompleted;
        bool isPassed;
    }

    struct VotingDetails {
        uint256 objectiveId;
        uint256 startTime;
        uint256 endTime;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 abstainVotes;
        bool isCompleted;
        bool isPassed;
    }

    struct VotingDurationDetails {
        uint256 startTime;
        uint256 endTime;
        uint256 left;
        uint256 votingDuration;
    }

    // --- State Variables ---
    mapping(uint256 => Voting) public objectiveVotes;
    uint256 public votingDuration = 30 * 3600; // Default voting duration: 30 min

    // --- Events ---
    event VoteCast(uint256 objectiveId, address voter, Vote vote, uint256 timestamp);
    event VotingStarted(uint256 objectiveId, uint256 startTime, uint256 endTime);
    event VotingEnded(uint256 objectiveId, bool isPassed, uint256 yesVotes, uint256 noVotes, uint256 abstainVotes, uint256 endTime);


    // --- Modifiers ---
    modifier votingNotStarted(uint256 _objectiveId) {
        require(objectiveVotes[_objectiveId].startTime == 0, "Voting has already started for this objective.");
        _;
    }

    modifier votingInProgress(uint256 _objectiveId) {
        require(objectiveVotes[_objectiveId].startTime > 0 && !objectiveVotes[_objectiveId].isCompleted, "Voting is not currently in progress for this objective.");
        require(block.timestamp >= objectiveVotes[_objectiveId].startTime && block.timestamp <= objectiveVotes[_objectiveId].endTime, "Voting period has ended.");
        _;
    }

    modifier votingCompleted(uint256 _objectiveId) {
        require(objectiveVotes[_objectiveId].isCompleted, "Voting is not yet completed for this objective.");
        _;
    }

    // --- Constructor ---
    constructor() { }

    // --- Voting Management Functions ---
    function startVoting(uint256 _objectiveId)
        public
        votingNotStarted(_objectiveId)
    {
        objectiveVotes[_objectiveId].objectiveId = _objectiveId;
        objectiveVotes[_objectiveId].startTime = block.timestamp;
        objectiveVotes[_objectiveId].endTime = block.timestamp + votingDuration;
        emit VotingStarted(_objectiveId, objectiveVotes[_objectiveId].startTime, objectiveVotes[_objectiveId].endTime);
    }

    function castVote(uint256 _objectiveId, Vote _vote, address _voter)
        public
        votingInProgress(_objectiveId)
    {
        objectiveVotes[_objectiveId].votes[_voter] = VoteRecord({
            vote: _vote,
            voter: _voter
        });

        if (_vote == Vote.YES) {
            objectiveVotes[_objectiveId].yesVotes++;
        } else if (_vote == Vote.ABSTAIN) {
            objectiveVotes[_objectiveId].abstainVotes++;
        } else {
            objectiveVotes[_objectiveId].noVotes++;
        }

        emit VoteCast(_objectiveId, _voter, _vote, block.timestamp);
    }

    function endVoting(uint256 _objectiveId, uint256 _totalCouncilMembers)
        public
        votingInProgress(_objectiveId)
    {
        bool isPassed = objectiveVotes[_objectiveId].yesVotes > _totalCouncilMembers / 2;
        objectiveVotes[_objectiveId].isCompleted = true;
        objectiveVotes[_objectiveId].isPassed = isPassed;

        emit VotingEnded(_objectiveId, isPassed, objectiveVotes[_objectiveId].yesVotes, objectiveVotes[_objectiveId].noVotes, objectiveVotes[_objectiveId].abstainVotes, block.timestamp);
    }

    // --- Configuration ---
    function setVotingDuration(uint256 _duration) public {
        votingDuration = _duration;
    }

    // --- Getter Functions ---
    function getVotingDetails(uint256 _objectiveId) public view returns (VotingDetails memory) {
        Voting storage voting = objectiveVotes[_objectiveId];
        return VotingDetails({
            objectiveId: voting.objectiveId,
            startTime: voting.startTime,
            endTime: voting.endTime,
            yesVotes: voting.yesVotes,
            noVotes: voting.noVotes,
            abstainVotes: voting.abstainVotes,
            isCompleted: voting.isCompleted,
            isPassed: voting.isPassed
        });
    }

    function getVote(uint256 _objectiveId, address _voter) public view returns (Vote) {
        return objectiveVotes[_objectiveId].votes[_voter].vote;
    }

    function getVotingDuration(uint256 _objectiveId) public view returns (VotingDurationDetails memory) {
        return VotingDurationDetails({
            startTime: objectiveVotes[_objectiveId].startTime,
            endTime: objectiveVotes[_objectiveId].endTime,
            left: objectiveVotes[_objectiveId].endTime - objectiveVotes[_objectiveId].startTime,
            votingDuration: votingDuration
        });
    }
}