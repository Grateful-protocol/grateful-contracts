import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { GratefulProfile, ProfilesModule } from "../../../typechain-types";
import { mintDAIMumbaiTokens } from "./vaults";

const setupUser = async (
  user: SignerWithAddress,
  gratefulProfile: GratefulProfile,
  profileModule: ProfilesModule
) => {
  await mintDAIMumbaiTokens(user);

  const SALT = ethers.utils.formatBytes32String("Grateful");
  const tokenId = (await gratefulProfile.totalSupply()).add(1);
  await profileModule.createProfile(user.address, SALT);

  const profileId = await profileModule.getProfileId(
    gratefulProfile.address,
    tokenId
  );

  return { signer: user, address: user.address, tokenId, profileId };
};

export { setupUser };
