import { ChainBuilderRuntime } from "@usecannon/builder/dist/src/types";
import { ethers } from "hardhat";
import { AaveV2Vault__factory } from "../typechain-types";

const abi = require("../abi/contracts/vaults/AaveV2Vault.sol/Aavev2Vault.json");
const hre = require("hardhat");

const initializeAaveV2Vault = async (
  runtime: ChainBuilderRuntime,
  proxy: string,
  vaultId: string,
  asset: string,
  aToken: string,
  aaveMining: string,
  lendingPool: string,
  owner: string,
  minRate: number,
  maxRate: number
) => {
  if (runtime?.provider) {
    hre.ethers.provider = runtime.provider;
  }

  const signer = await runtime.getSigner(owner);

  const aaveV2VaultFactory = (await ethers.getContractFactory(
    "AaveV2Vault"
  )) as AaveV2Vault__factory;

  const vault = await aaveV2VaultFactory
    .connect(signer)
    .deploy(asset, aToken, aaveMining, owner, lendingPool, proxy, {
      gasLimit: "3000000",
    });

  const formattedVaultId = ethers.utils.formatBytes32String(vaultId);

  // Add vault
  const vaultsModule = await ethers.getContractAt("VaultsModule", proxy);
  const tx = await vaultsModule
    .connect(signer)
    .addVault(formattedVaultId, vault.address, minRate, maxRate);

  return {
    contracts: {
      AaveV2Vault: {
        address: vault.address,
        deployTxnHash: vault.deployTransaction.hash,
        abi,
      },
    },
    txns: { initialize_vault: tx },
  };
};

export { initializeAaveV2Vault };
