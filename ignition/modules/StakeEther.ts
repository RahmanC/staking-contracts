import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const rewardRatePerSecond = "100000000000000";

const StakeEtherModule = buildModule("StakeEtherModule", (m) => {
  const stakeEther = m.contract("StakeEther", [rewardRatePerSecond]);

  return { stakeEther };
});

export default StakeEtherModule;
