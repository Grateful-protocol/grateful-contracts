import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { loadFixture, time } from "@nomicfoundation/hardhat-network-helpers";
import {
  GratefulProfile,
  OwnerModule,
  ProfilesModule,
  VaultsModule,
  FundsModule,
  AaveV2Vault,
  BalancesModule,
  ConfigModule,
  SubscriptionsModule,
  FeesModule,
  GratefulSubscription,
} from "../../typechain-types";
import { BigNumber } from "ethers";
import { addAaveV2DAIMumbaiVault } from "./utils/vaults";
import {
  addGratefulProfile,
  deployGratefulSubscription,
  setupTreasury,
  setupUser,
} from "./utils/users";
import { deposit } from "./utils/deposit";
import { withdraw } from "./utils/withdraw";
import { subscribe } from "./utils/subscribe";
import { advanceTime } from "./utils/advanceTime";
import { unsubscribe } from "./utils/unsubscribe";
import { update } from "./utils/update";

const { deploySystem } = require("@synthetixio/hardhat-router/utils/tests");
const {
  getProxyAddress,
} = require("@synthetixio/hardhat-router/utils/deployments");

type System = {
  proxyAddress: string;
  owner: SignerWithAddress;
  ownerModule: OwnerModule;
  vaultsModule: VaultsModule;
  profileModule: ProfilesModule;
  fundsModule: FundsModule;
  balancesModule: BalancesModule;
  configModule: ConfigModule;
  subscriptionsModule: SubscriptionsModule;
  feesModule: FeesModule;
  vault: AaveV2Vault;
  vaultId: string;
  treasuryId: string;
  gratefulProfile: GratefulProfile;
  gratefulSubscription: GratefulSubscription;
  giver: {
    signer: SignerWithAddress;
    address: string;
    tokenId: BigNumber;
    profileId: string;
  };
  creator: {
    signer: SignerWithAddress;
    address: string;
    tokenId: BigNumber;
    profileId: string;
  };
  SOLVENCY_TIME: BigNumber;
  FEE_PERCENTAGE: BigNumber;
};

// We define a fixture to reuse the same setup in every test.
// We use loadFixture to run this setup once, snapshot that state,
// and reset Hardhat Network to that snapshot in every test.
const deploySystemFixture = async () => {
  const deploymentInfo = {
    network: "hardhat",
    instance: "test",
  };

  await deploySystem(deploymentInfo, { clear: true });

  const proxyAddress = getProxyAddress(deploymentInfo);

  const ownerModule = (await ethers.getContractAt(
    "contracts/modules/OwnerModule.sol:OwnerModule",
    proxyAddress
  )) as OwnerModule;

  const vaultsModule = (await ethers.getContractAt(
    "VaultsModule",
    proxyAddress
  )) as VaultsModule;

  const profileModule = (await ethers.getContractAt(
    "ProfilesModule",
    proxyAddress
  )) as ProfilesModule;

  const fundsModule = (await ethers.getContractAt(
    "FundsModule",
    proxyAddress
  )) as FundsModule;

  const balancesModule = (await ethers.getContractAt(
    "BalancesModule",
    proxyAddress
  )) as BalancesModule;

  const configModule = (await ethers.getContractAt(
    "ConfigModule",
    proxyAddress
  )) as ConfigModule;

  const subscriptionsModule = (await ethers.getContractAt(
    "SubscriptionsModule",
    proxyAddress
  )) as SubscriptionsModule;

  const feesModule = (await ethers.getContractAt(
    "FeesModule",
    proxyAddress
  )) as FeesModule;

  return {
    proxyAddress,
    ownerModule,
    vaultsModule,
    profileModule,
    fundsModule,
    balancesModule,
    configModule,
    subscriptionsModule,
    feesModule,
  };
};

const initializeOwnerModule = async (
  ownerModule: OwnerModule,
  owner: SignerWithAddress
) => {
  const tx = await ownerModule
    .connect(owner)
    .initializeOwnerModule(owner.address);

  await tx.wait();
};

const initializeConfigModule = async (
  configModule: ConfigModule,
  owner: SignerWithAddress,
  solvencyTime: BigNumber,
  gratefulSubscription: GratefulSubscription
) => {
  const tx = await configModule
    .connect(owner)
    .initializeConfigModule(solvencyTime, gratefulSubscription.address);

  await tx.wait();
};

const initializeFeesModule = async (
  feesModule: FeesModule,
  owner: SignerWithAddress,
  treasuryId: string,
  feePercentage: BigNumber
) => {
  const tx = await feesModule
    .connect(owner)
    .initializeFeesModule(treasuryId, feePercentage);

  await tx.wait();
};

const deploySystemWithOwner = async () => {
  // Contracts are deployed using the first signer/account by default
  const [owner] = await ethers.getSigners();

  const { ownerModule, ...modules } = await deploySystemFixture();

  await initializeOwnerModule(ownerModule, owner);

  return { ownerModule, owner, ...modules };
};

const deployCompleteSystem = async (): Promise<System> => {
  const modules = await deploySystemWithOwner();

  const {
    vaultsModule,
    profileModule,
    configModule,
    feesModule,
    owner,
    proxyAddress,
  } = modules;

  // Create vault and add it to the system
  const vault = await addAaveV2DAIMumbaiVault(vaultsModule);

  // Create Profile NFT and allow it
  const gratefulProfile = await addGratefulProfile(profileModule);

  // Create Subscription NFT and allow it
  const gratefulSubscription = await deployGratefulSubscription(proxyAddress);

  // Setup config module
  const SOLVENCY_TIME = BigNumber.from(604800); // 1 week
  await initializeConfigModule(
    configModule,
    owner,
    SOLVENCY_TIME,
    gratefulSubscription
  );

  // Setup fees module
  const FEE_PERCENTAGE = BigNumber.from(4); // 4%
  const treasuryId = await setupTreasury(owner, gratefulProfile, profileModule);
  await initializeFeesModule(feesModule, owner, treasuryId, FEE_PERCENTAGE);

  // Setup users
  const [, giverSigner, creatorSigner] = await ethers.getSigners();
  const giver = await setupUser(giverSigner, gratefulProfile, profileModule);
  const creator = await setupUser(
    creatorSigner,
    gratefulProfile,
    profileModule
  );

  return {
    ...modules,
    ...vault,
    gratefulProfile,
    giver,
    creator,
    gratefulSubscription,
    SOLVENCY_TIME,
    FEE_PERCENTAGE,
    treasuryId,
  };
};

const depositFixture = async () => {
  const fixture = await loadFixture(deployCompleteSystem);
  return deposit(fixture);
};

const withdrawFixture = async () => {
  const fixture = await loadFixture(depositFixture);
  return withdraw(fixture);
};

const subscribeFixture = async () => {
  const fixture = await loadFixture(depositFixture);
  return subscribe(fixture);
};

const advanceTimeFixture = async () => {
  const fixture = await loadFixture(subscribeFixture);
  return advanceTime(fixture);
};

const unsubscribeFixture = async () => {
  const fixture = await loadFixture(advanceTimeFixture);
  return unsubscribe(fixture);
};

const updateFixture = async () => {
  const fixture = await loadFixture(unsubscribeFixture);
  return update(fixture);
};

export {
  System,
  deployCompleteSystem,
  deploySystemFixture,
  deploySystemWithOwner,
  depositFixture,
  withdrawFixture,
  subscribeFixture,
  advanceTimeFixture,
  unsubscribeFixture,
  updateFixture,
};
