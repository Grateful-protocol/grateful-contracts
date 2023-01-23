import { task } from "hardhat/config";

type TaskArgs = {
  proxy: string;
  profileId: string;
  vaultId: string;
};

task("getBalance", "Get balance info from a profile")
  .addParam("proxy", "Proxy address of the system")
  .addParam("profileId", "Profile ID to get balance from")
  .addParam("vaultId", "Vault ID to deposit")
  .setAction(async (taskArgs: TaskArgs, hre) => {
    console.log("Getting balance with:", taskArgs);

    const profileId = taskArgs.profileId;
    const vaultId = taskArgs.vaultId;

    // Get contracts
    const balancesModule = await hre.ethers.getContractAt(
      "BalancesModule",
      taskArgs.proxy
    );

    // Get balance info
    const balance = await balancesModule.balanceOf(profileId, vaultId);
    const flow = await balancesModule.getFlow(profileId, vaultId);
    const canBeLiquidated = await balancesModule.canBeLiquidated(
      profileId,
      vaultId
    );
    const remainingTime = await balancesModule.getRemainingTimeToZero(
      profileId,
      vaultId
    );

    // Log balance info
    console.log("BALANCE:", balance);
    console.log("FLOW:", flow);
    console.log("CAN BE LIQUIDATED:", canBeLiquidated);
    console.log("REMAINING TIME:", remainingTime);
  });
