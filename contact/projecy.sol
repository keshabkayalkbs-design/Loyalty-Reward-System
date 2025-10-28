// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import security and interface contracts
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title LoyaltyProgram
 * @dev Manages the rules for earning and redeeming loyalty tokens
 * This contract should be the OWNER of the LoyaltyToken contract
 * to have minting privileges
 */
contract LoyaltyProgram is Ownable, Pausable {

   
    // The ERC20 loyalty token contract
    IERC20 public loyaltyToken;

    // Rate of reward: e.g., 10 points per $1 spent
    // (Assuming currency and points share the same decimals)
    uint256 public rewardRate;

    // Mapping of authorized merchant addresses.
    mapping(address => bool) public merchants;

    // Definition of a redeemable reward
    struct RewardItem {
        string name;        // "10% Off Coupon"
        uint256 cost;       // How many tokens it costs
        uint256 stock;      // How many are available (0 for unlimited)
        bool available;     // Whether the reward is currently active
    }

    // Mapping from a reward ID to the reward details
    mapping(bytes32 => RewardItem) public rewardCatalogue;

    // --- Events ---

    event RewardIssued(address indexed customer, uint256 amount, address indexed merchant);
    event RewardRedeemed(address indexed customer, bytes32 indexed rewardId, uint256 cost);
    event RewardAdded(bytes32 indexed rewardId, string name, uint256 cost, uint256 stock);
    event MerchantStatusChanged(address indexed merchant, bool isAuthorized);
    
    // --- Modifiers ---

    /**
     * @dev Modifier to allow only authorized merchants to call a function.
     */
    modifier onlyMerchant() {
        require(merchants[msg.sender], "LoyaltyProgram: Caller is not an authorized merchant");
        _;
    }

    // --- Constructor ---

    /**
     * @dev Initializes the contract with the token address and reward rate.
     * @param _tokenAddress The address of the deployed LoyaltyToken contract.
     * @param _initialRate The number of points to award per unit of currency.
     */
    constructor(address _tokenAddress, uint256 _initialRate) {
        loyaltyToken = IERC20(_tokenAddress);
        rewardRate = _initialRate;
    }

    // --- Admin Functions (Owner Only) ---

    /**
     * @dev Adds or removes a merchant from the authorized list.
     */
    function setMerchant(address _merchantAddress, bool _isAuthorized) public onlyOwner {
        merchants[_merchantAddress] = _isAuthorized;
        emit MerchantStatusChanged(_merchantAddress, _isAuthorized);
    }

    /**
     * @dev Updates the reward rate.
     */
    function setRewardRate(uint256 _newRate) public onlyOwner {
        rewardRate = _newRate;
    }

    /**
     * @dev Toggles the paused state of the contract (for emergencies).
     */
    function togglePause() public onlyOwner {
        if (paused()) {
            _unpause();
        } else {
            _pause();
        }
    }

    /**
     * @dev Adds a new item to the reward catalogue.
     */
    function addReward(bytes32 _rewardId, string memory _name, uint256 _cost, uint256 _stock) public onlyOwner {
        require(_cost > 0, "LoyaltyProgram: Cost must be greater than 0");
        rewardCatalogue[_rewardId] = RewardItem(_name, _cost, _stock, true);
        emit RewardAdded(_rewardId, _name, _cost, _stock);
    }
    
    /**
     * @dev Updates the availability of an existing reward.
     */
    function setRewardAvailability(bytes32 _rewardId, bool _available) public onlyOwner {
        require(rewardCatalogue[_rewardId].cost > 0, "LoyaltyProgram: Reward does not exist");
        rewardCatalogue[_rewardId].available = _available;
    }

    // --- Merchant Functions ---

    /**
     * @dev Called by a merchant to issue rewards to a customer.
     * @param _customer The address of the customer receiving points.
     * @param _purchaseAmount The value of the customer's purchase.
     */
    function issueRewards(address _customer, uint256 _purchaseAmount) 
        public 
        onlyMerchant 
        whenNotPaused 
    {
        require(_customer != address(0), "LoyaltyProgram: Cannot issue to zero address");
        uint256 rewardAmount = _purchaseAmount * rewardRate;
        
        // This fails if this contract is not the owner of the token contract
        // Dynamic cast to the LoyaltyToken interface to call mint
        LoyaltyToken(address(loyaltyToken)).mint(_customer, rewardAmount);

        emit RewardIssued(_customer, rewardAmount, msg.sender);
    }

    // --- User Functions ---

    /**
     * @dev Called by a customer to redeem a reward.
     * The customer MUST have first called `approve()` on the LoyaltyToken
     * contract, approving this contract to spend their tokens.
     * @param _rewardId The ID of the reward to redeem.
     */
    function redeemReward(bytes32 _rewardId) public whenNotPaused {
        RewardItem storage reward = rewardCatalogue[_rewardId];

        // Check if reward is valid and available
        require(reward.cost > 0, "LoyaltyProgram: Reward does not exist");
        require(reward.available, "LoyaltyProgram: Reward is not available");
        
        // Check stock (0 means unlimited)
        if (reward.stock != 0) {
            require(reward.stock > 0, "LoyaltyProgram: Reward is out of stock");
            reward.stock--; // Decrement stock
        }

        // The user (msg.sender) must have approved this contract
        // to spend `reward.cost` tokens on their behalf.
        // This will transfer tokens from the user to this contract.
        bool success = loyaltyToken.transferFrom(msg.sender, address(this), reward.cost);
        require(success, "LoyaltyProgram: ERC20 transfer failed. Check allowance.");

        // Optional: You can choose to burn the collected tokens
        // LoyaltyToken(address(loyaltyToken)).burn(reward.cost); 
        // Or just keep them in this contract to be managed by the owner.

        emit RewardRedeemed(msg.sender, _rewardId, reward.cost);
    }

    // --- View Functions ---

    /**
     * @dev Gets the details for a specific reward.
     */
    function getRewardDetails(bytes32 _rewardId) 
        public 
        view 
        returns (string memory name, uint256 cost, uint256 stock, bool available) 
    {
        RewardItem storage reward = rewardCatalogue[_rewardId];
        return (reward.name, reward.cost, reward.stock, reward.available);
    }

    /**
     * @dev Gets the current token balance for any user.
     */
    function getUserBalance(address _user) public view returns (uint256) {
        return loyaltyToken.balanceOf(_user);
    }
}