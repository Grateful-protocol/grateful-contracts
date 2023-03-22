import { task } from "hardhat/config";

type TaskArgs = {
  proxy: string;
  giverId: string;
  creatorId: string;
};

task("unsubscribe", "Unsubscribe from a creator")
  .addParam("proxy", "Proxy address of the system")
  .addParam("giverId", "Giver profile ID")
  .addParam("creatorId", "Creator profile ID")
  .setAction(async (taskArgs: TaskArgs, hre) => {
    console.log("Unsubscribing with:", taskArgs);

    // Get current signer
    const [signer] = await hre.ethers.getSigners();

    // Get contracts
    const subscriptionsModule = await hre.ethers.getContractAt(
      "SubscriptionsModule",
      taskArgs.proxy
    );

    // Unsubscription tx
    const tx = await subscriptionsModule
      .connect(signer)
      .unsubscribe(taskArgs.giverId, taskArgs.creatorId);

    await tx.wait();

    console.log("Unsubscription successful");
  });
