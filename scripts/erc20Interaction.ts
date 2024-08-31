import { ethers } from "hardhat";

async function main() {
  const stakingTokenAddress = "0xB92190Bb5E420d210bEdE03C90A7866530B97aED";
  const stakeERC20ContractAddress =
    "0xCbB0737A5817AfD7E9586Cd0f0A4A1AC7C55f058";

  const stakingToken = await ethers.getContractAt(
    "IERC20",
    stakingTokenAddress
  );
  const stakeERC20 = await ethers.getContractAt(
    "StakeERC20",
    stakeERC20ContractAddress
  );

  // Approve the staking contract to spend the tokens
  const approvalAmount = ethers.parseUnits("1000", 18);
  const approveTx = await stakingToken.approve(
    stakeERC20ContractAddress,
    approvalAmount
  );
  await approveTx.wait();

  // Stake tokens
  const stakeAmount = ethers.parseUnits("150", 18);
  const stakeTx = await stakeERC20.stake(stakeAmount);
  await stakeTx.wait();
  console.log("Tokens staked:", stakeAmount.toString());

  // Claim rewards
  const claimTx = await stakeERC20.claimReward();
  await claimTx.wait();
  console.log("Rewards claimed");

  // Unstake tokens
  const unstakeAmount = ethers.parseUnits("100", 18);
  const unstakeTx = await stakeERC20.unstake(unstakeAmount);
  await unstakeTx.wait();
  console.log("Tokens unstaked:", unstakeAmount.toString());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
