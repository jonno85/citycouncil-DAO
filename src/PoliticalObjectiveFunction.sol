// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract PoliticalObjectiveFunction {
    // --- Data Structures ---

    struct PoliticalObjective {
        uint256 id;
        string title;
        string description;
        address proposer;
        uint256 creationTimestamp;
        bool isActive;
    }

    // --- State Variables ---

    mapping(uint256 => PoliticalObjective) public politicalObjectives;
    uint256 public nextObjectiveId = 1;

    // --- Events ---

    event ObjectiveProposed(
        uint256 objectiveId,
        string title,
        address proposer,
        uint256 timestamp
    );

    event ObjectiveSetInactive(uint256 objectiveId, address setter, uint256 timestamp);

    // --- Constructor ---
    constructor() { }

    // --- Functions ---
    function proposeObjective(string memory _title, string memory _description, address _proposer) public {
        uint256 objectiveId = nextObjectiveId++;
        politicalObjectives[objectiveId] = PoliticalObjective({
            id: objectiveId,
            title: _title,
            description: _description,
            proposer: _proposer,
            creationTimestamp: block.timestamp,
            isActive: true
        });

        emit ObjectiveProposed(objectiveId, _title, _proposer, block.timestamp);
    }

    function setObjectiveInactive(uint256 _objectiveId, address _actor) public {
        require(politicalObjectives[_objectiveId].id == _objectiveId, "Objective ID does not exist.");
        require(politicalObjectives[_objectiveId].isActive, "Objective is already inactive.");
        politicalObjectives[_objectiveId].isActive = false;
        emit ObjectiveSetInactive(_objectiveId, _actor, block.timestamp);
    }

    function getObjectiveDetails(uint256 _objectiveId) public view returns (PoliticalObjective memory) {
        require(politicalObjectives[_objectiveId].id == _objectiveId, "Objective ID does not exist.");
        return politicalObjectives[_objectiveId];
    }

    function isObjectiveActive(uint256 _objectiveId) public view returns (bool) {
        return politicalObjectives[_objectiveId].isActive;
    }
}