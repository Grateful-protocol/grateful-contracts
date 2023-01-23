import { task } from "hardhat/config";

type TaskArgs = {
  proxy: string;
  profile: string;
  giverId: string;
  creatorId: string;
  vaultId: string;
  rate: string;
};

task("subscribe", "Subscribe to a creator")
  .addParam("proxy", "Proxy address of the system")
  .addParam("profile", "Profile address")
  .addParam("giverId", "Giver token ID from the profile")
  .addParam("creatorId", "Creator token ID from the profile")
  .addParam("vaultId", "Vault ID to deposit")
  .addParam("rate", "Subscription rate in wei per second")
  .setAction(async (taskArgs: TaskArgs, hre) => {
    console.log("Subscribing with:", taskArgs);

    // Get current signer
    const [signer] = await hre.ethers.getSigners();

    // Get contracts
    const subscriptionsModule = await hre.ethers.getContractAt(
      "SubscriptionsModule",
      taskArgs.proxy
    );

    // Subscription tx
    const tx = await subscriptionsModule
      .connect(signer)
      .subscribe(
        taskArgs.profile,
        taskArgs.giverId,
        taskArgs.profile,
        taskArgs.creatorId,
        taskArgs.vaultId,
        taskArgs.rate
      );

    await tx.wait();

    console.log("Subscription created");
  });
