// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Insurance {
    address public admin;
    uint256 public premiumPerMonth;

    struct Policy {
        address policyHolder;
        uint256 startTime;
        bool isActive;
        uint256 totalPaid;
    }

    mapping(bytes32 => Policy) public policies;
    event PolicyCreated(bytes32 indexed policyId, address indexed policyHolder);
    event PremiumPaid(bytes32 indexed policyId, uint256 amount);
    event PolicyExpired(bytes32 indexed policyId);
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(uint256 _premiumPerMonth) {
        admin = msg.sender;
        premiumPerMonth = _premiumPerMonth;
    }

    function createPolicy(bytes32 _policyId) external {
        require(
            policies[_policyId].policyHolder == address(0),
            "Policy already exists"
        );

        policies[_policyId] = Policy(msg.sender, block.timestamp, true, 0);
        emit PolicyCreated(_policyId, msg.sender);
    }

    function payPremium(bytes32 _policyId) external payable {
        Policy storage policy = policies[_policyId];
        require(policy.isActive, "Policy is inactive");
        require(policy.policyHolder == msg.sender, "Not policy owner");

        uint256 elapsedMonths = (block.timestamp - policy.startTime) / 30 days;
        uint256 dueAmount = elapsedMonths * premiumPerMonth;
        require(msg.value >= dueAmount, "Insufficient payment");

        policy.totalPaid += msg.value;

        // Check if policy expired
        if (elapsedMonths > 3) {
            policy.isActive = false;
            emit PolicyExpired(_policyId);
        } else {
            
            emit PremiumPaid(_policyId, msg.value);
        }
    }
}