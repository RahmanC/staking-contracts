// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakeERC20 is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    uint256 public rewardRatePerSecond;
    uint256 public totalStaked;

    struct StakeInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 lastStakedTime;
    }

    mapping(address => StakeInfo) public stakes;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(IERC20 _stakingToken, uint256 _rewardRatePerSecond) Ownable(msg.sender) {
        stakingToken = _stakingToken;
        rewardRatePerSecond = _rewardRatePerSecond;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 tokens");

        // Update the user's reward before changing the stake amount
        _updateReward(msg.sender);

        // Transfer staking tokens to the contract
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);

        // Update the user's staking balance
        stakes[msg.sender].amount += _amount;
        stakes[msg.sender].lastStakedTime = block.timestamp;

        totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external {
        require(_amount > 0, "Cannot unstake 0 tokens");
        require(stakes[msg.sender].amount >= _amount, "Insufficient staked balance");

        // Update the user's reward before changing the stake amount
        _updateReward(msg.sender);

        // Update the user's staking balance
        stakes[msg.sender].amount -= _amount;
        totalStaked -= _amount;

        // Transfer the tokens back to the user
        stakingToken.safeTransfer(msg.sender, _amount);

        emit Unstaked(msg.sender, _amount);
    }

    function claimReward() external {
        _updateReward(msg.sender);

        uint256 reward = stakes[msg.sender].rewardDebt;
        require(reward > 0, "No reward to claim");

        stakes[msg.sender].rewardDebt = 0;

        // Transfer the reward tokens to the user
        stakingToken.safeTransfer(msg.sender, reward);

        emit RewardClaimed(msg.sender, reward);
    }

    function _updateReward(address _user) internal {
        if (stakes[_user].amount > 0) {
            uint256 reward = _calculateReward(_user);
            stakes[_user].rewardDebt += reward;
        }
        stakes[_user].lastStakedTime = block.timestamp;
    }

    function _calculateReward(address _user) internal view returns (uint256) {
        StakeInfo storage stakeInfo = stakes[_user];
        uint256 stakingDuration = block.timestamp - stakeInfo.lastStakedTime;
        return stakingDuration * rewardRatePerSecond * stakeInfo.amount / 1e18;
    }

    // Admin functions to update reward rate or emergency withdraw
    function setRewardRate(uint256 _newRewardRate) external onlyOwner {
        rewardRatePerSecond = _newRewardRate;
    }

    function emergencyWithdraw() external onlyOwner {
        stakingToken.safeTransfer(owner(), stakingToken.balanceOf(address(this)));
    }
}
