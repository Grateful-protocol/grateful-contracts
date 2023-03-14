import { task } from "hardhat/config";

type TaskArgs = {
  proxy: string;
  giverId: string;
  creatorId: string;
  vaultId: string;
  rate: string;
};

task("subscribe", "Subscribe to a creator")
  .addParam("proxy", "Proxy address of the system")
  .addParam("giverId", "Giver profile ID")
  .addParam("creatorId", "Creator profile ID")
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

    // Set vault
    const vaultId = hre.ethers.utils.formatBytes32String(taskArgs.vaultId);

    // Subscription tx
    const tx = await subscriptionsModule
      .connect(signer)
      .subscribe(taskArgs.giverId, taskArgs.creatorId, vaultId, taskArgs.rate);

    await tx.wait();

    console.log("Subscription created");
  });
