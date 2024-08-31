import { ethers } from "hardhat";

async function main() {
  const stakeEtherContractAddress =
    "0x04F28aB6a55178CD05aD8b2c089679AA45Ee7F17";
  const stakeEther = await ethers.getContractAt(
    "StakeEther",
    stakeEtherContractAddress
  );

  // Stake Ether
  const stakeTx = await stakeEther.stake({
    value: ethers.parseUnits("0.001", "ether"),
  });
  await stakeTx.wait();
  console.log("Ether staked");

  // Claim rewards
  const claimTx = await stakeEther.claimReward();
  await claimTx.wait();
  console.log("Rewards claimed");

  // Unstake Ether (with reward withdrawal)
  const unstakeTx = await stakeEther.unstake();
  await unstakeTx.wait();
  console.log("Ether unstaked and rewards claimed");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
