// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract StakeEther is Ownable {
    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        uint256 rewardDebt;
    }

    uint256 public rewardRatePerSecond;
    uint256 public totalStaked;
    uint256 public constant MINIMUM_STAKING_TIME = 1 weeks; 

    mapping(address => StakeInfo) public stakes;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(uint256 _rewardRatePerSecond) Ownable(msg.sender) {
        rewardRatePerSecond = _rewardRatePerSecond;
    }

    // Function to stake Ether
    function stake() external payable {
        require(msg.value > 0, "Cannot stake 0 Ether");

        _updateReward(msg.sender);

        stakes[msg.sender].amount += msg.value;
        stakes[msg.sender].startTime = block.timestamp;
        totalStaked += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    // Function to unstake Ether and claim rewards
    function unstake() external {
        require(stakes[msg.sender].amount > 0, "No Ether staked");
        require(
            block.timestamp >= stakes[msg.sender].startTime + MINIMUM_STAKING_TIME,
            "Staking period not yet completed"
        );

        _updateReward(msg.sender);

        uint256 amount = stakes[msg.sender].amount;
        uint256 reward = stakes[msg.sender].rewardDebt;

        stakes[msg.sender].amount = 0;
        stakes[msg.sender].rewardDebt = 0;
        totalStaked -= amount;

        payable(msg.sender).transfer(amount + reward);

        emit Unstaked(msg.sender, amount);
        emit RewardClaimed(msg.sender, reward);
    }

    // Function to claim rewards without unstaking
    function claimReward() external {
        require(
            block.timestamp >= stakes[msg.sender].startTime + MINIMUM_STAKING_TIME,
            "Staking period not yet completed"
        );

        _updateReward(msg.sender);

        uint256 reward = stakes[msg.sender].rewardDebt;
        require(reward > 0, "No rewards to claim");

        stakes[msg.sender].rewardDebt = 0;

        payable(msg.sender).transfer(reward);

        emit RewardClaimed(msg.sender, reward);
    }

    // Function to update reward for a user
    function _updateReward(address _user) internal {
        if (stakes[_user].amount > 0) {
            uint256 reward = _calculateReward(_user);
            stakes[_user].rewardDebt += reward;
        }
        stakes[_user].startTime = block.timestamp;
    }

    // Function to calculate reward
    function _calculateReward(address _user) internal view returns (uint256) {
        StakeInfo storage stakeInfo = stakes[_user];
        uint256 stakingDuration = block.timestamp - stakeInfo.startTime;
        return (stakingDuration * rewardRatePerSecond * stakeInfo.amount) / 1e18;
    }

    // Admin function to update the reward rate
    function setRewardRate(uint256 _newRewardRate) external onlyOwner {
        rewardRatePerSecond = _newRewardRate;
    }

    // Admin function to withdraw contract balance
    function emergencyWithdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Fallback function to accept Ether
    receive() external payable {}
}
