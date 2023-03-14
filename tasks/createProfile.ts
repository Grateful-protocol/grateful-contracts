import { task } from "hardhat/config";

type TaskArgs = {
  proxy: string;
  address: string;
};

task("createProfile", "Create a Grateful profile")
  .addParam("proxy", "Proxy address of the system")
  .addParam("address", "Profile NFT receiver")
  .setAction(async (taskArgs: TaskArgs, hre) => {
    console.log("Creating profile with:", taskArgs);

    // Get current signer
    const [signer] = await hre.ethers.getSigners();

    // Get contracts
    const profilesModule = await hre.ethers.getContractAt(
      "ProfilesModule",
      taskArgs.proxy
    );

    // Create profile tx
    const tx = await profilesModule
      .connect(signer)
      .createProfile(taskArgs.address);

    await tx.wait();

    console.log("Profile created");
  });
