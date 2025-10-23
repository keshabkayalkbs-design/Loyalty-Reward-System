// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract LoyaltyProgram is Ownable {

    address public loyaltyTokenAddress;
    

    uint256 public rewardRate; 
    bool public isPaused = false; 

    mapping(address => bool) public merchants; 

    struct RewardItem {
        string name;
        uint256 cost;
        uint256 stock;
        bool available;
    }

    
}