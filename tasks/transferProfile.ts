import { task } from "hardhat/config";

type TaskArgs = {
  profile: string;
  from: string;
  to: string;
  tokenId: string;
};

task("transferProfile", "Transfer a Grateful profile")
  .addParam("profile", "Proxy address of the profile")
  .addParam("from", "Address who transfers")
  .addParam("to", "Address who receives")
  .addParam("tokenId", "Profile NFT token ID to transfer")
  .setAction(async (taskArgs: TaskArgs, hre) => {
    console.log("Transfering profile with:", taskArgs);

    // Get current signer
    const [signer] = await hre.ethers.getSigners();

    // Get contracts
    const profile = await hre.ethers.getContractAt("ERC721", taskArgs.profile);

    // Create profile tx
    const tx = await profile
      .connect(signer)
      .transferFrom(taskArgs.from, taskArgs.to, taskArgs.tokenId);

    await tx.wait();

    console.log("Profile transfered");
  });
