# Insurance dApp Documentation

## Smart Contracts

### Insurance.sol
Main contract for policy management.

*Key Functions:*
- createPolicy(bytes32 policyId): Creates a new insurance policy
- payPremium(bytes32 policyId): Pays premium for existing policy
- ...

### ClaimVerification.sol
Handles verification of insurance claims.

*Key Functions:*
- submitClaim(bytes32 policyId, uint256 amount): Submits a new claim
- ...

## Frontend Components

### InsuranceContext
Provides global state management for the application.

*Key Methods:*
- createPolicy(): Creates a new policy for the connected wallet
- payPremium(policyId): Pays premium for specified policy
- ...

## User Guide

1. *Connecting Your Wallet*
   - Click "Connect Wallet" in the top-right corner
   - Confirm the connection in your wallet extension

2. *Creating a Policy*
   - Navigate to the "Get Policy" section
   - Click "Create Policy"
   - Confirm the transaction in your wallet

...
