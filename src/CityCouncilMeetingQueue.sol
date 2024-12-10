// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./PoliticalObjectiveFunction.sol";

contract CityCouncilMeetingQueue is PoliticalObjectiveFunction {

  // --- Data Structures ---
  struct Meeting {
    uint256 id;
    uint256 creationTimestamp;
    uint256 scheduledTime;
    bool isActive;
    address[] attendees;
    uint256[] objectiveQueue;
  }

  // --- State Variables ---
  mapping(uint256 => Meeting) public meetings;
  uint256 public nextMeetingId = 1;
  uint256 public nextQueueItemId = 1;
  mapping(uint256 => uint256) public meetingObjectiveQueue;

  // --- Events ---
  event MeetingScheduled (
    uint256 meetingId,
    uint256 scheduledTime,
    address scheduler,
    uint256 timestamp
  );

  event ObjectiveRemovedToQueue (
    uint256 meetingId,
    uint256 objectiveId,
    address scheduler,
    uint256 timestamp
  );

  event ObjectiveAddedToQueue (
    uint256 meetingId,
    uint256 objectiveId,
    address scheduler,
    uint256 timestamp
  );

  event MeetingSetInactive(uint256 meetingId, address setter, uint256 timestamp);

  // --- Modifiers ---
  modifier meetingExists(uint256 _meetingId) {
      require(meetings[_meetingId].id == _meetingId, "Meeting ID does not exist.");
      _;
  }

  modifier objectiveIsActive(uint256 _objectiveId) {
      require(politicalObjectives[_objectiveId].isActive, "Objective is not active.");
      _;
  }

  modifier objectiveNotInQueue(uint256 _meetingId, uint256 _objectiveId) {
      for (uint256 i = 0; i < meetings[_meetingId].objectiveQueue.length; i++) {
          require(meetings[_meetingId].objectiveQueue[i] != _objectiveId, "Objective is already in the queue for this meeting.");
      }
      _;
  }

  modifier objectiveInQueue(uint256 _meetingId, uint256 _objectiveId) {
      bool found = false;
      for (uint256 i = 0; i < meetings[_meetingId].objectiveQueue.length; i++) {
          if (meetings[_meetingId].objectiveQueue[i] == _objectiveId) {
              found = true;
              break;
          }
      }
      require(found, "Objective is not in the queue for this meeting.");
      _;
  }

  // --- Constructor ---
  constructor() PoliticalObjectiveFunction() {}

  // --- Functions ---
  function scheduleMeeting(uint256 _scheduledTime) public {
    uint256 meetingId = nextMeetingId++;
    meetings[meetingId] = Meeting({
      id: meetingId,
      creationTimestamp: block.timestamp,
      scheduledTime: _scheduledTime,
      isActive: true,
      attendees: new address[](0),
      objectiveQueue: new uint256[](0)
    });
    emit MeetingScheduled(meetingId, _scheduledTime, msg.sender, block.timestamp);
  }

  function setMeetingInactive(uint256 _meetingId) public meetingExists(_meetingId) {
    require(meetings[_meetingId].isActive, "Meeting is already inactive.");
    meetings[_meetingId].isActive = false;
    emit MeetingSetInactive(_meetingId, msg.sender, block.timestamp);
  }

  function getMeetingDetails(uint256 _meetingId) public view meetingExists(_meetingId) returns (Meeting memory) {
    return meetings[_meetingId];
  }

  // --- Queue Management Functions ---
  function addObjectiveToQueue(uint256 _meetingId, uint256 _objectiveId) public meetingExists(_meetingId) objectiveIsActive(_objectiveId) objectiveNotInQueue(_meetingId, _objectiveId) {
    meetings[_meetingId].objectiveQueue.push(_objectiveId);
    emit ObjectiveAddedToQueue(_meetingId, _objectiveId, msg.sender, block.timestamp);
  }

  function removeObjectiveFromQueue(uint256 _meetingId, uint256 _objectiveId) public meetingExists(_meetingId) objectiveInQueue(_meetingId, _objectiveId) {
    uint256[] storage queue = meetings[_meetingId].objectiveQueue;
    for (uint256 i = 0; i < queue.length; i++) {
      if (queue[i] == _objectiveId) {
        queue[i] = queue[queue.length - 1];
        queue.pop();
        emit ObjectiveAddedToQueue(_meetingId, _objectiveId, msg.sender, block.timestamp);
        break;
      }
    }
    // Should not reach here due to the objectiveInQueue modifier, but for safety:
    revert("Objective not found in queue (internal error).");
  }

  function getMeetingQueue(uint256 _meetingId) public view meetingExists(_meetingId) returns (uint256[] memory) {
    return meetings[_meetingId].objectiveQueue;
  }
}