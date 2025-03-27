// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IncidentRegistry {
    struct Incident {
        string photoHash;  // IPFS hash (Pinata)
        string latitude;
        string longitude;
        string description;
        uint256 timestamp;
    }

    mapping(uint256 => Incident) public incidents;
    uint256 public incidentCount;

    event IncidentAdded(uint256 indexed id, string photoHash, string latitude, string longitude, string description, uint256 timestamp);

    function addIncident(
        string memory _photoHash,
        string memory _latitude,
        string memory _longitude,
        string memory _description
    ) public {
        uint256 currentId = incidentCount++;
        incidents[currentId] = Incident(_photoHash, _latitude, _longitude, _description, block.timestamp);
        emit IncidentAdded(currentId, _photoHash, _latitude, _longitude, _description, block.timestamp);
    }

    function getIncident(uint256 _id) public view returns (Incident memory) {
        require(_id < incidentCount, "Incident does not exist.");
        return incidents[_id];
    }
}
