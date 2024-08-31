// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

interface IStakeERC20 {
    function stake(uint256 _amount) external;

    function unstake(uint256 _amount) external;

}