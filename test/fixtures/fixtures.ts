import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import {
  GratefulProfile,
  OwnerModule,
  ProfilesModule,
  VaultsModule,
  FundsModule,
  AaveV2Vault,
  BalancesModule,
} from "../../typechain-types";
import { BigNumber } from "ethers";
import { addAaveV2DAIMumbaiVault } from "./utils/vaults";
import { addGratefulProfile, setupUser } from "./utils/users";
import { deposit } from "./utils/deposit";
import { withdraw } from "./utils/withdraw";

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
  vault: AaveV2Vault;
  vaultId: string;
  gratefulProfile: GratefulProfile;
  giver: {
    signer: SignerWithAddress;
    address: string;
    tokenId: BigNumber;
    profileId: string;
  };
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

  return {
    proxyAddress,
    ownerModule,
    vaultsModule,
    profileModule,
    fundsModule,
    balancesModule,
  };
};

const initializeOwnerModule = async (
  ownerModule: OwnerModule,
  owner: SignerWithAddress
) => {
  // Initialize Owner Module
  const tx = await ownerModule
    .connect(owner)
    .initializeOwnerModule(owner.address);

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

  const { vaultsModule, profileModule } = modules;

  const vault = await addAaveV2DAIMumbaiVault(vaultsModule);

  const profile = await addGratefulProfile(profileModule);

  // Setup users
  const { gratefulProfile } = profile;
  const [, giverSigner] = await ethers.getSigners();
  const giver = await setupUser(giverSigner, gratefulProfile, profileModule);

  return { ...modules, ...vault, ...profile, giver };
};

const depositFixture = async () => {
  const fixture = await loadFixture(deployCompleteSystem);
  return deposit(fixture);
};

const withdrawFixture = async () => {
  const fixture = await loadFixture(depositFixture);
  return withdraw(fixture);
};

export {
  System,
  deployCompleteSystem,
  deploySystemFixture,
  deploySystemWithOwner,
  depositFixture,
  withdrawFixture,
};
