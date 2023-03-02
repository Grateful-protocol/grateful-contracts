import { ChainBuilderRuntime } from "@usecannon/builder/dist/src/types";
import { ethers } from "hardhat";

const hre = require("hardhat");

const initializeFeesModule = async (
  runtime: ChainBuilderRuntime,
  profile: string,
  proxy: string,
  owner: string,
  feePercentage: number
) => {
  if (runtime?.provider) {
    hre.ethers.provider = runtime.provider;
  }

  const signer = await runtime.getSigner(owner);

  // Get contracts
  const gratefulProfile = await ethers.getContractAt(
    "GratefulProfile",
    profile
  );
  const profileModule = await ethers.getContractAt("ProfilesModule", proxy);
  const feesModule = await ethers.getContractAt("FeesModule", proxy);

  // Get next token ID
  const tokenId = (await gratefulProfile.totalSupply()).add(1);

  await profileModule.createProfile(owner);

  // Get treasury profile ID
  const treasuryId = await profileModule.getProfileId(profile, tokenId);

  // Initialize Fees module
  const tx = await feesModule
    .connect(signer)
    .initializeFeesModule(treasuryId, feePercentage);

  return { txns: { initialize_fees: tx } };
};

export { initializeFeesModule };
