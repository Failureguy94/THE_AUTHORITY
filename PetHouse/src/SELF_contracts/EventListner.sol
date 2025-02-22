// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventListener {
    address public admin;

    struct Event {
        bytes32 eventId;
        bool verified;
    }

    mapping(bytes32 => Event) public events;

    event EventDetected(bytes32 indexed eventId);
    event EventVerified(bytes32 indexed eventId);
    event PayoutApproved(bytes32 indexed eventId, address indexed user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function detectEvent(bytes32 _eventID) external onlyAdmin {
        require(events[_eventID].eventId == 0, "Event already exists");
        events[_eventID] = Event(_eventID, false);
        emit EventDetected(_eventID);
    }

    function verifyEvent(bytes32 _eventID) external onlyAdmin {
        require(events[_eventID].eventId != 0, "Event not detected");
        require(!events[_eventID].verified, "Event already verified");
             
        // Manual verification logic
        bool approved = manualVerification();
        require(approved, "Event verification failed");

        events[_eventID].verified = true;
        emit EventVerified(_eventID);
    }

    function manualVerification() internal view returns (bool) {
        // Simulating token price check
        uint256 initialTokenPrice = 100; // Example: Assume initial price is 100 (mock data)
        uint256 currentTokenPrice = getCurrentTokenPrice(); // Fetch current price

        // Simulating liquidity check
        uint256 contractLiquidity = address(this).balance; // Check contract's liquidity

        // Condition 1: If token price drops by 20% or more, approve the event
        if (currentTokenPrice <= (initialTokenPrice * 80) / 100) {
            return true;
        }

        // Condition 2: If liquidity is below a threshold, approve the event
        if (contractLiquidity < 10 ether) { // Example threshold
            return true;
        }

        return false; // Default case: event not verified
    }

    // Mock function to simulate token price retrieval (Replace this with actual on-chain oracle)
    function getCurrentTokenPrice() internal pure returns (uint256) {
        return 75; // Assume the price dropped to 75 (just for example)
    }

    function approvePayout(bytes32 _eventID, address user, uint256 amount) external onlyAdmin {
        require(events[_eventID].verified, "Event not verified");
        require(amount > 0, "Invalid amount");

        emit PayoutApproved(_eventID, user, amount);
    }

    function isEventVerified(bytes32 _eventID) external view returns (bool) {
        return events[_eventID].verified;
    }
}