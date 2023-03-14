import { task } from "hardhat/config";

type TaskArgs = {
  proxy: string;
  profileId: string;
  vault: string;
  vaultId: string;
  amount: string;
};

task("deposit", "Deposit into grateful")
  .addParam("proxy", "Proxy address of the system")
  .addParam("profileId", "Profile ID")
  .addParam("vault", "Vault to deposit")
  .addParam("vaultId", "Vault ID to deposit")
  .addParam("amount", "Amount to deposit")
  .setAction(async (taskArgs: TaskArgs, hre) => {
    console.log("Depositing with:", taskArgs);

    // Get current signer
    const [signer] = await hre.ethers.getSigners();

    // Get contracts
    const vault = await hre.ethers.getContractAt("AaveV2Vault", taskArgs.vault);
    const fundsModule = await hre.ethers.getContractAt(
      "FundsModule",
      taskArgs.proxy
    );

    // Set token data
    const tokenAddress = await vault.asset();
    const token = await hre.ethers.getContractAt("ERC20", tokenAddress);
    const decimals = await token.decimals();

    const depositAmount = hre.ethers.utils.parseUnits(
      taskArgs.amount,
      decimals
    );

    // Approve token to grateful contract
    await token.connect(signer).approve(fundsModule.address, depositAmount);

    // Deposit tx
    const tx = await fundsModule
      .connect(signer)
      .depositFunds(taskArgs.profileId, taskArgs.vaultId, depositAmount);

    await tx.wait();

    console.log("Funds deposited");
  });
