# StackCred Clarity Smart Contract

## Overview
StackCred is a Clarity smart contract for the Stacks blockchain that manages decentralized credit scores for users. It tracks and updates credit scores based on multiple factors, including repayment, staking, NFT activity, and DAO participation. The contract is designed for use in decentralized finance (DeFi) and reputation systems.

## Features
- **Credit Score Tracking:** Maintains a credit score for each user as a tuple of multiple factors.
- **Configurable Weights:** Admin can set weights for each credit score factor.
- **Score Updates:** Only the admin can update user scores.
- **NFT and DAO Integration:** Tracks NFT and DAO participation as part of the score.
- **Admin Controls:** Only the admin can update scores, set new admin, or delete user data.

## Data Structures
- **Credit Score:**
  ```clarity
  (tuple (repayment uint) (staking uint) (nft uint) (dao uint) (total uint) (last-updated uint))
  ```
- **Config:**
  ```clarity
  (tuple (repayment-weight uint) (staking-weight uint) (nft-weight uint) (dao-weight uint))
  ```

## Key Functions
- `update-score`: Admin updates a user's credit score.
- `set-admin`: Admin can transfer admin rights.
- `delete-user-data`: Admin can delete a user's credit score and NFT data.

## Usage
1. **Deploy the contract** to the Stacks blockchain using Clarinet or the Stacks CLI.
2. **Set the admin** (default is the deployer).
3. **Admin updates scores** using the `update-score` function.
4. **Query scores** using read-only functions (to be implemented as needed).

## Development
- Contract source: `contracts/stackcred.clar`
- Tests: `tests/stackcred.test.ts`
- Configuration: `Clarinet.toml`, `settings/`


