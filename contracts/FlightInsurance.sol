// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FlightInsurance {
    struct Insurance {
        address payable user;
        uint256 amount;
        string flightId;
        bool isClaimed;
    }

    mapping(bytes32 => Insurance) public insurances;
    address public owner;

    event InsurancePurchased(address indexed user, string flightId, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function purchaseInsurance(string memory flightId) public payable {
        require(msg.value > 0, "Insurance amount must be greater than 0");

        bytes32 insuranceId = keccak256(
            abi.encodePacked(msg.sender, flightId, block.timestamp)
        );

        require(insurances[insuranceId].user == address(0), "Insurance already exists");

        insurances[insuranceId] = Insurance({
            user: payable(msg.sender),
            amount: msg.value,
            flightId: flightId,
            isClaimed: false
        });

        emit InsurancePurchased(msg.sender, flightId, msg.value);
    }

    function getInsurance(bytes32 insuranceId) public view returns (Insurance memory) {
        Insurance memory insurance = insurances[insuranceId];
        require(insurance.user != address(0), "Insurance not found");
        return insurance;
    }

    function withdrawFunds(uint256 amount) public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        require(address(this).balance >= amount, "Insufficient funds");
        payable(owner).transfer(amount);
    }
}
