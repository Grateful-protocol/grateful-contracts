import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  GratefulProfile,
  GratefulProfile__factory,
  GratefulSubscription__factory,
  ProfilesModule,
} from "../../../typechain-types";
import { mintDAIMumbaiTokens } from "./vaults";

const addGratefulProfile = async (profileModule: ProfilesModule) => {
  const gratefulProfileFactory = (await ethers.getContractFactory(
    "GratefulProfile"
  )) as GratefulProfile__factory;

  const gratefulProfile = await gratefulProfileFactory.deploy();

  await profileModule.allowProfile(gratefulProfile.address);

  return gratefulProfile;
};

const deployGratefulSubscription = async () => {
  const gratefulSubscriptionFactory = (await ethers.getContractFactory(
    "GratefulSubscription"
  )) as GratefulSubscription__factory;

  const gratefulSubscription = await gratefulSubscriptionFactory.deploy();

  return gratefulSubscription;
};

const setupTreasury = async (
  owner: SignerWithAddress,
  gratefulProfile: GratefulProfile,
  profileModule: ProfilesModule
) => {
  const tokenId = await gratefulProfile.totalSupply();
  await gratefulProfile.safeMint(owner.address);

  const treasuryId = await profileModule.getProfileId(
    gratefulProfile.address,
    tokenId
  );

  return treasuryId;
};

const setupUser = async (
  user: SignerWithAddress,
  gratefulProfile: GratefulProfile,
  profileModule: ProfilesModule
) => {
  await mintDAIMumbaiTokens(user);

  const tokenId = await gratefulProfile.totalSupply();
  await gratefulProfile.safeMint(user.address);

  const profileId = await profileModule.getProfileId(
    gratefulProfile.address,
    tokenId
  );

  return { signer: user, address: user.address, tokenId, profileId };
};

export {
  addGratefulProfile,
  setupUser,
  deployGratefulSubscription,
  setupTreasury,
};
