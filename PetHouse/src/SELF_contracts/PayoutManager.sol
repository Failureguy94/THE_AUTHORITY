// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EventListner.sol";

contract PayoutManager {
    EventListener public eventListener;
    address public admin;

    event PayoutProcessed(address indexed recipient, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(address _eventListener) {
        eventListener = EventListener(_eventListener);
        admin = msg.sender;
    }

    function processPayout(address recipient, uint256 amount) external onlyAdmin {
        require(
            eventListener.isEventVerified(keccak256(abi.encodePacked(recipient, amount))),
            "Payout not approved"
        );

        emit PayoutProcessed(recipient, amount);
    }
}