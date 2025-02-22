// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EventListner.sol";
import "./PayoutManager.sol";
import "./ClaimVerification.sol";
contract ReactiveContractConnector {
    event EventProcessed(
        uint256 indexed chainId,
        address indexed contractAddress,
        uint256 indexed topic0,
        uint256 topic1,
        uint256 topic2,
        uint256 topic3,
        bytes data
    );

    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint64 private constant GAS_LIMIT = 1000000;

    address private _callback;
    address private claimVerifier;
    address private payoutHandler;
    address private eventTracker;

    constructor(
        address _claimVerifier,
        address _payoutHandler,
        address _eventTracker,
        address callback
    ) payable {
        claimVerifier = _claimVerifier;
        payoutHandler = _payoutHandler;
        eventTracker = _eventTracker;
        _callback = callback;
    }

    function react(
        uint256 chain_id,
        address _contract,
        uint256 topic_0,
        uint256 topic_1,
        uint256 topic_2,
        uint256 topic_3,
        bytes calldata data
    ) external {
        emit EventProcessed(
            chain_id,
            _contract,
            topic_0,
            topic_1,
            topic_2,
            topic_3,
            data
        );

        bytes32 eventId = keccak256(
            abi.encodePacked(topic_0, topic_1, topic_2, topic_3)
        );

        // Ensure event is verified before processing
        if (!EventListener(eventTracker).isEventVerified(eventId)) {
            EventListener(eventTracker).verifyEvent(eventId);
        }

        // If condition met, verify the claim
        if (topic_3 >= 0.01 ether) {
            ClaimVerification(claimVerifier).verifyClaim(eventId);
        }
    }

    function triggerPayout(
        bytes32 claimId,
        address claimant,
        uint256 amount
    ) external {
        require(
            EventListener(eventTracker).isEventVerified(claimId),
            "Event not verified for payout"
        );
        PayoutManager(payoutHandler).processPayout(claimant, amount);
    }
}
