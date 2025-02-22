// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EventListner.sol";

contract ClaimVerification {
    EventListener public eventListener;
    address public admin;
    struct Claim {
        bytes32 claimId;
        address claimant;
        uint256 amount;
        bool verified;
        bool paid;
    }

    mapping(bytes32 => Claim) public claims;

    event ClaimSubmitted(
        bytes32 indexed claimId,
        address indexed claimant,
        uint256 amount
    );
    event ClaimVerified(bytes32 indexed claimId);
    event ClaimPaid(
        bytes32 indexed claimId,
        address indexed claimant,
        uint256 amount
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(address _eventListener) {
        eventListener = EventListener(_eventListener);
        admin = msg.sender;
    }

    function submitClaim(bytes32 _claimId, uint256 _amount) external {
        require(claims[_claimId].claimId == 0, "Claim already exists");

        claims[_claimId] = Claim(_claimId, msg.sender, _amount, false, false);
        emit ClaimSubmitted(_claimId, msg.sender, _amount);
    }

    function verifyClaim(bytes32 _claimId) external onlyAdmin {
        require(claims[_claimId].claimId != 0, "Claim does not exist");
        require(!claims[_claimId].verified, "Claim already verified");

        require(
            eventListener.isEventVerified(_claimId),
            "Claim verification failed"
        );

        claims[_claimId].verified = true;
        emit ClaimVerified(_claimId);
    }

    function payClaim(
        bytes32 _claimId,
        address payoutManager
    ) external onlyAdmin {
        Claim storage claim = claims[_claimId];

        require(claim.verified, "Claim not verified");
        require(!claim.paid, "Claim already paid");

        PayoutManager(payoutManager).processPayout(
            claim.claimant,
            claim.amount
        );

        claim.paid = true;
        emit ClaimPaid(_claimId, claim.claimant, claim.amount);
    }
}

interface PayoutManager {
    function processPayout(address recipient, uint256 amount) external;
}
