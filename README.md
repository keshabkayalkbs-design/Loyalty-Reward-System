# Blockchain Loyalty Rewards Program

## Project Description

The Blockchain Loyalty Rewards Program is a decentralized application designed to replace traditional loyalty systems. It uses two main smart contracts: a `LoyaltyToken` (ERC20) to represent points, and a `LoyaltyProgram` contract to manage the rules. This system allows authorized merchants to issue tokens to customers, and for customers to redeem those tokens for rewards in a transparent and secure way.

## Project Vision

To empower businesses with a flexible and secure loyalty solution, and to provide customers with true ownership of their rewards. The vision is to create an open and interoperable loyalty ecosystem where points from different merchants can be managed from a single wallet.

## Key Features

* **Admin Control:** The contract owner can add or remove authorized merchants and pause the contract in emergencies.
* **Reward Catalogue:** The owner can add, update, and manage a list of redeemable rewards (e.g., "10% Off Coupon") with specific token costs and stock levels.
* **Merchant Issuance:** Authorized merchants can issue (mint) loyalty tokens to customers based on their purchases.
* **Customer Redemption:** Customers can redeem their earned tokens for items in the reward catalogue. This requires a token `approve` and then a call to `redeemReward`.
* **Transparent Balances:** Any user can check their loyalty token balance at any time.

## Future Scope

* Build a frontend dashboard for Admins, Merchants, and Customers to easily interact with the contract.
* Implement automatic token burning upon redemption to create a deflationary model.
* Create different merchant "tiers" with different reward rates.
* Introduce "time-locked" rewards or special promotions.
* Integrate with other DeFi protocols to allow points to be swapped or staked.

## Setup & Deployment

1.  Clone this repository:
    ```sh
    git clone <your-repo-link>
    cd blockchain-loyalty-program
    ```
2.  Deploy the `LoyaltyToken` contract first.
3.  Deploy the `LoyaltyProgram` contract, passing the `LoyaltyToken`'s address and an initial reward rate to the constructor.
4.  **Crucial:** Transfer ownership of the `LoyaltyToken` contract to the deployed `LoyaltyProgram` contract. This is required to give the `LoyaltyProgram` contract permission to mint new tokens.

## Deployment Details

**Network:** `Core Testnet`

**Deployed Contract Address:** `0x27c3E3dfB0843414c36f30649641868e11FD3151`

**Verification:** `Verified on Sourcify`

**Deployed Using:** `Remix IDE (Injected Provider - MetaMask)`

<img width="1896" height="858" alt="Screenshot 2025-11-04 032936" src="https://github.com/user-attachments/assets/e6c1a8a8-1069-4ab9-9837-559dffc3b2bd" />
