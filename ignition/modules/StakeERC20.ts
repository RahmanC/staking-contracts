import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const stakingTokenAddress = "0xB92190Bb5E420d210bEdE03C90A7866530B97aED";
const rewardRatePerSecond = "100000000000000";

const StakeERC20Module = buildModule("StakeERC20Module", (m) => {
  const stakeERC20 = m.contract("StakeERC20", [
    stakingTokenAddress,
    rewardRatePerSecond,
  ]);

  return { stakeERC20 };
});

export default StakeERC20Module;
